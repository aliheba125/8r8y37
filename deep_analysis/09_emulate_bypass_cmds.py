#!/usr/bin/env python3
"""Emulate bypass ELF functions up to each system()/puts call to recover the
runtime-decrypted command strings (they're XOR-obfuscated in .data)."""
import lief
from unicorn import *
from unicorn.arm64_const import *
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

LIB='/projects/sandbox/decompiled_apk/assets/servernrot/bypass'
b=lief.parse(LIB)
raw=open(LIB,'rb').read()

MAP_BASE=0x0
MAP_SIZE=0x120000  # covers up to ~0x100000
STACK=0x40000000; STACK_SIZE=0x40000

# PLT resolution
reloc={}
for r in b.pltgot_relocations:
    if hasattr(r,'address') and r.symbol: reloc[r.address]=r.symbol.name
md=Cs(CS_ARCH_ARM64,CS_MODE_ARM)
def v2o(va):
    for s in b.segments:
        if s.type.name=='LOAD' and s.virtual_address<=va<s.virtual_address+s.virtual_size:
            fo=s.file_offset+(va-s.virtual_address)
            if fo<s.file_offset+s.physical_size: return fo
    return None
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
                        if x.mnemonic=='ldr' and '#' in x.op_str:
                            lo=int(x.op_str.split('#')[-1].rstrip(']'),16);break
                    if ai+lo in reloc: plt[pa]=reloc[ai+lo]
                except: pass

# Find function starts (functions containing system/puts calls we care about)
# We'll emulate from a set of function entry points and capture args to system/puts.
# Function entries: scan backwards from call site to prologue (stp x29,x30 / sub sp).
def find_func_start(site):
    off=v2o(site)
    # scan backward up to 0x400 bytes for a prologue
    for delta in range(0, 0x600, 4):
        va=site-delta
        o=v2o(va)
        if o is None: continue
        ins=list(md.disasm(raw[o:o+8],va))
        if len(ins)>=1:
            m=ins[0]
            # common prologue: sub sp, sp, #imm  OR stp x29,x30
            if m.mnemonic=='sub' and m.op_str.startswith('sp, sp,'):
                # check previous isn't part of another func; good enough
                return va
    return site-0x40

def emulate_capture(func_va, name, stop_after_calls=6):
    uc=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
    uc.mem_map(MAP_BASE,MAP_SIZE)
    for s in b.segments:
        if s.type.name=='LOAD':
            c=bytes(s.content)
            if c: uc.mem_write(MAP_BASE+s.virtual_address,c)
    uc.mem_map(STACK,STACK_SIZE)
    # scratch for tpidr_el0 reads: map a TLS region and set it
    TLS=0x50000000
    uc.mem_map(TLS,0x4000)
    uc.reg_write(UC_ARM64_REG_TPIDR_EL0, TLS)
    captured=[]
    calls=[0]
    def readstr(uc,addr,m=200):
        out=b''
        try:
            for i in range(m):
                ch=uc.mem_read(addr+i,1)
                if ch==b'\x00':break
                out+=bytes(ch)
        except: pass
        return out
    def hook(uc,address,size,ud):
        if address in plt:
            sym=plt[address]
            lr=uc.reg_read(UC_ARM64_REG_LR)
            if sym in ('system','puts','popen','fopen','__android_log_print','snprintf','sprintf','printf'):
                x0=uc.reg_read(UC_ARM64_REG_X0)
                arg=readstr(uc,x0)
                # for log_print/printf the fmt is x0; for system/puts too
                if sym in ('system','puts'):
                    captured.append((sym,arg))
                    calls[0]+=1
            # emulate return
            if sym=='system': uc.reg_write(UC_ARM64_REG_X0,0)
            elif sym in ('fopen','popen'): uc.reg_write(UC_ARM64_REG_X0,0)  # NULL -> caller bails early
            else: uc.reg_write(UC_ARM64_REG_X0,0)
            uc.reg_write(UC_ARM64_REG_PC,lr)
            if calls[0]>=stop_after_calls: uc.emu_stop()
    uc.hook_add(UC_HOOK_CODE,hook)
    uc.reg_write(UC_ARM64_REG_SP,STACK+STACK_SIZE-0x1000)
    uc.reg_write(UC_ARM64_REG_LR,0xdeadbeef)
    uc.reg_write(UC_ARM64_REG_X0,0x1234)  # fake pid arg
    uc.reg_write(UC_ARM64_REG_X1,0x50002000)
    try:
        uc.emu_start(func_va,0xdeadbeef,count=200000)
    except UcError as e:
        pass
    return captured

# system call sites found earlier
SITES={'system_fn1':0xe798,'system_fn2':0xec94,'system_fn3':0x129b4,'init_de00':0xde00,
       'init_df44':0xdf44,'init_df78':0xdf78,'init_df9c':0xdf9c,'entry':0xe3a8}

print("═"*70)
print("BYPASS ELF — decrypted system()/puts() commands via emulation")
print("═"*70)
done=set()
for label,site in SITES.items():
    if label.startswith('system_fn'):
        fstart=find_func_start(site)
    else:
        fstart=site
    if fstart in done: 
        continue
    done.add(fstart)
    cap=emulate_capture(fstart,label)
    print(f"\n[{label}] emulate from 0x{fstart:x}:")
    if cap:
        for sym,arg in cap:
            try: dec=arg.decode('utf-8','replace')
            except: dec=repr(arg)
            print(f"    {sym}(\"{dec}\")")
    else:
        print("    (no system/puts captured)")
