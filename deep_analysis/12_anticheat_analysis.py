#!/usr/bin/env python3
"""Deep analysis of anti-cheat/anti-ban: disassemble libTcore JNI_OnLoad and
hook-init functions to prove what anti-detection is ACTUALLY wired at load time."""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

LIB='/projects/sandbox/decompiled_apk/lib/arm64-v8a/libTcore.so'
b=lief.parse(LIB); raw=open(LIB,'rb').read()

def v2o(va):
    for s in b.segments:
        if s.type.name=='LOAD' and s.virtual_address<=va<s.virtual_address+s.virtual_size:
            fo=s.file_offset+(va-s.virtual_address)
            if fo<s.file_offset+s.physical_size: return fo
    return None
def cstr(va,m=140):
    o=v2o(va)
    if o is None: return None
    e=raw.find(b'\x00',o,o+m)
    if e==-1: return None
    try:
        s=raw[o:e].decode('utf-8')
        return s if s.isprintable() and len(s)>=2 else None
    except: return None

# PLT map
reloc={}
for r in b.pltgot_relocations:
    if hasattr(r,'address') and r.symbol: reloc[r.address]=r.symbol.name
md=Cs(CS_ARCH_ARM64,CS_MODE_ARM)
plt={}
for s in b.sections:
    if s.name=='.plt':
        for pa in range(s.virtual_address,s.virtual_address+s.size,16):
            off=v2o(pa)
            if off is None: continue
            ins=list(md.disasm(raw[off:off+16],pa))
            if len(ins)>=3 and ins[0].mnemonic=='adrp':
                try:
                    ai=int(ins[0].op_str.split('#')[1].rstrip(']'),16)
                    lo=0
                    for x in ins[1:]:
                        if x.mnemonic=='ldr' and '#' in x.op_str: lo=int(x.op_str.split('#')[-1].rstrip(']'),16);break
                    if ai+lo in reloc: plt[pa]=reloc[ai+lo]
                except: pass

# local function symbols (for resolving bl to internal funcs like hideXposed)
localfns={}
for s in b.symbols:
    if s.value and s.name:
        localfns[s.value]=s.name
for s in b.exported_symbols:
    if s.value and s.name:
        localfns[s.value]=s.name

def disasm(name, va, count=160, stop_ret=True):
    print(f"\n{'='*70}\n{name} @ 0x{va:x}\n{'='*70}")
    off=v2o(va)
    if off is None: print("  (no content)"); return
    adrp={}
    for ins in md.disasm(raw[off:off+count*4], va):
        note=""
        if ins.mnemonic=='adrp':
            p=ins.op_str.split(', ')
            try: adrp[p[0]]=int(p[1][1:],16)
            except: pass
        elif ins.mnemonic=='add' and ins.op_str.count(',')>=2:
            p=ins.op_str.split(', ')
            if len(p)>=3 and p[1] in adrp and p[2].startswith('#'):
                try:
                    val=adrp[p[1]]+int(p[2][1:],16)
                    s=cstr(val)
                    if s: note=f'   ; "{s}"'
                    adrp[p[0]]=val
                except: pass
        elif ins.mnemonic in ('bl','b') and ins.op_str.startswith('#'):
            t=int(ins.op_str[1:],16)
            if t in plt: note=f"   ; -> {plt[t]} (import)"
            elif t in localfns: note=f"   ; -> {localfns[t]}"
        print(f"  0x{ins.address:x}  {ins.mnemonic:<8} {ins.op_str}{note}")
        if stop_ret and ins.mnemonic=='ret': break

# 1. JNI_OnLoad
onload=[s.value for s in b.exported_symbols if s.name=='JNI_OnLoad']
if onload: disasm('JNI_OnLoad', onload[0], 200)

# 2. hideXposed - what does it actually do?
for s in b.exported_symbols:
    if 'hideXposed' in s.name and 'JNIEnv' in s.name:
        disasm(s.name, s.value, 120)
        break

# 3. nativeHook
for s in b.exported_symbols:
    if s.name=='_Z10nativeHookP7_JNIEnv':
        disasm(s.name, s.value, 80)
        break

# 4. List RegisterNatives-style: which Java_ methods does libTcore register dynamically?
print(f"\n{'='*70}\nSearching for anti-detection strings in libTcore\n{'='*70}")
for s in b.sections:
    if s.name in ('.rodata','.data.rel.ro'):
        data=raw[s.file_offset:s.file_offset+s.size]
        cur=b'';st=0
        for i,ch in enumerate(data):
            if 32<=ch<=126:
                if not cur: st=i
                cur+=bytes([ch])
            else:
                if len(cur)>=4:
                    t=cur.decode('ascii')
                    if any(k in t.lower() for k in ['xposed','magisk','frida','substrate','riru','zygisk','su','root','/proc','maps','emulator','goldfish','anogs','tencent','detect','hook','ptrace','TracerPid','/system/','busybox','supersu','.so']):
                        print(f"  0x{s.virtual_address+st:x}: {t!r}")
                cur=b''
