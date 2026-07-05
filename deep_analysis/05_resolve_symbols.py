#!/usr/bin/env python3
"""Resolve helper functions and Yellow's return string in libclient.so."""
import lief
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

LIB = '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libclient.so'
b = lief.parse(LIB)
raw = open(LIB, 'rb').read()

def vaddr_to_offset(vaddr):
    for s in b.segments:
        if s.type.name != 'LOAD':
            continue
        if s.virtual_address <= vaddr < s.virtual_address + s.virtual_size:
            return s.file_offset + (vaddr - s.virtual_address)
    return None

def read_cstring(vaddr, maxlen=200):
    off = vaddr_to_offset(vaddr)
    if off is None: return None
    end = raw.find(b'\x00', off, off+maxlen)
    if end == -1: return None
    try: return raw[off:end].decode('utf-8', errors='replace')
    except: return None

# 1) Yellow() returns NewStringUTF(env, <str at 0x144b9>)
YELLOW_STR_VA = 0x14000 + 0x4b9
print(f"═══ Yellow() return string ═══")
print(f"vaddr 0x{YELLOW_STR_VA:x} => {read_cstring(YELLOW_STR_VA)!r}")

# 2) What's at 0x49490? BYPASS calls this. Check the PLT
print(f"\n═══ Function at 0x49490 (called by BYPASS/VERSIONS) ═══")
off = vaddr_to_offset(0x49490)
if off:
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    code = raw[off:off+40]
    for ins in md.disasm(code, 0x49490):
        print(f"  0x{ins.address:x}  {ins.mnemonic:<10}  {ins.op_str}")

# Check if it's a PLT stub for an imported function
print(f"\n═══ .plt section ═══")
for sect in b.sections:
    if sect.name in ('.plt', '.got.plt', '.got'):
        print(f"  {sect.name}: vaddr=0x{sect.virtual_address:x} size=0x{sect.size:x}")

# Cross-reference: find import name at 0x49490 
# In LIEF, imports are symbols; PLT slots correspond
print(f"\n═══ Imported symbols (PLT candidates) ═══")
for imp in b.imported_symbols:
    if imp.value != 0:
        print(f"  0x{imp.value:x}  {imp.name}")

# 3) Try to find all NewStringUTF calls in libclient.so (Java_* return strings)
# Pattern: adrp x1, page ; add x1, x1, offset ; ldr x2, [x8, #0x538] ; br x2
print(f"\n═══ All hardcoded strings returned via NewStringUTF (offset 0x538) ═══")
md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
md.detail = True

# Scan .text for pattern: adrp + add + ldr [x8, #0x538] + br
text = None
for sect in b.sections:
    if sect.name == '.text':
        text_off = sect.file_offset
        text_va = sect.virtual_address
        text_size = sect.size
        text = raw[text_off:text_off+text_size]
        break

found = 0
if text:
    # walk in 4-byte chunks
    for i in range(0, len(text)-16, 4):
        addr = text_va + i
        try:
            insns = list(md.disasm(text[i:i+16], addr))
        except:
            continue
        if len(insns) >= 4:
            if (insns[0].mnemonic == 'adrp' 
                and insns[1].mnemonic == 'add'
                and 'ldr' in insns[2].mnemonic 
                and '#0x538' in insns[2].op_str
                and insns[3].mnemonic == 'br'):
                # calculate string address
                adrp_page = insns[0].operands[1].imm  # target page
                add_off = insns[1].operands[2].imm  # offset
                str_va = adrp_page + add_off
                s = read_cstring(str_va)
                if s:
                    print(f"  @ 0x{addr:x} => {s!r}")
                    found += 1
                    if found > 20: break

# 4) Extract all readable strings from libclient.so's .rodata
print(f"\n═══ Notable .rodata strings ═══")
rodata_off = None
rodata_size = 0
for sect in b.sections:
    if sect.name == '.rodata':
        rodata_off = sect.file_offset
        rodata_size = sect.size
        rodata_va = sect.virtual_address
        break

if rodata_off:
    data = raw[rodata_off:rodata_off+rodata_size]
    strings = []
    cur = b''
    start = 0
    for i, ch in enumerate(data):
        if 32 <= ch <= 126:
            if not cur:
                start = i
            cur += bytes([ch])
        else:
            if len(cur) >= 5:
                strings.append((rodata_va + start, cur.decode('ascii')))
            cur = b''
    print(f"  Total >=5 char ASCII strings in .rodata: {len(strings)}")
    # Filter interesting
    interesting = []
    keywords = ['http', 'firebase', 'google', 'server', 'download', 'sock', 'bypass', 'anogs', 'load', 'exec', 'system', 'shell', 'root', 'ptrace', 'proc/', 'data/', 'sdcard', 'ready', '/tmp/', 'inject', '.so', 'debug', 'trace', 'hide', 'client', 'com.', 'connect', 'admin']
    for va, s in strings:
        sl = s.lower()
        if any(k in sl for k in keywords):
            interesting.append((va, s))
    print(f"  Interesting: {len(interesting)}")
    for va, s in interesting[:100]:
        print(f"    0x{va:08x}  {s!r}")
