package com.reconnect.mindhealth.common.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Utility class for secure AES-128 encryption and decryption of PHI data.
 */
public class EncryptionUtil {
    private static final String ALGORITHM = "AES/CBC/PKCS5Padding";
    private static final String KEY_STRING = "ReconnectMindH78"; // Exactly 16 chars
    private static final String IV_STRING = "MindHealthIv1234";  // Exactly 16 chars

    private static SecretKeySpec secretKeySpec;
    private static IvParameterSpec ivParameterSpec;

    static {
        try {
            secretKeySpec = new SecretKeySpec(KEY_STRING.getBytes(StandardCharsets.UTF_8), "AES");
            ivParameterSpec = new IvParameterSpec(IV_STRING.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new RuntimeException("Error initializing EncryptionUtil", e);
        }
    }

    /**
     * Encrypt a plaintext string using AES-128.
     */
    public static String encrypt(String strToEncrypt) {
        try {
            if (strToEncrypt == null) return null;
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParameterSpec);
            return Base64.getEncoder().encodeToString(cipher.doFinal(strToEncrypt.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException("Error encrypting", e);
        }
    }

    /**
     * Decrypt an AES-128 encrypted Base64 string.
     */
    public static String decrypt(String strToDecrypt) {
        try {
            if (strToDecrypt == null) return null;
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec);
            return new String(cipher.doFinal(Base64.getDecoder().decode(strToDecrypt)), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Error decrypting", e);
        }
    }
}
