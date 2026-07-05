#!/usr/bin/env python3
"""
LSParanoid Decryptor - EXACT replica of the smali bytecode.
Based on:
- org/lsposed/lsparanoid/DeobfuscatorHelper.smali
- org/lsposed/lsparanoid/RandomHelper.smali
- org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali

All operations mirror Java semantics (signed int/short overflow, arithmetic shifts).
"""
import re
import sys

MAX_CHUNK_LENGTH = 0x1fff  # 8191

MASK32 = 0xFFFFFFFF
MASK64 = 0xFFFFFFFFFFFFFFFF
MASK16 = 0xFFFF


def to_short(x):
    """Convert int to signed 16-bit short (Java int-to-short semantics)."""
    x = x & 0xFFFF
    if x & 0x8000:
        x -= 0x10000
    return x


def to_int(x):
    """Convert long to signed 32-bit int."""
    x = x & MASK32
    if x & 0x80000000:
        x -= 0x100000000
    return x


def to_long(x):
    """Simulate a signed 64-bit long."""
    x = x & MASK64
    if x & 0x8000000000000000:
        x -= 0x10000000000000000
    return x


def urshift64(x, n):
    """Unsigned right shift for 64-bit long."""
    return (x & MASK64) >> n


def urshift32(x, n):
    """Unsigned right shift for 32-bit int."""
    return (x & MASK32) >> n


def rotl_short(x, k):
    """
    RandomHelper.rotl(short x, int k) — smali:
        shl-int v0, p0, p1          # v0 = x << k (int)
        rsub-int/lit8 v1, p1, 0x20  # v1 = 32 - k
        ushr-int v1, p0, v1         # v1 = x >>> (32 - k) (unsigned int)
        or-int/2addr v0, v1
        int-to-short v0, v0
    Note: p0 is short but gets treated as int in operations.
    """
    # In Java: x is short, but in shl-int/ushr-int it's promoted to int.
    # If x is negative short, promoting to int sign-extends.
    # For ushr, we need to treat as UNSIGNED 32-bit int.
    x_as_int = x & MASK32  # sign-extended int if x is negative
    # But smali stores short as int and shl-int uses full int.
    # Java `short x` in arithmetic gets sign-extended to int.
    # We already have x as Python int (possibly negative).
    # For shl-int we can compute: (x << k) & MASK32
    # For ushr-int we compute: (x_as_int) >> (32-k) where x_as_int is unsigned.
    # But if x is a NEGATIVE short (e.g. -1 = 0xFFFF), sign-extended to int is 0xFFFFFFFF.
    if x < 0:
        x_int = (x + 0x100000000) & MASK32  # sign-extended int
    else:
        x_int = x & MASK32

    shifted_left = (x_int << k) & MASK32
    shifted_right = x_int >> (32 - k)  # Python's >> on unsigned int works
    combined = (shifted_left | shifted_right) & MASK32
    return to_short(combined)


def rand_next(state):
    """
    RandomHelper.next(long state) — smali trace:
    
    v2 = short(state & 0xFFFF)          # s0
    v0 = short((state >>> 16) & 0xFFFF) # s1
    v1 = v2                             # next = s0
    v1 = short(v1 + v0)                 # next = short(s0 + s1)
    v1 = rotl(v1, 9)                    # next = rotl(next, 9)
    v1 = short(v1 + v2)                 # next = short(next + s0)  
    
    v0 = short(v0 ^ v2)                 # s1' = s1 ^ s0
    v2 = rotl(v2, 13)                   # s0'' = rotl(s0, 13)
    v2 = short(v2 ^ v0)                 # s0'' = s0'' ^ s1'
    v4 = v0 << 5 (int)                  # v4 = s1' << 5 (as int)
    v4 = v4 ^ v2                        # v4 = (s1'<<5) ^ (rotl(s0,13) ^ s1')
    v2 = short(v4)                      # 
    v0 = rotl(v0, 10)                   # s1' = rotl(s1',10)
    
    # Build result: 
    v4 = (long) v1                      # v4 = (long) next
    v4 = v4 << 16                       # v4 = next << 16
    v6 = (long) v0                      # v6 = (long) rotl(s1',10)
    v4 = v4 | v6                        # v4 = (next<<16) | rotl(s1',10)
    v3 = v4 << 16                       # v3 = ((next<<16) | rotl(s1',10)) << 16
    v5 = (long) v2                      # v5 = (long) final xor
    v3 = v3 | v5
    return v3
    """
    s0 = to_short(state & MASK16)
    s1 = to_short((urshift64(state, 16)) & MASK16)

    next_val = to_short(s0 + s1)
    next_val = rotl_short(next_val, 9)
    next_val = to_short(next_val + s0)

    s1_new = to_short(s1 ^ s0)
    s0_rot13 = rotl_short(s0, 13)
    s0_after = to_short(s0_rot13 ^ s1_new)

    # v4 = (s1_new << 5) ^ s0_after   (all as int, then short)
    # Note: this uses the "int" shl (not short shl)
    if s1_new < 0:
        s1_new_int = (s1_new + 0x100000000) & MASK32
    else:
        s1_new_int = s1_new & MASK32
    v4_int = ((s1_new_int << 5) & MASK32) ^ (s0_after & MASK32 if s0_after >= 0 else (s0_after + 0x100000000) & MASK32)
    v2_short = to_short(v4_int)

    s1_rot10 = rotl_short(s1_new, 10)

    # Assemble result as unsigned 64-bit
    # v4 = (long)next_val << 16
    # The int-to-long sign-extends. If next_val is negative short, converted to long is negative.
    def s2u16(x):
        return x & MASK16

    def s2u64(x):
        return x & MASK64

    # int-to-long sign-extends, so we need to preserve signed value
    next_long = s2u64(next_val)  # store as unsigned bits
    s1r10_long = s2u64(s1_rot10)
    v2_long = s2u64(v2_short)

    v4 = ((next_long << 16) | s1r10_long) & MASK64
    v3 = ((v4 << 16) | v2_long) & MASK64
    return v3


