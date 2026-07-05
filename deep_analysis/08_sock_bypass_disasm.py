#!/usr/bin/env python3
"""Disassemble sock daemon + bypass ELF: entry, init_array, and functions that
call popen/socket/connect/system to prove the protocol and hooking mechanism."""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

def analyze(path, name, watch_imports):
    print("\n" + "="*74)
    print(f"BINARY: {name}  ({path})")
    print("="*74)
    b = lief.parse(path)
    raw = open(path,'rb').read()

    def v2o(va):
        for s in b.segments:
            if s.type.name=='LOAD' and s.virtual_address<=va<s.virtual_address+s.virtual_size:
                fo = s.file_offset+(va-s.virtual_address)
                if fo < s.file_offset+s.physical_size: return fo
        return None
    def cstr(va, m=120):
        off=v2o(va)
        if off is None: return None
        e=raw.find(b'\x00',off,off+m)
        if e==-1: return None
        try:
            s=raw[off:e].decode('utf-8')
            return s if s.isprintable() and len(s)>=2 else None
        except: return None

    # Map imports to PLT via relocations
    reloc={}
    for r in b.pltgot_relocations:
        if hasattr(r,'address') and r.symbol:
            reloc[r.address]=r.symbol.name
    md=Cs(CS_ARCH_ARM64,CS_MODE_ARM)
    plt={}
    # find .plt
    plt_sec=None
    for s in b.sections:
        if s.name=='.plt': plt_sec=s
    if plt_sec:
        for pa in range(plt_sec.virtual_address, plt_sec.virtual_address+plt_sec.size, 16):
            off=v2o(pa)
            if off is None: continue
            ins=list(md.disasm(raw[off:off+16],pa))
            if len(ins)>=3 and ins[0].mnemonic=='adrp':
                try:
                    adrp_imm=int(ins[0].op_str.split('#')[1].rstrip(']'),16)
                    ldr_off=0
                    for x in ins[1:]:
                        if x.mnemonic in ('ldr',) and '#' in x.op_str:
                            ldr_off=int(x.op_str.split('#')[-1].rstrip(']'),16); break
                    got=adrp_imm+ldr_off
                    if got in reloc: plt[pa]=reloc[got]
                except: pass

    # entry + init_array functions
    print(f"  Entry: 0x{b.header.entrypoint:x}")
    init_fns=[]
    for s in b.sections:
        if s.name in ('.init_array','.preinit_array'):
            off=s.file_offset
            for i in range(0, s.size, 8):
                ptr=int.from_bytes(raw[off+i:off+i+8],'little')
                if ptr: init_fns.append(ptr)
    print(f"  init_array fns: {[hex(x) for x in init_fns]}")

    # Find functions that reference watched imports: scan .text for bl to those PLT stubs
    watch_plt = {pa:sym for pa,sym in plt.items() if sym in watch_imports}
    print(f"  Watched import PLT stubs: {[(hex(a),s) for a,s in watch_plt.items()]}")

    text=None
    for s in b.sections:
        if s.name=='.text':
            text=(s.file_offset, s.virtual_address, s.size)
    if not text: 
        print("  no .text"); return
    toff,tva,tsize=text
    code=raw[toff:toff+tsize]

    # find call sites
    print(f"\n  ── Call sites to watched imports ──")
    callsites={}
    for i in range(0,len(code)-4,4):
        va=tva+i
        ins=list(md.disasm(code[i:i+4],va))
        if not ins: continue
        ii=ins[0]
        if ii.mnemonic=='bl' and ii.op_str.startswith('#'):
            tgt=int(ii.op_str[1:],16)
            if tgt in watch_plt:
                callsites.setdefault(watch_plt[tgt],[]).append(va)
    for sym,sites in callsites.items():
        print(f"    {sym}: {len(sites)} calls @ {[hex(s) for s in sites[:8]]}")

    # Dump context around FIRST call to key imports, resolving string args
    print(f"\n  ── Context around key call sites (with string resolution) ──")
    key_syms=[s for s in ('popen','system','connect','socket','bind','fopen','open') if s in callsites]
    for sym in key_syms[:4]:
        site=callsites[sym][0]
        print(f"\n    ┌─ near {sym} @ 0x{site:x}")
        start=site-0x40
        soff=v2o(start)
        if soff is None: continue
        adrp_regs={}
        for ins in md.disasm(raw[soff:soff+0x50], start):
            note=""
            if ins.mnemonic=='adrp':
                p=ins.op_str.split(', ')
                try: adrp_regs[p[0]]=int(p[1][1:],16)
                except: pass
            elif ins.mnemonic=='add' and ins.op_str.count(',')>=2:
                p=ins.op_str.split(', ')
                if len(p)>=3 and p[1] in adrp_regs and p[2].startswith('#'):
                    try:
                        val=adrp_regs[p[1]]+int(p[2][1:],16)
                        s=cstr(val)
                        if s: note=f'   ; "{s}"'
                    except: pass
            elif ins.mnemonic=='bl' and ins.op_str.startswith('#'):
                t=int(ins.op_str[1:],16)
                if t in plt: note=f"   ; -> {plt[t]}"
            print(f"      0x{ins.address:x}  {ins.mnemonic:<7} {ins.op_str}{note}")

    # ALL notable strings
    print(f"\n  ── All notable strings ──")
    seen=set()
    for s in b.sections:
        if s.name in ('.rodata','.data.rel.ro','.data'):
            data=raw[s.file_offset:s.file_offset+s.size]
            cur=b''; st=0
            for i,ch in enumerate(data):
                if 32<=ch<=126:
                    if not cur: st=i
                    cur+=bytes([ch])
                else:
                    if len(cur)>=4:
                        txt=cur.decode('ascii')
                        if txt not in seen and not txt.startswith('__') and 'clang' not in txt.lower():
                            seen.add(txt)
                    cur=b''
    kws=['/proc','/data','/sdcard','sock','socket','pidof','ps ','kill','libanogs','libunity','il2cpp','.so','com.','maps','mem','cmdline','stat','Bypass','Active','hook','LD_','tmp','/system','chmod','su','/dev']
    notable=[s for s in seen if any(k in s for k in kws)]
    for s in sorted(notable):
        print(f"    {s!r}")

analyze('/projects/sandbox/decompiled_apk/assets/servernrot/sock','sock daemon',
        {'popen','socket','connect','open','bind','fopen','read','pclose'})
analyze('/projects/sandbox/decompiled_apk/assets/servernrot/bypass','bypass ELF',
        {'system','fopen','open','mprotect','pthread_create'})
