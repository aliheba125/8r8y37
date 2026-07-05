import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

/**
 * LSParanoid Deobfuscator - exact replica of the app's logic
 * Based on: org.lsposed.lsparanoid.DeobfuscatorHelper
 * and org.lsposed.lsparanoid.RandomHelper
 */
public class LSParanoidDecrypt {

    // Constants from the libraries used in the app
    static final long ZIP_64_SIZE_LIMIT = 4294967295L; // 0xFFFFFFFFL
    static final long PAYLOAD_SHORT_MAX = 65535L; // 0xFFFFL

    public static final int MAX_CHUNK_LENGTH = 8191;

    // RandomHelper.seed
    public static long seed(long x) {
        long z = ((x >>> 33) ^ x) * 7109453100751455733L;
        return (((z >>> 28) ^ z) * (-3808689974395783757L)) >>> 32;
    }

    // RandomHelper.rotl (short)
    private static short rotl(short x, int k) {
        // Java's short is 16-bit signed
        // The original code: (short) ((x << k) | (x >>> (32 - k)))
        // But this is wrong for 16-bit! The original uses >>> 32-k which for short means it treats it as int
        return (short) ((x << k) | ((x & 0xFFFF) >>> (32 - k)));
    }

    // RandomHelper.next
    public static long next(long state) {
        short s0 = (short) (state & PAYLOAD_SHORT_MAX);
        short s1 = (short) (PAYLOAD_SHORT_MAX & (state >>> 16));
        short nextVal = (short) (s0 + s1);
        short s12 = (short) (s1 ^ s0);
        long result = (short) (rotl(nextVal, 9) + s0);
        return (((result << 16) | rotl(s12, 10)) << 16) | ((short) ((s12 << 5) ^ ((short) (rotl(s0, 13) ^ s12))));
    }

    // DeobfuscatorHelper.getCharAt
    private static long getCharAt(int charIndex, String[] chunks, long state) {
        long nextState = next(state);
        String chunk = chunks[charIndex / MAX_CHUNK_LENGTH];
        return (((long) chunk.charAt(charIndex % MAX_CHUNK_LENGTH)) << 32) ^ nextState;
    }

    // DeobfuscatorHelper.getString
    public static String getString(long id, String[] chunks) {
        long state = next(seed(id & ZIP_64_SIZE_LIMIT));
        long low = (state >>> 32) & PAYLOAD_SHORT_MAX;
        long state2 = next(state);
        long high = (state2 >>> 16) & (-65536L); // ~PAYLOAD_SHORT_MAX = 0xFFFF0000...
        // Actually: & (-65536) in Java means & 0xFFFFFFFFFFFF0000
        // But the original code says: & (-65536) which is 0xFFFFFFFFFFFF0000
        // Wait, let me re-read: (state2 >>> 16) & (-65536)
        // -65536 as long = 0xFFFFFFFFFFFF0000
        // But PAYLOAD_SHORT_MAX is 65535, so the original is:
        // high = (state2 >>> 16) & (~PAYLOAD_SHORT_MAX) but that's wrong
        // Let me re-read the decompiled code:
        // long high = (state2 >>> 16) & (-65536);
        // In Java: -65536L = 0xFFFFFFFFFFFF0000L
        // So high gets bits 16-63 of (state2 >>> 16)
        
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
        // Read the smali file to get the raw chunk string
        String smaliPath = "/home/ubuntu/apk_analysis/decoded/smali_classes4/org/lsposed/lsparanoid/Deobfuscator$M5LOADER$app.smali";
        String smaliContent = new String(Files.readAllBytes(Paths.get(smaliPath)), "UTF-8");
        
        // Extract the const-string value
        Pattern p = Pattern.compile("const-string v2, \"(.+?)\"", Pattern.DOTALL);
        Matcher m = p.matcher(smaliContent);
        if (!m.find()) {
            System.err.println("ERROR: Could not find const-string in smali");
            return;
        }
        
        String rawStr = m.group(1);
        // Decode smali unicode escapes (backslash-u XXXX)
        String decoded = decodeSmaliUnicode(rawStr);
        
        System.out.println("Chunk loaded: " + decoded.length() + " characters");
        
        // The chunks array has 1 element
        String[] chunks = new String[] { decoded };
        
        // Read all IDs from file
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
        
        System.out.println("Total IDs to decode: " + ids.size());
        System.out.println("\n=== DECRYPTED STRINGS ===\n");
        
        // Also write to file
        PrintWriter pw = new PrintWriter(new FileWriter("/home/ubuntu/apk_analysis/decrypted_strings.txt"));
        
        int success = 0;
        int failed = 0;
        for (long id : ids) {
            try {
                String result = getString(id, chunks);
                String output = "ID=" + id + " => \"" + result + "\"";
                System.out.println(output);
                pw.println(output);
                success++;
            } catch (Exception e) {
                String output = "ID=" + id + " => ERROR: " + e.getMessage();
                System.out.println(output);
                pw.println(output);
                failed++;
            }
        }
        
        pw.close();
        System.out.println("\n=== SUMMARY ===");
        System.out.println("Success: " + success + "/" + ids.size());
        System.out.println("Failed: " + failed + "/" + ids.size());
    }
    
    private static String decodeSmaliUnicode(String input) {
        StringBuilder sb = new StringBuilder();
        int i = 0;
        while (i < input.length()) {
            if (i + 5 < input.length() && input.charAt(i) == '\\' && input.charAt(i + 1) == 'u') {
                String hex = input.substring(i + 2, i + 6);
                try {
                    int codePoint = Integer.parseInt(hex, 16);
                    sb.append((char) codePoint);
                    i += 6;
                    continue;
                } catch (NumberFormatException e) {
                    // Not a valid unicode escape, treat as literal
                }
            }
            sb.append(input.charAt(i));
            i++;
        }
        return sb.toString();
    }
}
