#!/usr/bin/env python3
"""Determine if bypass ELF ACTUALLY neutralizes anti-cheat (hooks/patches Tencent libs)
or is just advertising. Analyze: does it mprotect+write to libanogs/libITOP code?
Does it install real hooks, or only run the 3 promo system() calls?"""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

LIB='/projects/sandbox/decompiled_apk/assets/servernrot/bypass'
b=lief.parse(LIB); raw=open(LIB,'rb').read()

def v2o(va):
    for s in b.segments:
        if s.type.name=='LOAD' and s.virtual_address<=va<s.virtual_address+s.virtual_size:
            fo=s.file_offset+(va-s.virtual_address)
            if fo<s.file_offset+s.physical_size: return fo
    return None
def cstr(va,m=160):
    o=v2o(va)
    if o is None: return None
    e=raw.find(b'\x00',o,o+m)
    if e==-1: return None
    try:
        s=raw[o:e].decode('utf-8'); return s if s.isprintable() and len(s)>=2 else None
    except: return None

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

# Which imports does bypass use? Full list
print("═══ كل استيرادات bypass (الدوال الخارجية) ═══")
imports=sorted(set(reloc.values()))
for i in imports: print(f"  {i}")

# Find all string references to Tencent libs and what code touches them
print("\n═══ الدوال التي تشير لمكتبات Tencent + ماذا تفعل بها ═══")
tencent=['libanogs','libITOP','libCrashSight','libAntsVoice','libGCloudVoice','libUE4','libNetEaseCrash']
tsec=[s for s in b.sections if s.name=='.text'][0]
code=raw[tsec.file_offset:tsec.file_offset+tsec.size]; tva=tsec.virtual_address

# locate string addresses for tencent libs
lib_addrs={}
for s in b.sections:
    if s.name in ('.rodata','.data.rel.ro','.data'):
        data=raw[s.file_offset:s.file_offset+s.size]
        for name in tencent:
            idx=0
            while True:
                p=data.find(name.encode(),idx)
                if p<0: break
                lib_addrs[s.virtual_address+p]=data[p:p+40].split(b'\x00')[0].decode('ascii','replace')
                idx=p+1
print("  عناوين سلاسل مكتبات Tencent:")
for a,n in lib_addrs.items(): print(f"    0x{a:x}: {n!r}")

# Count critical hooking primitives usage
print("\n═══ أدوات الـ hooking/patching الفعلية المستخدمة ═══")
counts={}
for i in range(0,len(code)-4,4):
    ins=list(md.disasm(code[i:i+4],tva+i))
    if ins and ins[0].mnemonic=='bl' and ins[0].op_str.startswith('#'):
        t=int(ins[0].op_str[1:],16)
        if t in plt:
            counts[plt[t]]=counts.get(plt[t],0)+1
for fn in ['mprotect','memcpy','__memcpy_chk','dlopen','dlsym','mmap','mremap','system','fopen','open','pthread_create','__android_log_print','puts','sprintf','snprintf']:
    if fn in counts: print(f"  {fn}: {counts[fn]} استدعاء")

# Does it dlopen the tencent libs? Check dlopen call sites and their string args
print("\n═══ هل يفتح (dlopen) مكتبات anti-cheat فعلاً؟ ═══")
dlopen_plt=[a for a,n in plt.items() if n=='dlopen']
found_dlopen=False
for i in range(0,len(code)-4,4):
    ins=list(md.disasm(code[i:i+4],tva+i))
    if ins and ins[0].mnemonic=='bl' and ins[0].op_str.startswith('#'):
        t=int(ins[0].op_str[1:],16)
        if t in dlopen_plt:
            found_dlopen=True
            # look back for the string arg (adrp+add into x0)
            off=v2o(tva+i-0x28); adrp={}
            argstr=None
            for j in md.disasm(raw[off:off+0x28],tva+i-0x28):
                if j.mnemonic=='adrp':
                    p=j.op_str.split(', ')
                    try: adrp[p[0]]=int(p[1][1:],16)
                    except: pass
                elif j.mnemonic=='add' and j.op_str.count(',')>=2:
                    p=j.op_str.split(', ')
                    if len(p)>=3 and p[1] in adrp and p[2].startswith('#'):
                        argstr=cstr(adrp[p[1]]+int(p[2][1:],16))
            print(f"  dlopen @ 0x{tva+i:x}  arg={argstr!r}")
if not found_dlopen: print("  لا يوجد استدعاء dlopen (لا يفتح المكتبات ديناميكياً)")

# Does it mprotect then write (real code patching)?
print("\n═══ هل يعدّل كود anti-cheat (mprotect ثم كتابة)؟ ═══")
mprotect_sites=[]
for i in range(0,len(code)-4,4):
    ins=list(md.disasm(code[i:i+4],tva+i))
    if ins and ins[0].mnemonic=='bl' and ins[0].op_str.startswith('#'):
        t=int(ins[0].op_str[1:],16)
        if t in plt and plt[t]=='mprotect':
            mprotect_sites.append(tva+i)
print(f"  مواقع mprotect: {[hex(x) for x in mprotect_sites]}")
