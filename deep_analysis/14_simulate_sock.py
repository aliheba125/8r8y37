#!/usr/bin/env python3
"""SIMULATION: I act as the game + libclient, test sock's real behavior.
Part A: Emulate sock's socket-send function (0x1bc8) with Unicorn to PROVE the
        wire protocol (capture exactly what bytes it writes to the socket fd).
Part B: Detectability model - as the game, can I detect sock's memory tampering?
"""
import lief, struct
from unicorn import *
from unicorn.arm64_const import *

LIB='/projects/sandbox/decompiled_apk/assets/servernrot/sock'
b=lief.parse(LIB); raw=open(LIB,'rb').read()

# PLT resolution
reloc={}
for r in b.pltgot_relocations:
    if hasattr(r,'address') and r.symbol: reloc[r.address]=r.symbol.name
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM
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
                    ai=int(ins[0].op_str.split('#')[1].rstrip(']'),16); lo=0
                    for x in ins[1:]:
                        if x.mnemonic=='ldr' and '#' in x.op_str: lo=int(x.op_str.split('#')[-1].rstrip(']'),16);break
                    if ai+lo in reloc: plt[pa]=reloc[ai+lo]
                except: pass
write_plt=[a for a,n in plt.items() if n=='write']

print("="*68)
print("الجزء أ: محاكاة دالة الإرسال في sock (Unicorn) — إثبات البروتوكول")
print("="*68)

MAP=0x0; SZ=0x40000; STK=0x30000000; SST=0x40000
DATA=0x20000000  # our fake payload buffer

def emulate_send(payload):
    uc=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
    uc.mem_map(MAP,SZ)
    for s in b.segments:
        if s.type.name=='LOAD':
            c=bytes(s.content)
            if c: uc.mem_write(MAP+s.virtual_address,c)
    uc.mem_map(STK,SST)
    uc.mem_map(DATA,0x4000)
    TLS=0x50000000; uc.mem_map(TLS,0x4000); uc.reg_write(UC_ARM64_REG_TPIDR_EL0,TLS)
    # set socket fd global (0x1a2c4) to a fake fd=7
    uc.mem_write(0x1a2c4, struct.pack('<i',7))
    uc.mem_write(DATA, payload)
    captured=[]
    def hook(uc,addr,size,ud):
        if addr in write_plt:
            fd=uc.reg_read(UC_ARM64_REG_X0)
            buf=uc.reg_read(UC_ARM64_REG_X1)
            n=uc.reg_read(UC_ARM64_REG_X2)
            data=uc.mem_read(buf,n)
            captured.append((fd,bytes(data)))
            # return n (full write)
            uc.reg_write(UC_ARM64_REG_X0,n)
            uc.reg_write(UC_ARM64_REG_PC, uc.reg_read(UC_ARM64_REG_LR))
    uc.hook_add(UC_HOOK_CODE,hook)
    uc.reg_write(UC_ARM64_REG_X0,DATA)          # buf
    uc.reg_write(UC_ARM64_REG_X1,len(payload))  # len
    uc.reg_write(UC_ARM64_REG_SP,STK+SST-0x400)
    uc.reg_write(UC_ARM64_REG_LR,0xdeadbeef)
    try: uc.emu_start(MAP+0x1bc8,0xdeadbeef,count=5000)
    except UcError as e: pass
    return captured

payload=b'ESP_DATA_XYZ'  # نتظاهر أن sock يرسل بيانات ESP
caps=emulate_send(payload)
print(f"  أرسلنا payload={payload!r} (طول {len(payload)})")
print(f"  ما كتبه sock على السوكت (fd, bytes):")
for fd,data in caps:
    print(f"    write(fd={fd}, {data.hex()}  = {data!r})")
if len(caps)>=2:
    hdr=caps[0][1]
    length=struct.unpack('>I',hdr)[0] if len(hdr)==4 else None
    print(f"\n  ✅ البروتوكول مُثبت: رأس طول 4 بايت big-endian = {length}, ثم الحمولة")
    print(f"     (نفس بروتوكول libclient الخادم — كل رسالة: [4B BE len][payload])")

print()
print("="*68)
print("الجزء ب: أنا العبة — هل أكتشف تلاعب sock بذاكرتي بسهولة؟")
print("="*68)
# نموذج قائم على آلية sock المُثبتة بالتفكيك (open /proc/mem, write)
detections = [
 ("عملية باسم 'sock' بنفس UID",
  "sock لا يعيد تسمية نفسه (لا prctl/PR_SET_NAME في الثنائي) → أراه في /proc/*/cmdline",
  "سهل جداً"),
 ("واصف ملف مفتوح على /proc/<pid_العبة>/mem من عملية أخرى",
  "sock يفتح /proc/mem الخاص بي؛ أفحص /proc/*/fd فأجد من يمسك ذاكرتي",
  "سهل جداً"),
 ("تغيّر بايتات ذاكرتي (سلامة الذاكرة)",
  "sock يكتب عبر write(/proc/mem) → checksum على كودي/بياناتي يفشل",
  "سهل (لو العبة تفحص سلامتها)"),
 ("libclient.so داخل خرائطي (وضع بدون روت/VirtualApp)",
  "في الـ sandbox، libclient محمّلة بعمليتي → أراها في /proc/self/maps",
  "سهل جداً"),
 ("سوكت Unix في مجلد files",
  "sock/libclient ينشئان سوكت بمسار معروف → أفحص المجلد",
  "متوسط"),
]
print(f"{'ما أفحصه كعبة':45s} | {'السهولة'}")
print("-"*68)
for what,how,ease in detections:
    print(f"  • {what}")
    print(f"      كيف: {how}")
    print(f"      الكشف: {ease}\n")

print("="*68)
print("دفاعات sock الذاتية (هل يخفي/يحمي نفسه؟)")
print("="*68)
defenses = {
 "إعادة تسمية العملية (prctl PR_SET_NAME)":"❌ غير موجود",
 "حذف/إخفاء الثنائي (unlink/memfd)":"❌ غير موجود",
 "مضاد تصحيح (ptrace/TracerPid)":"❌ غير موجود",
 "تشفير/إخفاء مسار السوكت":"❌ مسار ثابت",
 "إخفاء من /proc/self/maps":"❌ غير موجود (hideXposed ميت)",
 "علامة مائية دعائية":"⚠️ ' TO BUY :- @ZxANUBIS ' مضمّنة",
}
for k,v in defenses.items():
    print(f"  {v}   {k}")
print("\n  الخلاصة: sock لا يخفي نفسه إطلاقاً ولا يضع أي دفاع.")
