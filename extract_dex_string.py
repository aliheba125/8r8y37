#!/usr/bin/env python3
"""
Extract the LSParanoid chunk string directly from classes4.dex
The DEX format stores strings in MUTF-8 encoding
"""
import struct
import os

def read_uleb128(data, offset):
    """Read unsigned LEB128 value"""
    result = 0
    shift = 0
    while True:
        b = data[offset]
        offset += 1
        result |= (b & 0x7F) << shift
        if (b & 0x80) == 0:
            break
        shift += 7
    return result, offset

def decode_mutf8(data, offset, length_hint):
    """Decode Modified UTF-8 string from DEX"""
    chars = []
    end = len(data)
    while offset < end:
        b = data[offset]
        if b == 0:  # null terminator
            break
        offset += 1
        if (b & 0x80) == 0:
            # Single byte (ASCII)
            chars.append(chr(b))
        elif (b & 0xE0) == 0xC0:
            # Two bytes
            b2 = data[offset]
            offset += 1
            chars.append(chr(((b & 0x1F) << 6) | (b2 & 0x3F)))
        elif (b & 0xF0) == 0xE0:
            # Three bytes
            b2 = data[offset]
            b3 = data[offset + 1]
            offset += 2
            chars.append(chr(((b & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)))
        else:
            # Should not happen in MUTF-8 for BMP chars
            chars.append('?')
    return ''.join(chars)

def parse_dex(filepath):
    """Parse DEX file and extract all strings"""
    with open(filepath, 'rb') as f:
        data = f.read()
    
    # DEX header
    magic = data[0:8]
    print(f"Magic: {magic}")
    
    # String IDs offset and count
    string_ids_size = struct.unpack_from('<I', data, 56)[0]
    string_ids_off = struct.unpack_from('<I', data, 60)[0]
    
    print(f"String IDs: count={string_ids_size}, offset={string_ids_off}")
    
    # Find the longest string (our chunk)
    longest_str = ""
    longest_idx = -1
    
    for i in range(string_ids_size):
        str_data_off = struct.unpack_from('<I', data, string_ids_off + i * 4)[0]
        # Read ULEB128 length
        str_len, str_start = read_uleb128(data, str_data_off)
        
        if str_len > len(longest_str):
            try:
                decoded = decode_mutf8(data, str_start, str_len)
                if len(decoded) > len(longest_str):
                    longest_str = decoded
                    longest_idx = i
            except:
                pass
    
    print(f"\nLongest string: index={longest_idx}, length={len(longest_str)}")
    print(f"First 50 chars: {repr(longest_str[:50])}")
    print(f"Last 50 chars: {repr(longest_str[-50:])}")
    
    return longest_str

if __name__ == '__main__':
    dex_path = '/home/ubuntu/apk_analysis/extracted/classes4.dex'
    print(f"Parsing {dex_path}...")
    print(f"File size: {os.path.getsize(dex_path)} bytes\n")
    
    chunk = parse_dex(dex_path)
    
    # Save the chunk for use by the decryptor
    with open('/home/ubuntu/apk_analysis/chunk_raw.bin', 'wb') as f:
        # Write as UTF-16LE for Java compatibility
        for c in chunk:
            f.write(struct.pack('<H', ord(c)))
    
    print(f"\nSaved chunk ({len(chunk)} chars) to chunk_raw.bin")
    print(f"Binary file size: {os.path.getsize('/home/ubuntu/apk_analysis/chunk_raw.bin')} bytes")
