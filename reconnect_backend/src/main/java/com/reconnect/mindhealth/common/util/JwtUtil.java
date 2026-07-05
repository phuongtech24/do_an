package com.reconnect.mindhealth.common.util;

import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtUtil {

    private static final String CLAIM_TOKEN_TYPE = "tokenType";
    private static final String ACCESS_TOKEN_TYPE = "ACCESS";
    private static final String REFRESH_TOKEN_TYPE = "REFRESH";

    @Value("${app.security.jwt-secret:mindhealth-local-secret-change-this-32chars-min}")
    private String jwtSecret;

    @Value("${app.security.jwt-expiration-ms:86400000}")
    private long jwtExpiration;

    @Value("${app.security.refresh-jwt-expiration-ms:2592000000}")
    private long refreshJwtExpiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    public String generateToken(String email) {
        return generateAccessToken(email);
    }

    public String generateAccessToken(String email) {
        return generateToken(email, ACCESS_TOKEN_TYPE, jwtExpiration);
    }

    public String generateRefreshToken(String email) {
        return generateToken(email, REFRESH_TOKEN_TYPE, refreshJwtExpiration);
    }

    public Date getAccessTokenExpiresAt() {
        return new Date(System.currentTimeMillis() + jwtExpiration);
    }

    public Date getRefreshTokenExpiresAt() {
        return new Date(System.currentTimeMillis() + refreshJwtExpiration);
    }

    public long getAccessTokenExpiresIn() {
        return jwtExpiration;
    }

    public long getRefreshTokenExpiresIn() {
        return refreshJwtExpiration;
    }

    public Boolean validateToken(String token) {
        return validateToken(token, null);
    }

    public Boolean validateAccessToken(String token) {
        return validateToken(token, ACCESS_TOKEN_TYPE);
    }

    public Boolean validateRefreshToken(String token) {
        return validateToken(token, REFRESH_TOKEN_TYPE);
    }

    public String getEmailFromToken(String token) {
        return getClaims(token).getSubject();
    }

    private String generateToken(String email, String tokenType, long expirationMs) {
        return Jwts.builder()
                .subject(email)
                .claim(CLAIM_TOKEN_TYPE, tokenType)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(getSigningKey())
                .compact();
    }

    private Boolean validateToken(String token, String expectedType) {
        try {
            Claims claims = getClaims(token);
            if (expectedType == null) {
                return true;
            }
            return expectedType.equalsIgnoreCase(claims.get(CLAIM_TOKEN_TYPE, String.class));
        } catch (Exception e) {
            return false;
        }
    }

    private Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
