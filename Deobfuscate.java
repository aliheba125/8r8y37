import java.io.*;
import java.nio.file.*;
import java.util.*;

public class Deobfuscate {
    public static final int MAX_CHUNK_LENGTH = 8191;

    public static long seed(long x) {
        long z = ((x >>> 33) ^ x) * 7109453100751455733L;
        return (((z >>> 28) ^ z) * (-3808689974395783757L)) >>> 32;
    }

    public static long next(long state) {
        short s0 = (short) (state & 0xFFFFL);
        short s1 = (short) (0xFFFFL & (state >>> 16));
        short nextVal = (short) (s0 + s1);
        short s12 = (short) (s1 ^ s0);
        long result = (short) (rotl(nextVal, 9) + s0);
        return (((result << 16) | rotl(s12, 10)) << 16) | ((short) ((s12 << 5) ^ ((short) (rotl(s0, 13) ^ s12))));
    }

    private static short rotl(short x, int k) {
        return (short) ((x << k) | ((x & 0xFFFF) >>> (16 - k)));
    }

    private static long getCharAt(int charIndex, String[] chunks, long state) {
        long nextState = next(state);
        String chunk = chunks[charIndex / MAX_CHUNK_LENGTH];
        return ((long)chunk.charAt(charIndex % MAX_CHUNK_LENGTH) << 32) ^ nextState;
    }

    public static String getString(long id, String[] chunks) {
        long state = next(seed(id & 0xFFFFFFFFL));
        long low = (state >>> 32) & 0xFFFFL;
        long state2 = next(state);
        long high = (state2 >>> 16) & 0xFFFF0000L;
        int index = (int) (((id >>> 32) ^ low) ^ high);
        long state3 = getCharAt(index, chunks, state2);
        int length = (int) ((state3 >>> 32) & 0xFFFFL);
        char[] chars = new char[length];
        for (int i = 0; i < length; i++) {
            state3 = getCharAt(index + i + 1, chunks, state3);
            chars[i] = (char) ((state3 >>> 32) & 0xFFFFL);
        }
        return new String(chars);
    }

    public static void main(String[] args) throws Exception {
        // Read chunks from smali file
        String smaliContent = new String(Files.readAllBytes(Paths.get(args[0])));
        
        // Extract the chunks string
        int start = smaliContent.indexOf("\"");
        int end = smaliContent.lastIndexOf("\"");
        if (start < 0 || end <= start) {
            System.err.println("Could not find string data");
            return;
        }
        
        // Parse the chunks - find all string literals in sput-object lines
        List<String> chunkList = new ArrayList<>();
        String[] lines = smaliContent.split("\n");
        StringBuilder currentChunk = new StringBuilder();
        boolean inString = false;
        
        for (String line : lines) {
            if (line.trim().startsWith("const-string")) {
                int q1 = line.indexOf('"');
                int q2 = line.lastIndexOf('"');
                if (q1 >= 0 && q2 > q1) {
                    String str = line.substring(q1 + 1, q2);
                    // Decode unicode escapes
                    chunkList.add(decodeUnicode(str));
                }
            }
        }
        
        if (chunkList.isEmpty()) {
            System.err.println("No chunks found, trying alternative parsing...");
            // Try to find the fill-array-data or sput pattern
            // Look for the big string constant
            int idx = smaliContent.indexOf("sput-object");
            System.err.println("Found sput-object at: " + idx);
            return;
        }
        
        String[] chunks = chunkList.toArray(new String[0]);
        System.err.println("Found " + chunks.length + " chunks, total chars: " + 
            chunkList.stream().mapToInt(String::length).sum());
        
        // Test with known IDs from the code
        long[] testIds = {
            -15395268201307L,  // User.isPremium
            -5147476233051L,   // AES_MODE
            -4541885844315L,   // hash algorithm
            -4602015386459L,   // AES
            -4735159372635L,   // decrypt key
            -946998217563L,    // Firebase reference (GroupActivity)
            -826739133275L,    // FCM URL
            -5297800088411L,   // Login reference
            -9708731501403L,   // MainActivity reference
            -14738138205019L,  // root access message
            -14793972779867L,  // no root message
            -11246329793371L,  // chmod command
            -11323639204699L,  // bypass command
            -26154161277787L,  // OPEN_DOCUMENT_TREE action
            -26330254936923L,  // content URI
        };
        
        for (long id : testIds) {
            try {
                String result = getString(id, chunks);
                System.out.println("ID " + id + " = \"" + result + "\"");
            } catch (Exception e) {
                System.out.println("ID " + id + " = ERROR: " + e.getMessage());
            }
        }
    }
    
    private static String decodeUnicode(String input) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            if (i + 5 < input.length() && input.charAt(i) == '\\' && input.charAt(i+1) == 'u') {
                String hex = input.substring(i+2, i+6);
                try {
                    sb.append((char) Integer.parseInt(hex, 16));
                    i += 5;
                } catch (NumberFormatException e) {
                    sb.append(input.charAt(i));
                }
            } else {
                sb.append(input.charAt(i));
            }
        }
        return sb.toString();
    }
}
