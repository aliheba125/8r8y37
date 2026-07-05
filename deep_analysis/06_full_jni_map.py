#!/usr/bin/env python3
"""Disassemble ALL JNI exports in libclient.so with full string/PLT resolution."""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM, CS_OP_IMM, CS_OP_REG

LIB = '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libclient.so'
b = lief.parse(LIB)
raw = open(LIB, 'rb').read()

def v2o(vaddr):
    for s in b.segments:
        if s.type.name == 'LOAD' and s.virtual_address <= vaddr < s.virtual_address + s.virtual_size:
            fo = s.file_offset + (vaddr - s.virtual_address)
            if fo < s.file_offset + s.physical_size:
                return fo
            return None  # BSS (no file content)
    return None

def cstr(vaddr, maxlen=120):
    off = v2o(vaddr)
    if off is None: return None
    end = raw.find(b'\x00', off, off+maxlen)
    if end == -1: return None
    try:
        s = raw[off:end].decode('utf-8')
        return s if s.isprintable() else None
    except: return None

# Build PLT -> symbol map
md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
plt_map = {}  # plt_vaddr -> symbol name
reloc_map = {}  # got vaddr -> symbol
for r in b.pltgot_relocations:
    if hasattr(r,'address') and r.symbol:
        reloc_map[r.address] = r.symbol.name
for plt_addr in range(0x49420, 0x49420+0x860, 16):
    off = v2o(plt_addr)
    if off is None: continue
    inst = list(md.disasm(raw[off:off+16], plt_addr))
    if len(inst) >= 2 and inst[0].mnemonic=='adrp' and inst[1].mnemonic=='ldr':
        # parse operands manually from op_str
        try:
            page = int(inst[0].op_str.split('#')[1].split(',')[0], 16) if '#' in inst[0].op_str else 0
            # adrp target
            adrp_imm = None
            for tok in inst[0].op_str.replace(',',' ').split():
                if tok.startswith('#0x'):
                    adrp_imm = int(tok[1:], 16)
            ldr_off = 0
            if '#' in inst[1].op_str:
                seg = inst[1].op_str.split('#')[-1].rstrip(']')
                ldr_off = int(seg, 16)
            got = adrp_imm + ldr_off
            if got in reloc_map:
                plt_map[plt_addr] = reloc_map[got]
        except: pass

JNI = [s for s in b.exported_symbols if s.name.startswith('Java_')]
JNI.sort(key=lambda x: x.value)

md2 = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

def disasm_fn(name, va, maxins=120):
    print(f"\n{'='*72}\n{name}  @ 0x{va:x}\n{'='*72}")
    off = v2o(va)
    if off is None:
        print("  (no file content)"); return
    code = raw[off:off+maxins*4]
    adrp_regs = {}  # reg -> page value for string resolution
    for ins in md2.disasm(code, va):
        note = ""
        if ins.mnemonic == 'adrp':
            parts = ins.op_str.split(', ')
            reg = parts[0]
            imm = int(parts[1][1:], 16)
            adrp_regs[reg] = imm
        elif ins.mnemonic == 'add' and ins.op_str.count(',')>=2:
            parts = ins.op_str.split(', ')
            dst, src = parts[0], parts[1]
            if src in adrp_regs and parts[2].startswith('#'):
                try:
                    val = adrp_regs[src] + int(parts[2][1:],16)
                    s = cstr(val)
                    if s is not None:
                        note = f"   ; \"{s}\" @0x{val:x}"
                    adrp_regs[dst] = val
                except: pass
        elif ins.mnemonic in ('bl','b') and ins.op_str.startswith('#'):
            tgt = int(ins.op_str[1:],16)
            if tgt in plt_map:
                note = f"   ; -> {plt_map[tgt]}"
        print(f"  0x{ins.address:06x}  {ins.mnemonic:<8} {ins.op_str}{note}")
        if ins.mnemonic == 'ret':
            break

for s in JNI:
    disasm_fn(s.name, s.value)
