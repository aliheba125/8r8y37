#!/usr/bin/env python3
"""Sweep EVERY LSParanoid ID across ALL smali, decrypt, and flag anything
sensitive (URLs, IPs, hosts, secrets) not already documented."""
import sys, re, os, hashlib, base64
sys.path.insert(0,'/projects/sandbox')
from lsparanoid_decrypt import get_string, parse_smali_chunks
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

chunks = parse_smali_chunks('/projects/sandbox/decompiled_apk/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali')
key = hashlib.sha256(b"Activity").digest(); iv=b"\x00"*16

def aes(s):
    try:
        ct=base64.b64decode(s)
        if len(ct)%16: return None
        return unpad(AES.new(key,AES.MODE_CBC,iv).decrypt(ct),16).decode('utf-8')
    except: return None

root='/projects/sandbox/decompiled_apk'
ids=set()
id_locations={}
for dp,_,fs in os.walk(root):
    for fn in fs:
        if not fn.endswith('.smali'): continue
        p=os.path.join(dp,fn)
        try: txt=open(p,errors='ignore').read()
        except: continue
        for m in re.finditer(r'(-?0x[0-9a-f]+)L', txt):
            hid=m.group(1)
            ids.add(hid)
            id_locations.setdefault(hid, fn)

print(f"Total unique LSParanoid IDs referenced across all smali: {len(ids)}")

decoded=[]
for hid in ids:
    v=int(hid,16)&0xffffffffffffffff
    if v>0x8000000000000000: v-=0x10000000000000000
    try:
        s=get_string(v,chunks)
    except: continue
    if not s or len(s)<3: continue
    decoded.append((hid,s))

# Flag sensitive
url_re=re.compile(r'https?://[^\s"]+')
ip_re=re.compile(r'\b(?:\d{1,3}\.){3}\d{1,3}\b')
host_re=re.compile(r'\b[a-z0-9-]+\.(com|net|org|io|me|dev|app|xyz|ru|co|gg|tv)\b', re.I)
sens_kw=['http','://','.com','.net','token','secret','password','passwd','api','key','auth','bearer',
         'firebase','telegram','t.me','discord','webhook','admin','root','/data/','/sdcard','/system',
         'AIza','ftp','ssh','smtp','.php','endpoint','server','host']

print("\n═══ SENSITIVE strings (URLs/hosts/IPs/secrets) ═══")
flagged=set()
for hid,s in sorted(decoded, key=lambda x:x[1]):
    low=s.lower()
    hit = url_re.search(s) or ip_re.search(s) or (host_re.search(s) and ' ' not in s) or any(k in low for k in ('token','secret','password','webhook','bearer','aiza','discord','://'))
    if hit and s not in flagged:
        flagged.add(s)
        # try AES too
        extra=""
        if re.fullmatch(r'[A-Za-z0-9+/]+={0,2}',s) and s.endswith('='):
            d=aes(s)
            if d: extra=f"  ==AES==> {d!r}"
        print(f"  [{id_locations.get(hid,'?')}] {s!r}{extra}")

# also list ALL distinct http/host plaintext
print("\n═══ ALL distinct URLs/hosts in decrypted set ═══")
allhosts=set()
for hid,s in decoded:
    for m in url_re.findall(s): allhosts.add(m)
    for m in host_re.findall(s): pass
for h in sorted(allhosts):
    print(f"  {h}")
print(f"\n(total decrypted meaningful strings: {len(decoded)})")
