#!/usr/bin/env python3
"""
Deobfuscate LSParanoid strings from Zero_Loader APK
"""
import struct
import ctypes

def seed(x):
    x = x & 0xFFFFFFFF  # lower 32 bits
    z = ((x ^ (x >> 33)) * 7109453100751455733) & 0xFFFFFFFFFFFFFFFF
    return (((z ^ (z >> 28)) * ((-3808689974395783757) & 0xFFFFFFFFFFFFFFFF)) & 0xFFFFFFFFFFFFFFFF) >> 32

def rotl16(x, k):
    x = x & 0xFFFF
    return ((x << k) | (x >> (16 - k))) & 0xFFFF

def next_state(state):
    state = state & 0xFFFFFFFFFFFFFFFF
    s0 = state & 0xFFFF
    s1 = (state >> 16) & 0xFFFF
    
    # Convert to signed shorts for addition
    s0_s = ctypes.c_int16(s0).value
    s1_s = ctypes.c_int16(s1).value
    
    next_val = (s0_s + s1_s) & 0xFFFF
    s12 = (s1 ^ s0) & 0xFFFF
    
    rotl_next_9 = rotl16(next_val, 9)
    result = (rotl_next_9 + s0_s) & 0xFFFF
    
    rotl_s12_10 = rotl16(s12, 10)
    rotl_s0_13 = rotl16(s0, 13)
    
    part1 = (result << 16) | rotl_s12_10
    part2 = ((s12 << 5) & 0xFFFF) ^ ((rotl_s0_13 ^ s12) & 0xFFFF)
    
    return ((part1 << 16) | (part2 & 0xFFFF)) & 0xFFFFFFFFFFFFFFFF

MAX_CHUNK_LENGTH = 8191

