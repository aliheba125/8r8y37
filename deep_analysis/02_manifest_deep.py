#!/usr/bin/env python3
"""Parse manifest.xml directly to get full component + intent filter info."""
from loguru import logger
logger.remove()
from androguard.core.apk import APK
from androguard.core.axml import AXMLPrinter

APK_PATH = '/projects/sandbox/Zero_LoaderV4.4.01_FINAL_SECURED.apk'
apk = APK(APK_PATH)

# Get manifest XML
manifest_xml = apk.get_android_manifest_xml()

print("═" * 80)
print("SECTION B — Full component analysis (from parsed XML)")
print("═" * 80)

# Extract activities with full attributes
def dump_component(tag_name):
    print(f"\n── <{tag_name}> ──")
    components = manifest_xml.findall(f".//{tag_name}")
    for c in components:
        attrs = dict(c.attrib)
        # Extract name from android namespace
        name = None
        for k in list(attrs.keys()):
            if k.endswith('}name') or k == 'name':
                name = attrs[k]
                break
        if not name:
            continue
        # Get common security attributes
        exported = None
        process = None
        permission = None
        enabled = None
        for k, v in attrs.items():
            if k.endswith('}exported'): exported = v
            elif k.endswith('}process'): process = v
            elif k.endswith('}permission'): permission = v
            elif k.endswith('}enabled'): enabled = v
        marker = ""
        if exported == 'true':
            marker = " [EXPORTED - PUBLIC]"
        print(f"  {name}{marker}")
        if process:
            print(f"      process: {process}")
        if permission:
            print(f"      permission: {permission}")
        if enabled == 'false':
            print(f"      DISABLED")
        # intent filters
        for f in c.findall('./intent-filter'):
            actions = [a.attrib.get('{http://schemas.android.com/apk/res/android}name', '?') 
                       for a in f.findall('./action')]
            cats = [a.attrib.get('{http://schemas.android.com/apk/res/android}name', '?') 
                    for a in f.findall('./category')]
            datas = []
            for d in f.findall('./data'):
                datas.append(str(dict(d.attrib)))
            if actions:
                print(f"      intent-filter: actions={actions}")
            if cats:
                print(f"                     categories={cats}")
            if datas:
                print(f"                     data={datas}")
        # meta-data
        for m in c.findall('./meta-data'):
            mn = m.attrib.get('{http://schemas.android.com/apk/res/android}name', '?')
            mv = m.attrib.get('{http://schemas.android.com/apk/res/android}value', '?')
            if len(mv) > 80:
                mv = mv[:80] + '...'
            print(f"      meta: {mn} = {mv}")

dump_component('activity')
dump_component('service')
dump_component('receiver')
dump_component('provider')

# Application-level meta-data (Firebase config etc)
print("\n── <application> meta-data (Firebase/config) ──")
app = manifest_xml.find('.//application')
if app is not None:
    for m in app.findall('./meta-data'):
        mn = m.attrib.get('{http://schemas.android.com/apk/res/android}name', '?')
        mv = m.attrib.get('{http://schemas.android.com/apk/res/android}value', '?')
        mr = m.attrib.get('{http://schemas.android.com/apk/res/android}resource', '?')
        if mv == '?' and mr != '?':
            print(f"  {mn}: resource={mr}")
        else:
            if len(mv) > 100:
                mv = mv[:100] + '...'
            print(f"  {mn} = {mv}")

# uses-native-library
print("\n── uses-native-library ──")
for u in manifest_xml.findall('.//uses-native-library'):
    print(f"  {dict(u.attrib)}")

# queries (Android 11+)
print("\n── <queries> (which other apps this queries via PackageManager) ──")
for q in manifest_xml.findall('.//queries'):
    for child in q:
        print(f"  {child.tag}: {dict(child.attrib)}")
