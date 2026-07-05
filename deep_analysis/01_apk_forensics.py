#!/usr/bin/env python3
"""Full APK forensics using androguard - real parsed manifest, not string grep."""
from androguard.core.apk import APK
import json, os, hashlib

APK_PATH = '/projects/sandbox/Zero_LoaderV4.4.01_FINAL_SECURED.apk'
apk = APK(APK_PATH)

print("═" * 80)
print("SECTION A — APK METADATA (via androguard, ground truth)")
print("═" * 80)
print(f"Package:              {apk.get_package()}")
print(f"Version name:         {apk.get_androidversion_name()}")
print(f"Version code:         {apk.get_androidversion_code()}")
print(f"Min SDK:              {apk.get_min_sdk_version()}")
print(f"Target SDK:           {apk.get_target_sdk_version()}")
print(f"Effective target SDK: {apk.get_effective_target_sdk_version()}")
print(f"Main activity:        {apk.get_main_activity()}")
print(f"App name:             {apk.get_app_name()}")
print(f"Debuggable:           {apk.get_attribute_value('application', 'debuggable')}")
print(f"Allow backup:         {apk.get_attribute_value('application', 'allowBackup')}")
print(f"Network security:     {apk.get_attribute_value('application', 'networkSecurityConfig')}")
print(f"Extract native libs:  {apk.get_attribute_value('application', 'extractNativeLibs')}")
print(f"Uses cleartext:       {apk.get_attribute_value('application', 'usesCleartextTraffic')}")

print("\n── PERMISSIONS (declared) ──")
for p in sorted(apk.get_permissions()):
    print(f"  {p}")

print("\n── ACTIVITIES ──")
for a in apk.get_activities():
    exported = apk.get_element('activity', 'exported', name=a)
    print(f"  {a}  exported={exported}")

print("\n── SERVICES ──")
for s in apk.get_services():
    exported = apk.get_element('service', 'exported', name=s)
    process = apk.get_element('service', 'process', name=s)
    print(f"  {s}  exported={exported}  process={process}")

print("\n── RECEIVERS ──")
for r in apk.get_receivers():
    exported = apk.get_element('receiver', 'exported', name=r)
    print(f"  {r}  exported={exported}")

print("\n── PROVIDERS ──")
for p in apk.get_providers():
    exported = apk.get_element('provider', 'exported', name=p)
    print(f"  {p}  exported={exported}")

print("\n── INTENT FILTERS (all main activity + services) ──")
for a in apk.get_activities():
    filters = apk.get_intent_filters('activity', a)
    if filters:
        print(f"  {a}:")
        for k,v in filters.items():
            print(f"    {k}: {v}")

print("\n── SIGNATURE INFO ──")
print(f"  Signed V1: {apk.is_signed_v1()}")
print(f"  Signed V2: {apk.is_signed_v2()}")
print(f"  Signed V3: {apk.is_signed_v3()}")
certs = apk.get_certificates_der_v2() or apk.get_certificates_der_v3() or []
for c in certs[:2]:
    sha256 = hashlib.sha256(c).hexdigest()
    print(f"  Cert SHA256: {sha256}")

print("\n── ALL FILES IN APK (sorted by size) ──")
files_by_size = []
for f in apk.get_files():
    try:
        data = apk.get_file(f)
        files_by_size.append((len(data), f))
    except:
        pass
files_by_size.sort(reverse=True)
print(f"  Total files: {len(files_by_size)}")
print(f"  Top 30 largest:")
for size, name in files_by_size[:30]:
    print(f"    {size:>10d}  {name}")

print("\n── SUSPICIOUS FILES (executables, unknown types) ──")
suspicious = []
for f in apk.get_files():
    if f.startswith('assets/') or f.startswith('res/raw/'):
        data = apk.get_file(f)
        if len(data) < 8:
            continue
        magic = data[:4]
        if magic == b'\x7fELF':
            suspicious.append((f, len(data), 'ELF binary'))
        elif magic[:2] == b'PK':
            suspicious.append((f, len(data), 'ZIP archive'))
        elif magic == b'dex\n':
            suspicious.append((f, len(data), 'DEX'))

for name, size, kind in suspicious:
    print(f"  {size:>10d}  {kind:<15}  {name}")
