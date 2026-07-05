#!/usr/bin/env python3
"""Deep native library analysis with LIEF - full symbols, imports, sections, TLS."""
import lief, os, zipfile, hashlib
from collections import defaultdict

BINS = {
    'libclient.so':  '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libclient.so',
    'libTcore.so':   '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libTcore.so',
    'libpine.so':    '/projects/sandbox/decompiled_apk/lib/arm64-v8a/libpine.so',
    'sock':          '/projects/sandbox/decompiled_apk/assets/servernrot/sock',
    'bypass':        '/projects/sandbox/decompiled_apk/assets/servernrot/bypass',
    'libpubgm.so':   '/projects/sandbox/decompiled_apk/assets/servernrot/loader/libpubgm.so',
    'sock64':        '/projects/sandbox/decompiled_apk/assets/sock64',
    'raw_bypass':    '/projects/sandbox/decompiled_apk/res/raw/bypass',
}

for name, path in BINS.items():
    if not os.path.exists(path):
        print(f"MISSING: {name}")
        continue
    size = os.path.getsize(path)
    md5 = hashlib.md5(open(path,'rb').read()).hexdigest()
    print("═" * 80)
    print(f"BINARY: {name}   ({size} bytes, MD5 {md5})")
    print("═" * 80)
    b = lief.parse(path)
    if b is None:
        print(f"  Cannot parse (not ELF?)")
        continue
    
    # Header
    print(f"  Machine: {b.header.machine_type.name}")
    print(f"  Type: {b.header.file_type.name}")
    print(f"  Entry: 0x{b.header.entrypoint:x}")
    
    # Segments
    print("  Segments:")
    for s in b.segments:
        if s.type.name in ('LOAD','DYNAMIC','GNU_STACK','TLS','INTERP','GNU_RELRO'):
            print(f"    {s.type.name:<15} vaddr=0x{s.virtual_address:08x} size=0x{s.virtual_size:x} flags={s.flags}")
    
    # Imported libraries
    print("  NEEDED (imports):")
    for lib in b.libraries:
        print(f"    {lib}")
    
    # SONAME
    try:
        for e in b.dynamic_entries:
            if e.tag.name == 'SONAME':
                print(f"  SONAME: {e.name}")
    except:
        pass
    
    # Java_* JNI exports  
    java_exports = [s for s in b.exported_symbols if s.name.startswith('Java_')]
    print(f"  JNI Java_* exports: {len(java_exports)}")
    for s in sorted(java_exports, key=lambda x: x.name):
        print(f"    {s.name}  @ 0x{s.value:x}")
    
    # JNI_OnLoad?
    onload = [s for s in b.exported_symbols if s.name in ('JNI_OnLoad','JNI_OnUnload')]
    if onload:
        print("  JNI_OnLoad:")
        for s in onload:
            print(f"    {s.name}  @ 0x{s.value:x}")
    
    # All other C++ exports (likely internal)
    other_exports = [s for s in b.exported_symbols 
                     if not s.name.startswith('Java_') 
                     and s.name not in ('JNI_OnLoad','JNI_OnUnload')
                     and s.name not in ('_init','_fini','__bss_start','_edata','_end')]
    print(f"  Other exports: {len(other_exports)}")
    if len(other_exports) < 40:  # only print if small
        for s in sorted(other_exports, key=lambda x: x.name)[:30]:
            print(f"    {s.name}")
    else:
        # Show suspicious ones only
        suspicious_names = ('hook','inject','hide','ptrace','dlopen','dlsym','fork','execve','sock','http','curl','ssl','encrypt','decrypt','backdoor','shell','proc','maps','ANOGS','anogs','xposed','magisk','frida','pine','substrate')
        susp = [s for s in other_exports if any(k in s.name.lower() for k in suspicious_names)]
        print(f"  Suspicious exports: {len(susp)}")
        for s in sorted(susp, key=lambda x: x.name)[:50]:
            print(f"    {s.name}")
    
    # Critical imports (dangerous system calls)
    print("  Critical imports:")
    critical = ('dlopen','dlsym','system','execve','execv','execl','fork','ptrace','mmap','mprotect','memfd_create','__system_property_get','pthread_create','popen','socket','connect','bind','sendto','recvfrom','open','openat')
    for s in b.imported_symbols:
        if s.name in critical:
            print(f"    {s.name}")
    
    print()
