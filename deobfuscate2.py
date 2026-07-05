#!/usr/bin/env python3
"""
Deobfuscate LSParanoid strings from Zero_Loader APK - Fixed version
"""
import re
import ctypes

def seed(x):
    x = x & 0xFFFFFFFF
    z = (((x ^ (x >> 33)) & 0xFFFFFFFFFFFFFFFF) * 7109453100751455733) & 0xFFFFFFFFFFFFFFFF
    return ((((z ^ (z >> 28)) & 0xFFFFFFFFFFFFFFFF) * ((-3808689974395783757) & 0xFFFFFFFFFFFFFFFF)) & 0xFFFFFFFFFFFFFFFF) >> 32

def rotl16(x, k):
    x = x & 0xFFFF
    return ((x << k) | (x >> (16 - k))) & 0xFFFF

def next_state(state):
    state = state & 0xFFFFFFFFFFFFFFFF
    s0 = state & 0xFFFF
    s1 = (state >> 16) & 0xFFFF
    
    s0_s = ctypes.c_int16(s0).value
    s1_s = ctypes.c_int16(s1).value
    
    next_val = (s0_s + s1_s) & 0xFFFF
    s12 = (s1 ^ s0) & 0xFFFF
    
    rotl_next_9 = rotl16(next_val, 9)
    result_s = ctypes.c_int16((rotl_next_9 + s0_s) & 0xFFFF).value
    result = result_s & 0xFFFF
    
    rotl_s12_10 = rotl16(s12, 10)
    rotl_s0_13 = rotl16(s0, 13)
    
    part_high = ((result << 16) | rotl_s12_10) & 0xFFFFFFFF
    part_low = (((s12 << 5) & 0xFFFF) ^ ((rotl_s0_13 ^ s12) & 0xFFFF)) & 0xFFFF
    
    return ((part_high << 16) | part_low) & 0xFFFFFFFFFFFFFFFF

MAX_CHUNK_LENGTH = 8191

def get_char_at(char_index, chunks, state):
    next_st = next_state(state)
    chunk_idx = char_index // MAX_CHUNK_LENGTH
    char_idx = char_index % MAX_CHUNK_LENGTH
    if chunk_idx >= len(chunks):
        raise IndexError(f"chunk_idx={chunk_idx} >= len(chunks)={len(chunks)}, char_index={char_index}")
    chunk = chunks[chunk_idx]
    if char_idx >= len(chunk):
        raise IndexError(f"char_idx={char_idx} >= len(chunk)={len(chunk)}")
    char_val = ord(chunk[char_idx])
    return ((char_val & 0xFFFFFFFF) << 32) ^ next_st

def get_string(id_val, chunks):
    # Handle negative IDs (Java long)
    if id_val < 0:
        id_val = id_val & 0xFFFFFFFFFFFFFFFF
    
    state = next_state(seed(id_val & 0xFFFFFFFF))
    low = (state >> 32) & 0xFFFF
    state2 = next_state(state)
    high = (state2 >> 16) & 0xFFFF0000
    
    raw_index = ((id_val >> 32) ^ low) ^ high
    # Convert to signed 32-bit int
    index = ctypes.c_int32(raw_index & 0xFFFFFFFF).value
    
    if index < 0:
        raise ValueError(f"Negative index: {index}")
    
    state3 = get_char_at(index, chunks, state2)
    length = int((state3 >> 32) & 0xFFFF)
    
    if length > 1000:
        raise ValueError(f"Unreasonable length: {length}")
    
    chars = []
    for i in range(length):
        state3 = get_char_at(index + i + 1, chunks, state3)
        c = (state3 >> 32) & 0xFFFF
        chars.append(chr(c))
    
    return ''.join(chars)

def load_chunks():
    """Load chunks from smali file"""
    with open('decoded/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the const-string
    match = re.search(r'const-string v2, "(.+?)"', content, re.DOTALL)
    if not match:
        raise Exception("Could not find const-string")
    
    raw = match.group(1)
    # Decode unicode escapes
    decoded = raw.encode('utf-8').decode('unicode_escape')
    
    print(f"Loaded chunk: {len(decoded)} characters")
    
    # It's a single chunk (array size = 1)
    return [decoded]

if __name__ == '__main__':
    chunks = load_chunks()
    
    # Test IDs from the code
    test_ids = [
        (-15395268201307, "User.isPremium key"),
        (-5147476233051, "AES_MODE"),
        (-4541885844315, "Hash algorithm (MessageDigest)"),
        (-4602015386459, "SecretKeySpec algorithm"),
        (-4735159372635, "AES decrypt password/key"),
        (-4619195255643, "Charset for encrypt"),
        (-4773814078299, "Charset for decrypt"),
        (-946998217563, "Firebase ref (GroupActivity users)"),
        (-972768021339, "Firebase ref (GroupActivity messages)"),
        (-826739133275, "FCM base URL"),
        (-5297800088411, "Login Firebase ref"),
        (-6869758118747, "Login Firebase ref 2"),
        (-7252010208091, "Login Firebase ref 3"),
        (-5607037733723, "Login Firebase ref 4"),
        (-9708731501403, "MainActivity Firebase ref"),
        (-14738138205019, "Root access found msg"),
        (-14793972779867, "No root msg"),
        (-11246329793371, "chmod/exec command prefix"),
        (-11323639204699, "bypass exec command prefix"),
        (-13024446253915, "SplashActivity pref bool 1"),
        (-13071690894171, "SplashActivity pref int"),
        (-13136115403611, "SplashActivity pref bool 2"),
        (-12977201613659, "SplashActivity pref bool 3"),
        (-12676553902939, "SplashActivity condition check"),
        (-12723798543195, "SplashActivity desc text 1"),
        (-12921367038811, "SplashActivity desc text 2"),
        (-14866987223899, "doExe log msg"),
        (-14901346962267, "chmod prefix"),
        (-14931411733339, "chmod space"),
        (-19539911641947, "FirebaseIdService ref"),
        (-22679532735323, "ActivityCompat Firebase ref 1"),
        (-24736822070107, "ActivityCompat Firebase ref 2"),
        (-21189179083611, "restartApp extra key"),
        (-770904558427, "GroupActivity dialog title"),
        (-1226171091803, "GroupActivity pref key"),
        (-1264825797467, "GroupActivity pref default"),
        (-1174631484251, "GroupActivity Firebase ref 3"),
        (-26098326702939, "NetworkConnection service name"),
        (-26029607226203, "NetworkConnection toast msg"),
    ]
    
    print("\n=== Deobfuscated Strings ===\n")
    success = 0
    for id_val, desc in test_ids:
        try:
            result = get_string(id_val, chunks)
            print(f"  [{desc}]")
            print(f"    ID={id_val} => \"{result}\"")
            print()
            success += 1
        except Exception as e:
            print(f"  [{desc}]")
            print(f"    ID={id_val} => ERROR: {e}")
            print()
    
    print(f"\n=== Results: {success}/{len(test_ids)} decoded successfully ===")
