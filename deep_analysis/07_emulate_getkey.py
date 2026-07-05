#!/usr/bin/env python3
"""Emulate GetKey/Yellow/Telegram with Unicorn to extract runtime-decrypted strings.
Handles PLT stubs (__cxa_guard_*, atexit, close, exit) by intercepting them.
"""
import lief
from unicorn import *
from unicorn.arm64_const import *

LIB = '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libclient.so'
b = lief.parse(LIB)

BASE = 0x0
MAP_SIZE = 0x80000
JNIENV_PTR   = 0x10000000
JNITABLE     = 0x10001000
NEWSTRING_FN = 0x20000000
STACK        = 0x30000000
STACK_SIZE   = 0x20000

# PLT stub addresses -> behavior
PLT = {
    0x49470: 'guard_acquire',   # return 1
    0x49480: 'guard_release',   # return
    0x49450: 'atexit',          # return 0
    0x494d0: 'close',           # return 0
    0x49490: 'exit',            # stop
}

def emulate(func_va, name):
    uc = Uc(UC_ARCH_ARM64, UC_MODE_ARM)
    uc.mem_map(BASE, MAP_SIZE)
    for s in b.segments:
        if s.type.name == 'LOAD':
            content = bytes(s.content)
            if content:
                uc.mem_write(BASE + s.virtual_address, content)
    uc.mem_map(JNIENV_PTR & ~0xFFF, 0x2000)
    uc.mem_map(NEWSTRING_FN & ~0xFFF, 0x1000)
    uc.mem_map(STACK, STACK_SIZE)
    uc.mem_write(JNIENV_PTR, (JNITABLE).to_bytes(8, 'little'))
    uc.mem_write(JNITABLE + 0x538, (NEWSTRING_FN).to_bytes(8, 'little'))
    # fill NEWSTRING page with RET (0xd65f03c0) so if reached, no crash
    uc.mem_write(NEWSTRING_FN, b'\xc0\x03\x5f\xd6' * 4)

    cap = {}

    def hook_code(uc, address, size, ud):
        if address == NEWSTRING_FN:
            x1 = uc.reg_read(UC_ARM64_REG_X1)
            data = b''
            try:
                for i in range(256):
                    ch = uc.mem_read(x1 + i, 1)
                    if ch == b'\x00': break
                    data += bytes(ch)
            except: pass
            cap['str'] = data; cap['x1'] = x1
            uc.emu_stop(); return
        if address in PLT:
            beh = PLT[address]
            lr = uc.reg_read(UC_ARM64_REG_LR)
            if beh == 'guard_acquire':
                uc.reg_write(UC_ARM64_REG_X0, 1)
            elif beh in ('atexit','close'):
                uc.reg_write(UC_ARM64_REG_X0, 0)
            elif beh == 'exit':
                cap['exit'] = True; uc.emu_stop(); return
            # return to caller
            uc.reg_write(UC_ARM64_REG_PC, lr)

    uc.hook_add(UC_HOOK_CODE, hook_code)
    uc.reg_write(UC_ARM64_REG_X0, JNIENV_PTR)
    uc.reg_write(UC_ARM64_REG_X1, JNIENV_PTR + 0x100)
    uc.reg_write(UC_ARM64_REG_SP, STACK + STACK_SIZE - 0x200)
    uc.reg_write(UC_ARM64_REG_LR, 0xdeadbeef)
    try:
        uc.emu_start(BASE + func_va, 0xdeadbeef, count=5000)
    except UcError as e:
        if 'str' not in cap and 'exit' not in cap:
            cap['error'] = str(e)
            cap['pc'] = uc.reg_read(UC_ARM64_REG_PC)
    return cap

TARGETS = [
    (0x1ef54, 'LoginActivity.GetKey'),
    (0x1f068, 'MainActivity.GetKey'),
    (0x1f17c, 'LoginActivity.Yellow'),
    (0x230dc, 'HomeFragment.Telegram'),
]

print("═"*70)
print("EMULATION — runtime-decrypted strings (Unicorn ARM64)")
print("═"*70)
for va, name in TARGETS:
    r = emulate(va, name)
    print(f"\n{name} @ 0x{va:x}")
    if 'str' in r:
        try: dec = r['str'].decode('utf-8')
        except: dec = repr(r['str'])
        print(f"  → NewStringUTF(\"{dec}\")")
        print(f"    hex: {r['str'].hex()}")
    elif r.get('exit'):
        print(f"  → calls exit() [kill-trap confirmed]")
    else:
        print(f"  → error={r.get('error')} @ pc=0x{r.get('pc',0):x}")
