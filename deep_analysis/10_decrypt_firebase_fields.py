#!/usr/bin/env python3
"""Decrypt the full Firebase license DB structure.
Two layers: LSParanoid (dex string obfuscation) -> AES-256-CBC (field names).
Key = SHA256("Activity"), IV = 16 zero bytes, AES/CBC/PKCS7.
"""
import sys, re, hashlib, base64
sys.path.insert(0,'/projects/sandbox')
from lsparanoid_decrypt import get_string, parse_smali_chunks
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

chunks = parse_smali_chunks('/projects/sandbox/decompiled_apk/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali')
key = hashlib.sha256(b"Activity").digest()
iv  = b"\x00"*16

def lspara(hid):
    v = int(hid,16) & 0xffffffffffffffff
    if v > 0x8000000000000000: v -= 0x10000000000000000
    try: return get_string(v, chunks)
    except: return None

def aes_dec(b64):
    try:
        ct = base64.b64decode(b64)
        if len(ct) % 16 != 0: return None
        pt = AES.new(key, AES.MODE_CBC, iv).decrypt(ct)
        return unpad(pt,16).decode('utf-8')
    except: return None

FILES = [
    'smali_classes3/com/pubgm/activity/LoginActivity.smali',
    'smali_classes3/com/pubgm/activity/LoginActivity$1.smali',
    'smali_classes3/com/pubgm/activity/LoginActivity$AESCrypt.smali',
]
base = '/projects/sandbox/decompiled_apk/'

seen = set()
results = []
for f in FILES:
    try: txt = open(base+f).read()
    except: continue
    for m in re.finditer(r'const-wide [vp]\d+, (-?0x[0-9a-f]+)L', txt):
        hid = m.group(1)
        if hid in seen: continue
        seen.add(hid)
        s = lspara(hid)
        if s is None: continue
        entry = {'id':hid, 'lspara':s}
        # if looks like base64 (AES ciphertext), try AES decrypt
        if re.fullmatch(r'[A-Za-z0-9+/]+={0,2}', s) and len(s) >= 12 and s.endswith('='):
            dec = aes_dec(s)
            if dec: entry['aes'] = dec
        results.append((f, entry))

print("═"*72)
print("FIREBASE LICENSE DB — full decrypted string map (LSParanoid + AES)")
print("═"*72)
cur=None
for f,e in results:
    if f!=cur:
        print(f"\n### {f.split('/')[-1]}")
        cur=f
    if 'aes' in e:
        print(f"  {e['id']}: LSPara={e['lspara']!r}  ==AES==>  {e['aes']!r}   ★FIELD")
    else:
        # only print interesting plaintext (skip pure noise)
        s=e['lspara']
        if len(s)>=2:
            print(f"  {e['id']}: {s!r}")
