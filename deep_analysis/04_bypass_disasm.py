#!/usr/bin/env python3
"""Disassemble critical JNI functions in libclient.so to see actual behavior."""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

LIB = '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libclient.so'
b = lief.parse(LIB)
raw = open(LIB, 'rb').read()

# Build vaddr -> file offset map
def vaddr_to_offset(vaddr):
    for s in b.segments:
        if s.type.name != 'LOAD':
            continue
        if s.virtual_address <= vaddr < s.virtual_address + s.virtual_size:
            return s.file_offset + (vaddr - s.virtual_address)
    return None

md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
md.detail = True

# Critical functions to disassemble
TARGETS = [
    ('Java_com_pubgm_activity_MainActivity_BYPASS', 0x1f1a0, 200),  # 200 instructions
    ('Java_com_pubgm_activity_MainActivity_VERSIONS', 0x1f190, 30),
    ('Java_com_pubgm_activity_LoginActivity_Yellow', 0x1f17c, 30),
    ('Java_com_pubgm_activity_LoginActivity_GetKey', 0x1ef54, 100),
    ('Java_com_pubgm_floating_Overlay_getReady', 0x23520, 100),
    ('Java_com_pubgm_fragments_HomeFragment_Telegram', 0x230dc, 100),
]

# Also get read-only data segment for string cross-references
rodata_off = None
rodata_vaddr = None
rodata_size = None
for sect in b.sections:
    if sect.name == '.rodata':
        rodata_off = sect.file_offset
        rodata_vaddr = sect.virtual_address
        rodata_size = sect.size
        print(f"  .rodata @ vaddr=0x{rodata_vaddr:x} size=0x{rodata_size:x}")

def read_cstring_at_vaddr(vaddr, maxlen=200):
    off = vaddr_to_offset(vaddr)
    if off is None:
        return None
    end = raw.find(b'\x00', off, off+maxlen)
    if end == -1:
        return None
    try:
        return raw[off:end].decode('utf-8', errors='replace')
    except:
        return None

for name, va, count in TARGETS:
    off = vaddr_to_offset(va)
    print(f"\n{'═' * 70}")
    print(f"FUNCTION: {name}  @ vaddr 0x{va:x}  file offset 0x{off:x}")
    print("═" * 70)
    code = raw[off:off+count*4]
    for i, ins in enumerate(md.disasm(code, va)):
        # Try to resolve string references (adrp + add/ldr pattern)
        annotation = ""
        if ins.mnemonic == 'adrp':
            # Track for next inst
            pass
        # Look for calls
        if ins.mnemonic in ('bl', 'b'):
            target = ins.operands[0].imm if ins.operands else None
            if target:
                # Try to find function name at this offset (symbol lookup)
                for s in b.symbols:
                    if s.value == target:
                        annotation = f"  ; -> {s.name}"
                        break
        print(f"  0x{ins.address:08x}  {ins.mnemonic:<10}  {ins.op_str}{annotation}")
        # Stop on unconditional return
        if ins.mnemonic == 'ret' and i > 3:
            break