def rand_seed(x):
    """
    seed(long x):
        z = ((x >>> 33) ^ x) * 0x62a9d9ed799705f5
        z2 = ((z >>> 28) ^ z) * -0x34db2f5a3773ca4d
        return z2 >>> 32
    """
    x = x & MASK64
    z = (urshift64(x, 33) ^ x) & MASK64
    z = (z * 0x62a9d9ed799705f5) & MASK64
    z2 = (urshift64(z, 28) ^ z) & MASK64
    # -0x34db2f5a3773ca4d as long
    mult = (-0x34db2f5a3773ca4d) & MASK64
    z2 = (z2 * mult) & MASK64
    return urshift64(z2, 32)


def get_char_at(char_index, chunks, state):
    """
    getCharAt(int charIndex, String[] chunks, long state):
        nextState = next(state)
        chunk = chunks[charIndex / MAX_CHUNK_LENGTH]
        c = chunk.charAt(charIndex % MAX_CHUNK_LENGTH)
        return (((long)c) << 32) ^ nextState
    """
    next_state = rand_next(state)
    chunk = chunks[char_index // MAX_CHUNK_LENGTH]
    c = ord(chunk[char_index % MAX_CHUNK_LENGTH])
    return ((c << 32) ^ next_state) & MASK64


def get_string(id_, chunks):
    """
    getString(long id, String[] chunks):
        state = next(seed(id & 0xFFFFFFFF))
        low = (state >>> 32) & 0xFFFF
        state = next(state)
        high = (state >>> 16) & 0xFFFF0000
        index = ((id >>> 32) ^ low ^ high) as int
        state = getCharAt(index, chunks, state)
        length = (state >>> 32) & 0xFFFF
        chars = new char[length]
        for i in 0..length:
            state = getCharAt(index + i + 1, chunks, state)
            chars[i] = (char) ((state >>> 32) & 0xFFFF)
        return String(chars)
    """
    # Convert id to unsigned 64-bit representation of the Java long
    id_ = id_ & MASK64

    state = rand_next(rand_seed(id_ & 0xFFFFFFFF))
    low = urshift64(state, 32) & 0xFFFF
    state = rand_next(state)
    # high mask is -0x10000 as long = 0xFFFFFFFFFFFF0000
    high = urshift64(state, 16) & 0xFFFFFFFFFFFF0000

    # index is a Java int (32-bit)
    id_high = urshift64(id_, 32)
    idx_long = (id_high ^ low ^ high) & MASK64
    # cast to int (32-bit, signed)
    index = to_int(idx_long & MASK32)

    state = get_char_at(index, chunks, state)
    length = urshift64(state, 32) & 0xFFFF

    chars = []
    for i in range(length):
        state = get_char_at(index + i + 1, chunks, state)
        chars.append(chr(urshift64(state, 32) & 0xFFFF))
    return "".join(chars)


def parse_smali_chunks(smali_path):
    """Read the Deobfuscator smali file and extract the chunk strings."""
    with open(smali_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Find `const-string vX, "..."` lines
    # There may be multiple chunks
    chunks = []
    for m in re.finditer(r'const-string v\d+, "((?:[^"\\]|\\.)+)"', content):
        raw = m.group(1)
        # Decode \uXXXX escapes
        decoded = []
        i = 0
        while i < len(raw):
            if raw[i] == '\\' and i + 5 < len(raw) and raw[i+1] == 'u':
                try:
                    c = int(raw[i+2:i+6], 16)
                    decoded.append(chr(c))
                    i += 6
                    continue
                except ValueError:
                    pass
            decoded.append(raw[i])
            i += 1
        chunks.append("".join(decoded))
    return chunks


if __name__ == "__main__":
    smali_path = "/projects/sandbox/decompiled_apk/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali"
    chunks = parse_smali_chunks(smali_path)
    print(f"Loaded {len(chunks)} chunk(s). First chunk length: {len(chunks[0]) if chunks else 0}", file=sys.stderr)

    # IDs to decrypt (from smali analysis)
    ids_to_decrypt = {
        "MainActivity.loadAssets - daemonPath suffix":  -0xa347d7e0b5b,
        "MainActivity.loadAssets - exec cmd prefix":    -0xa3a7d7e0b5b,
        "MainActivity.loadAssets2 - bypass filename":   -0xa457d7e0b5b,
        "MainActivity.loadAssets2 - exec cmd prefix":   -0xa4c7d7e0b5b,
        "MainActivity.onCreate - download URL (orig)":  -0x87b7d7e0b5b,
        "FileDownloadTask - moveFile arg1":             -0x7e77d7e0b5b,
        "FileDownloadTask - moveFile arg2":             -0x80d7d7e0b5b,
        "FileDownloadTask - moveFile arg3 suffix":      -0x81c7d7e0b5b,
        "FileDownloadTask - unzipFile source suffix":   -0x81e7d7e0b5b,
        "FileDownloadTask - unzipFile dest suffix":     -0x82e7d7e0b5b,
        "FileDownloadTask - zip password":              -0x82f7d7e0b5b,
        "MainActivity.clinit - library name":           -0xb807d7e0b5b,
        "MainService.clinit - library name":           -0x12417d7e0b5b,
        "MainService$1 - success message check":       -0x12227d7e0b5b,
        "MainService$1 - success toast":               -0x12307d7e0b5b,
        "MainActivity - startPatcher intent action":    -0x9dd7d7e0b5b,
        "MainActivity - startPatcher intent uri prefix": -0xa0f7d7e0b5b,
        "MainActivity - startFloater already running":  -0xa187d7e0b5b,
        "Overlay - startService intent extra":          -0x87b7d7e0b5b,  # duplicate
        # AESCrypt
        "AESCrypt - TAG":                               -0x4a57d7e0b5b,
        "AESCrypt - AES_MODE":                          -0x4ae7d7e0b5b,
        "AESCrypt - CHARSET":                           -0x4c37d7e0b5b,
        "AESCrypt - HASH_ALGORITHM":                    -0x4c97d7e0b5b,
        # LoginActivity firebase ref
        "LoginActivity - firebase ref":                 -0x4d17d7e0b5b,
        "LoginActivity - Settings.Secure key":          -0x4ea7d7e0b5b,
        # heis/OWNER
        "LoginActivity - USER":                         -0x6de7d7e0b5b,
        "LoginActivity - PASS":                         -0x6e37d7e0b5b,
        "LoginActivity - library name (LoginActivity)": -0x6e87d7e0b5b,
        "LoginActivity - OWNER value":                  -0x4f57d7e0b5b,
        # Firebase field names in LoginActivity$1
        "LoginActivity$1 - field 'ppp' (encrypted key)":       -0x1277d7e0b5b,
        "LoginActivity$1 - field 'username'":                  -0x1407d7e0b5b,
        "LoginActivity$1 - field 'llooooldl'":                 -0x1597d7e0b5b,
        "LoginActivity$1 - field 'lmlooooldl'":                -0x1727d7e0b5b,
        "LoginActivity$1 - field 'llooooll'":                  -0x18b7d7e0b5b,
        "LoginActivity$1 - field 'lloooll'":                   -0x1a47d7e0b5b,
        "LoginActivity$1 - field 'llooll'":                    -0x1bd7d7e0b5b,
        "LoginActivity$1 - field 'lllooolll'":                 -0x1d67d7e0b5b,
        "LoginActivity$1 - field 'clllll'":                    -0x1ef7d7e0b5b,
        "LoginActivity$1 - field 'periodType' (plaintext)":    -0x2087d7e0b5b,
        # AESCrypt CHARSET for AssetManager.open
        "MainActivity - loadJSONFromAsset charset":     -0x8387d7e0b5b,
    }

    print(f"\n{'='*80}")
    print(f"{'DECRYPTED STRINGS':^80}")
    print(f"{'='*80}\n")
    print(f"{'HEX ID':<20} {'DECRYPTED VALUE':<50} {'PURPOSE'}")
    print(f"{'-'*20} {'-'*50} {'-'*30}")

    for label, id_ in ids_to_decrypt.items():
        try:
            s = get_string(id_, chunks)
            # For display, escape non-printable
            display = repr(s)
            print(f"{hex(id_ & MASK64):<20} {display:<50} {label}")
        except Exception as e:
            print(f"{hex(id_ & MASK64):<20} ERROR: {type(e).__name__}: {e}")
