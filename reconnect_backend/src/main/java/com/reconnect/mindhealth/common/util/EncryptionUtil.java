package com.reconnect.mindhealth.common.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Utility class for secure AES-128 encryption and decryption of PHI data.
 * Keys are loaded from environment variables (ENCRYPTION_KEY, ENCRYPTION_IV).
 * 
 * **SECURITY:** Never hardcode encryption keys. Always load from environment variables.
 */
@Component
public class EncryptionUtil {
    private static final String ALGORITHM = "AES/CBC/PKCS5Padding";

    private static SecretKeySpec secretKeySpec;
    private static IvParameterSpec ivParameterSpec;

    /**
     * Constructor that loads encryption keys from environment variables.
     * Spring will automatically call this during bean initialization.
     * 
     * @param encryptionKey Environment variable: ENCRYPTION_KEY (must be exactly 16 chars)
     * @param encryptionIv  Environment variable: ENCRYPTION_IV (must be exactly 16 chars)
     */
    public EncryptionUtil(
            @Value("${encryption.key:ReconnectMindH78}") String encryptionKey,
            @Value("${encryption.iv:MindHealthIv1234}") String encryptionIv) {
        try {
            // Validate key length (must be exactly 16 for AES-128)
            if (encryptionKey == null || encryptionKey.length() != 16) {
                throw new IllegalArgumentException(
                    "ENCRYPTION_KEY (from env) must be exactly 16 characters. Got: " 
                    + (encryptionKey == null ? "null" : encryptionKey.length()));
            }
            if (encryptionIv == null || encryptionIv.length() != 16) {
                throw new IllegalArgumentException(
                    "ENCRYPTION_IV (from env) must be exactly 16 characters. Got: " 
                    + (encryptionIv == null ? "null" : encryptionIv.length()));
            }

            // Initialize static fields
            secretKeySpec = new SecretKeySpec(encryptionKey.getBytes(StandardCharsets.UTF_8), "AES");
            ivParameterSpec = new IvParameterSpec(encryptionIv.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new RuntimeException("Error initializing EncryptionUtil from environment variables", e);
        }
    }

    /**
     * Encrypt a plaintext string using AES-128.
     * 
     * @param strToEncrypt The plaintext to encrypt
     * @return Base64-encoded ciphertext, or null if input is null
     */
    public static String encrypt(String strToEncrypt) {
        try {
            if (strToEncrypt == null) return null;
            if (secretKeySpec == null || ivParameterSpec == null) {
                throw new IllegalStateException(
                    "EncryptionUtil not initialized. Ensure EncryptionUtil bean is created at startup.");
            }
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParameterSpec);
            return Base64.getEncoder().encodeToString(cipher.doFinal(strToEncrypt.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException("Error encrypting", e);
        }
    }

    /**
     * Decrypt an AES-128 encrypted Base64 string.
     * 
     * @param strToDecrypt The Base64-encoded ciphertext
     * @return Plaintext, or null if input is null
     */
    public static String decrypt(String strToDecrypt) {
        try {
            if (strToDecrypt == null) return null;
            if (secretKeySpec == null || ivParameterSpec == null) {
                throw new IllegalStateException(
                    "EncryptionUtil not initialized. Ensure EncryptionUtil bean is created at startup.");
            }
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec);
            return new String(cipher.doFinal(Base64.getDecoder().decode(strToDecrypt)), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Error decrypting", e);
        }
    }
}
