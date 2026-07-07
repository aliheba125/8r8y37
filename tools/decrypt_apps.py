#!/usr/bin/env python3
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import lsparanoid_decrypt as L

CHUNK = "/projects/sandbox/decompiled/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali"
chunks = L.parse_smali_chunks(CHUNK)
print(f"Loaded {len(chunks)} chunk(s)", file=sys.stderr)

targets = {
    "line64  clinit lib name":            -0xb807d7e0b5b,
    "line1649 Lambda(1649)":              -0xb167d7e0b5b,
    "line1672 Lambda(1672)":              -0xb027d7e0b5b,
    "line2094 Lambda(2094)":              -0xb4f7d7e0b5b,
    "line2117 Lambda(2117)":              -0xb437d7e0b5b,
    "line2158 (2158)":                    -0xb2a7d7e0b5b,
    "line2164 (2164)":                    -0xb327d7e0b5b,
    "line2266 (2266)":                    -0xb5b7d7e0b5b,
}
for label, id_ in targets.items():
    try:
        s = L.get_string(id_, chunks)
        print(f"{hex(id_ & L.MASK64):<20} {repr(s):<45} {label}")
    except Exception as e:
        print(f"{hex(id_ & L.MASK64):<20} ERROR {type(e).__name__}: {e}   {label}")
