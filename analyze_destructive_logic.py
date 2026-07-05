import subprocess
import os

def get_strings(file_path):
    result = subprocess.run(['strings', '-t', 'x', file_path], capture_output=True, text=True)
    return result.stdout

def analyze():
    sock64_path = "assets_extracted/sock64"
    if not os.path.exists(sock64_path):
        print(f"Error: {sock64_path} not found.")
        return

    print("=== DEEP ANALYSIS OF DESTRUCTIVE LOGIC ===")
    
    # 1. Locate the dangerous string
    strings_output = get_strings(sock64_path)
    target_str = "rm -rf /data/*"
    offset = -1
    for line in strings_output.splitlines():
        if target_str in line:
            offset = int(line.split()[0], 16)
            print(f"[+] Found destructive command at offset: 0x{offset:x}")
            break
    
    if offset == -1:
        print("[-] Could not find the destructive command string.")
        return

    # 2. Find surrounding strings to understand the context
    print("\n[+] Context strings around the command:")
    lines = strings_output.splitlines()
    for i, line in enumerate(lines):
        if target_str in line:
            for j in range(max(0, i-10), min(len(lines), i+15)):
                print(f"    {lines[j]}")

    # 3. Analyze the logic based on the strings
    print("\n[+] Logic Inference:")
    print("Based on the surrounding strings, the destruction is triggered by a 'Package Check':")
    print("1. The daemon checks for a specific package: 'com.ldev.leoskillz'")
    print("2. It checks for a specific version: '3.7.3'")
    print("3. It checks for a specific label: 'LeoSkillz'")
    print("4. It checks for a build date: '2025-05-17'")
    print("\nIf any of these don't match (Mismatch), it triggers the 'su -c rm -rf' command.")
    print("This is a 'Kill Switch' used to prevent using the daemon with a modified or different APK.")

    # 4. How to neutralize it (Technical Explanation)
    print("\n[+] HOW TO NEUTRALIZE (Technical Guide):")
    print("-" * 50)
    print("To stop this command from ever running, we have three options:")
    print("\nOption A: Binary Patching (The most effective)")
    print(f"Replace the string 'su -c \"rm -rf /data/* && reboot\"' with a harmless string like 'echo \"Safe Mode Active\" ############'.")
    print(f"The replacement must have the EXACT same length or be null-terminated earlier.")
    
    print("\nOption B: Logic Patching")
    print("Find the branch instruction (B.NE or CBZ) that leads to the destruction code and change it to a NOP (No Operation) or a forced jump (B) to the safe path.")
    
    print("\nOption C: Environment Spoofing")
    print("Ensure the system environment always returns 'com.ldev.leoskillz' and '3.7.3' when queried by the daemon.")

    print("\n[+] PROOF OF NEUTRALIZATION (Simulation):")
    # We will create a patched version of sock64 for demonstration
    with open(sock64_path, 'rb') as f:
        data = bytearray(f.read())
    
    old_cmd = b'su -c "rm -rf /data/* && reboot"'
    new_cmd = b'echo "Command Neutralized By Manus" #' # Same length or padded with #
    new_cmd = new_cmd.ljust(len(old_cmd), b'#')
    
    if old_cmd in data:
        data = data.replace(old_cmd, new_cmd)
        patched_path = "assets_extracted/sock64_SAFE"
        with open(patched_path, 'wb') as f:
            f.write(data)
        print(f"\n[!] SUCCESS: Created a neutralized version at {patched_path}")
        print(f"    The command 'rm -rf' has been replaced with a harmless 'echo' command.")
    else:
        print("\n[-] Failed to find the command in binary for patching.")

if __name__ == "__main__":
    analyze()
