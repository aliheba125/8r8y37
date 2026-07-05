#!/usr/bin/env python3
"""
Zero Loader V4.4.01 - License Keygen / Cracker
================================================
This script demonstrates how the license system can be completely bypassed.

The app uses AES/CBC/PKCS7Padding with:
- Key: SHA-256("Activity") 
- IV: 16 bytes of zeros
- Data stored in Firebase /users/{uid} as AES-encrypted strings

This keygen can:
1. Encrypt any license data in the same format the app expects
2. Decrypt existing license data from Firebase
3. Generate valid license entries that would pass validation
"""

import hashlib
import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

class ZeroLoaderKeygen:
    def __init__(self):
        # Hardcoded key from the app (found via LSParanoid decryption)
        self.password = "Activity"
        # Derive AES key using SHA-256
        self.key = hashlib.sha256(self.password.encode('utf-8')).digest()
        # IV is all zeros (critical weakness!)
        self.iv = b'\x00' * 16
    
    def encrypt(self, plaintext):
        """Encrypt data exactly as the app does"""
        cipher = AES.new(self.key, AES.MODE_CBC, self.iv)
        padded = pad(plaintext.encode('utf-8'), AES.block_size)
        encrypted = cipher.encrypt(padded)
        return base64.b64encode(encrypted).decode('utf-8')
    
    def decrypt(self, ciphertext_b64):
        """Decrypt data from Firebase"""
        try:
            cipher = AES.new(self.key, AES.MODE_CBC, self.iv)
            encrypted = base64.b64decode(ciphertext_b64)
            decrypted = unpad(cipher.decrypt(encrypted), AES.block_size)
            return decrypted.decode('utf-8')
        except Exception as e:
            return f"[DECRYPTION ERROR: {e}]"
    
    def generate_license(self, username="HackedUser", key="PREMIUM-KEY-2026", 
                         max_devices=99, period="Lifetime", status="Active",
                         owner="Admin", exp="2099-12-31"):
        """Generate a complete fake license entry for Firebase"""
        license_data = {
            "Login": self.encrypt("true"),
            "Key": self.encrypt(key),
            "Username": self.encrypt(username),
            "MaxDevices": self.encrypt(str(max_devices)),
            "Period": self.encrypt(period),
            "Status": self.encrypt(status),
            "Owner": self.encrypt(owner),
            "Active": self.encrypt("true"),
            "EXP": self.encrypt(exp),
            "UUID": self.encrypt("fake-uuid-12345"),
            "Devices": self.encrypt("1"),
        }
        return license_data
    
    def crack_validation(self):
        """
        Demonstrate how to bypass the license check entirely.
        
        The app validates by:
        1. Reading /users/{uid}/Key from Firebase
        2. Decrypting it with AES(key="Activity", iv=zeros)
        3. Comparing with user input
        
        Since we know the encryption key, we can:
        - Decrypt any existing key
        - Encrypt any key we want
        - Or simply patch the APK to skip validation
        """
        print("=" * 60)
        print("ZERO LOADER V4.4.01 - LICENSE CRACKER")
        print("=" * 60)
        print()
        print(f"[*] AES Password: '{self.password}'")
        print(f"[*] AES Key (SHA-256): {self.key.hex()}")
        print(f"[*] AES IV: {self.iv.hex()} (ALL ZEROS!)")
        print(f"[*] Mode: AES/CBC/PKCS7Padding")
        print()
        
        # Demo: encrypt/decrypt cycle
        test_values = [
            ("Login", "true"),
            ("Key", "WOLF-PREMIUM-2026-LIFETIME"),
            ("Username", "TestUser"),
            ("MaxDevices", "5"),
            ("Period", "Lifetime"),
            ("Status", "Active"),
            ("EXP", "2099-12-31"),
            ("Active", "true"),
        ]
        
        print("[+] GENERATING FAKE LICENSE VALUES:")
        print("-" * 60)
        for field, value in test_values:
            encrypted = self.encrypt(value)
            decrypted = self.decrypt(encrypted)
            print(f"  {field}:")
            print(f"    Plaintext:  {value}")
            print(f"    Encrypted:  {encrypted}")
            print(f"    Verify:     {decrypted}")
            print()
        
        # Generate complete license
        print("[+] COMPLETE FIREBASE LICENSE ENTRY (JSON):")
        print("-" * 60)
        license = self.generate_license()
        import json
        print(json.dumps(license, indent=2))
        print()
        
        # Error messages the app checks
        print("[+] APP ERROR MESSAGES (encrypted form):")
        print("-" * 60)
        errors = [
            "USER NOT REGISTERED",
            "MAX DEVICE REACHED", 
            "USER BLOCKED",
            "EXPIRED KEY",
            "Login Success",
        ]
        for msg in errors:
            print(f"  '{msg}' → {self.encrypt(msg)}")
        print()
        
        # Bypass methods
        print("[+] BYPASS METHODS:")
        print("-" * 60)
        print("  Method 1: Firebase Rule Exploitation")
        print("    - Anonymous auth is enabled")
        print("    - Write your own license to /users/{your_uid}")
        print("    - If rules allow write (they might for own UID)")
        print()
        print("  Method 2: APK Patching (smali)")
        print("    - Patch LoginActivity.validateKey() to always return true")
        print("    - Remove Firebase check entirely")
        print("    - Change 'USER NOT REGISTERED' check to skip")
        print()
        print("  Method 3: Frida/Xposed Hook")
        print("    - Hook AESCrypt.decrypt() to return 'Active' always")
        print("    - Hook Firebase ValueEventListener to inject fake data")
        print()
        print("  Method 4: Local SharedPreferences")
        print("    - App stores login state in SharedPreferences")
        print("    - Modify /data/data/com.pubgm/shared_prefs/ directly")
        print()

if __name__ == "__main__":
    keygen = ZeroLoaderKeygen()
    keygen.crack_validation()