def get_char_at(char_index, chunks, state):
    next_st = next_state(state)
    chunk = chunks[char_index // MAX_CHUNK_LENGTH]
    char_val = ord(chunk[char_index % MAX_CHUNK_LENGTH])
    return (char_val << 32) ^ next_st

def get_string(id_val, chunks):
    id_val = id_val & 0xFFFFFFFFFFFFFFFF  # ensure unsigned
    state = next_state(seed(id_val & 0xFFFFFFFF))
    low = (state >> 32) & 0xFFFF
    state2 = next_state(state)
    high = (state2 >> 16) & 0xFFFF0000
    index = int(((id_val >> 32) ^ low) ^ high) & 0xFFFFFFFF
    # Handle negative index (signed int)
    if index > 0x7FFFFFFF:
        index = index - 0x100000000
    
    state3 = get_char_at(index, chunks, state2)
    length = (state3 >> 32) & 0xFFFF
    
    chars = []
    for i in range(length):
        state3 = get_char_at(index + i + 1, chunks, state3)
        chars.append(chr((state3 >> 32) & 0xFFFF))
    
    return ''.join(chars)

def load_chunks_from_java(filepath):
    """Load chunks from the jadx-decompiled Java file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the chunks array initialization
    # The Java file has: private static final String[] chunks = {"...", "..."};
    start = content.find('chunks = {')
    if start < 0:
        start = content.find('chunks = new String[]{')
    if start < 0:
        print("Could not find chunks array")
        return None
    
    # Find the string literals
    chunks = []
    i = content.find('"', start)
    while i >= 0 and content[i-1:i+1] != '};':
        # Find end of this string
        j = i + 1
        while j < len(content):
            if content[j] == '"' and content[j-1] != '\\':
                break
            if content[j] == '\\' and j+1 < len(content):
                j += 1  # skip escaped char
            j += 1
        
        chunk_str = content[i+1:j]
        # Decode Java unicode escapes
        decoded = decode_java_unicode(chunk_str)
        chunks.append(decoded)
        
        # Find next string
        i = content.find('"', j + 1)
        if i >= 0 and content[i-1] == '}':
            break
    
    return chunks

def decode_java_unicode(s):
    """Decode Java-style unicode escapes like \\uXXXX"""
    result = []
    i = 0
    while i < len(s):
        if i + 5 < len(s) and s[i] == '\\' and s[i+1] == 'u':
            hex_str = s[i+2:i+6]
            try:
                result.append(chr(int(hex_str, 16)))
                i += 6
                continue
            except ValueError:
                pass
        result.append(s[i])
        i += 1
    return ''.join(result)

def load_chunks_from_smali(filepath):
    """Load chunks from smali file - the raw string data"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all const-string directives
    chunks = []
    lines = content.split('\n')
    for line in lines:
        line = line.strip()
        if 'const-string' in line and '"' in line:
            q1 = line.index('"')
            q2 = line.rindex('"')
            if q2 > q1:
                raw = line[q1+1:q2]
                decoded = decode_java_unicode(raw)
                chunks.append(decoded)
    
    return chunks if chunks else None

if __name__ == '__main__':
    import sys
    
    # Try loading from Java file first
    java_file = '/home/ubuntu/apk_analysis/jadx_output/sources/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.java'
    
    print("Loading chunks from Java file...")
    
    with open(java_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract the chunks - find the static block with the string array
    # Look for the pattern: chunks[0] = "..."; or chunks = {"...", "..."};
    # In this case it seems to be a single large string split into array
    
    # Find string between first { after "chunks" and last }
    idx = content.find('private static final String[] chunks')
    if idx < 0:
        idx = content.find('static final String[] chunks')
    if idx < 0:
        idx = content.find('chunks')
    
    print(f"Found 'chunks' at position: {idx}")
    
    # Extract the actual string data
    # The file format is: chunks = {"string1", "string2", ...};
    brace_start = content.find('{', idx)
    
    # Parse strings between quotes
    chunks = []
    i = content.find('"', brace_start)
    count = 0
    while i >= 0 and count < 10:
        j = i + 1
        depth = 0
        while j < len(content):
            if content[j] == '\\':
                j += 2
                continue
            if content[j] == '"':
                break
            j += 1
        
        raw_str = content[i+1:j]
        # Don't decode yet, just count
        count += 1
        print(f"  Chunk {count}: length={len(raw_str)} chars (first 50: {raw_str[:50]}...)")
        chunks.append(raw_str)
        
        i = content.find('"', j + 1)
        # Check if we hit the end of array
        between = content[j+1:i] if i > j+1 else ""
        if '}' in between and ',' not in between:
            break
    
    print(f"\nTotal chunks found: {len(chunks)}")
    
    # Now properly decode and try deobfuscation
    decoded_chunks = [decode_java_unicode(c) for c in chunks]
    total_chars = sum(len(c) for c in decoded_chunks)
    print(f"Total decoded characters: {total_chars}")
    
    # Test IDs
    test_ids = [
        (-15395268201307, "User.isPremium key"),
        (-5147476233051, "AES_MODE"),
        (-4541885844315, "Hash algorithm"),
        (-4602015386459, "AES key spec"),
        (-4735159372635, "Decrypt password"),
        (-946998217563, "Firebase ref GroupActivity"),
        (-826739133275, "FCM URL"),
        (-5297800088411, "Login Firebase ref"),
        (-9708731501403, "MainActivity Firebase ref"),
        (-14738138205019, "Root access found msg"),
        (-14793972779867, "No root msg"),
        (-11246329793371, "chmod command"),
        (-11323639204699, "bypass exec command"),
        (-13024446253915, "SplashActivity pref 1"),
        (-12676553902939, "SplashActivity pref 2"),
        (-12723798543195, "SplashActivity desc 1"),
        (-12921367038811, "SplashActivity desc 2"),
    ]
    
    print("\n=== Deobfuscated Strings ===")
    for id_val, desc in test_ids:
        try:
            result = get_string(id_val, decoded_chunks)
            print(f"  [{desc}] ID={id_val} => \"{result}\"")
        except Exception as e:
            print(f"  [{desc}] ID={id_val} => ERROR: {e}")
