import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

/**
 * Exact replica of the LSParanoid deobfuscation from the APK.
 * Key insight: In getCharAt, the expression:
 *   chunk.charAt(charIndex % MAX_CHUNK_LENGTH) << 32
 * In Java, charAt returns a char (16-bit unsigned), but when you do << 32 on it,
 * Java first promotes it to int (with sign extension for values > 0x7FFF),
 * then the shift happens on int which is 32-bit, so << 32 on an int is actually << 0!
 * 
 * Wait no - in Java, char is unsigned 16-bit, promoted to int (32-bit) for shift.
 * Then << 32 on an int wraps around (shift amount is mod 32), so it's << 0.
 * But the return type is long, so the expression is:
 *   (chunk.charAt(...) << 32) ^ nextState
 * Since charAt returns char -> promoted to int -> << 32 (which is << 0 for int!) 
 * -> then XOR with long causes int to be widened to long with sign extension.
 * 
 * Actually wait - let me re-read the decompiled code:
 *   return (chunk.charAt(charIndex % MAX_CHUNK_LENGTH) << 32) ^ nextState;
 * 
 * In Java: char -> int promotion (unsigned, so no sign extension)
 * Then: int << 32 = int << (32 % 32) = int << 0 = same int value
 * Then: int ^ long = int is sign-extended to long, then XOR
 * 
 * BUT WAIT - this is DECOMPILED code. The actual bytecode might be different!
 * In the actual bytecode, the char might be cast to long FIRST, then shifted.
 * Let me check what jadx might have gotten wrong.
 * 
 * The correct interpretation from bytecode would be:
 *   return ((long) chunk.charAt(charIndex % MAX_CHUNK_LENGTH) << 32) ^ nextState;
 * 
 * This is a common jadx decompilation issue - missing the (long) cast.
 */
public class FinalDecrypt {
    static final long ZIP_64_SIZE_LIMIT = 4294967295L;
    static final long PAYLOAD_SHORT_MAX = 65535L;
    public static final int MAX_CHUNK_LENGTH = 8191;

    public static long seed(long x) {
        long z = ((x >>> 33) ^ x) * 7109453100751455733L;
        return (((z >>> 28) ^ z) * (-3808689974395783757L)) >>> 32;
    }

    private static short rotl(short x, int k) {
        return (short) ((x << k) | (x >>> (32 - k)));
    }

    public static long next(long state) {
        short s0 = (short) (state & PAYLOAD_SHORT_MAX);
        short s1 = (short) (PAYLOAD_SHORT_MAX & (state >>> 16));
        short nextVal = (short) (s0 + s1);
        short s12 = (short) (s1 ^ s0);
        long result = (short) (rotl(nextVal, 9) + s0);
        return (((result << 16) | rotl(s12, 10)) << 16) | ((short) ((s12 << 5) ^ ((short) (rotl(s0, 13) ^ s12))));
    }

    private static long getCharAt(int charIndex, String[] chunks, long state) {
        long nextState = next(state);
        String chunk = chunks[charIndex / MAX_CHUNK_LENGTH];
        // CRITICAL: cast to long before shifting!
        return ((long) chunk.charAt(charIndex % MAX_CHUNK_LENGTH) << 32) ^ nextState;
    }

    public static String getString(long id, String[] chunks) {
        long state = next(seed(id & ZIP_64_SIZE_LIMIT));
        long low = (state >>> 32) & PAYLOAD_SHORT_MAX;
        long state2 = next(state);
        long high = (state2 >>> 16) & (-65536L);
        int index = (int) (((id >>> 32) ^ low) ^ high);
        long state3 = getCharAt(index, chunks, state2);
        int length = (int) ((state3 >>> 32) & PAYLOAD_SHORT_MAX);
        char[] chars = new char[length];
        for (int i = 0; i < length; i++) {
            state3 = getCharAt(index + i + 1, chunks, state3);
            chars[i] = (char) ((state3 >>> 32) & PAYLOAD_SHORT_MAX);
        }
        return new String(chars);
    }

    public static void main(String[] args) throws Exception {
        // Read the chunk from smali
        String smaliPath = "/home/ubuntu/apk_analysis/decoded/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali";
        String smaliContent = new String(Files.readAllBytes(Paths.get(smaliPath)), "UTF-8");
        
        Pattern p = Pattern.compile("const-string v2, \"(.+?)\"", Pattern.DOTALL);
        Matcher m = p.matcher(smaliContent);
        if (!m.find()) {
            System.err.println("ERROR: Could not find string");
            return;
        }
        
        String rawStr = m.group(1);
        
        // Decode unicode escapes
        StringBuilder sb = new StringBuilder();
        int i = 0;
        while (i < rawStr.length()) {
            if (i + 5 < rawStr.length() && rawStr.charAt(i) == '\\' && rawStr.charAt(i+1) == 'u') {
                String hex = rawStr.substring(i+2, i+6);
                try {
                    sb.append((char) Integer.parseInt(hex, 16));
                    i += 6;
                    continue;
                } catch (NumberFormatException e) {}
            }
            sb.append(rawStr.charAt(i));
            i++;
        }
        
        String decoded = sb.toString();
        System.out.println("Chunk length: " + decoded.length() + " characters");
        
        String[] chunks = new String[] { decoded };
        
        // Read all IDs
        List<Long> ids = new ArrayList<>();
        BufferedReader br = new BufferedReader(new FileReader("/home/ubuntu/apk_analysis/all_ids.txt"));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (!line.isEmpty()) {
                ids.add(Long.parseLong(line));
            }
        }
        br.close();
        
        System.out.println("Total IDs: " + ids.size());
        System.out.println("\n=== DECRYPTED STRINGS ===\n");
        
        PrintWriter pw = new PrintWriter(new FileWriter("/home/ubuntu/apk_analysis/decrypted_all.txt"));
        
        int success = 0;
        int failed = 0;
        for (long id : ids) {
            try {
                String result = getString(id, chunks);
                String output = id + "|" + result;
                System.out.println(output);
                pw.println(output);
                success++;
            } catch (Exception e) {
                String output = id + "|ERROR:" + e.getClass().getSimpleName() + ":" + e.getMessage();
                pw.println(output);
                failed++;
            }
        }
        
        pw.close();
        System.out.println("\n=== SUMMARY ===");
        System.out.println("Success: " + success + "/" + ids.size());
        System.out.println("Failed: " + failed + "/" + ids.size());
    }
}
