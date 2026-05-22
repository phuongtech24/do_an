# 🔐 Hướng dẫn Đơn giản: Authentication với JWT

> Dành cho dự án chỉ cần **Đăng nhập / Đăng ký** mà không cần RBAC phức tạp.

---

## 📦 Cấu trúc tầng backend (giản lược)

```
com.yourcompany.yourproject/
├── domain/
│   └── User.java             ← Entity
├── repository/
│   └── UserRepository.java    ← Data access
├── dto/
│   ├── LoginRequest.java      ← Input
│   ├── LoginResponse.java     ← Output với token
│   └── UserDto.java           ← User info
├── service/
│   └── AuthService.java       ← Business logic
├── util/
│   └── JwtUtil.java           ← Token utils (tạo/kiểm tra token)
├── security/
│   ├── JwtFilter.java         ← Bắt token từ header
│   ├── SecurityConfig.java    ← Filter chain
│   └── CustomUserDetails.java ← Spring Security UserDetails
└── rest/
    └── AuthController.java    ← API endpoints
```

---

## 🔧 Từng file cần viết

### 1️⃣ **pom.xml** — thêm dependency

```xml
<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

### 2️⃣ **User.java** (Entity)

```java
package com.yourcompany.yourproject.domain;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;

@Entity
@Table(name = "tbl_user")
@Data
@NoArgsConstructor
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(nullable = false, unique = true)
    private String username;
    
    @Column(nullable = false)
    private String password;  // bcrypt hash
    
    @Column(nullable = false, unique = true)
    private String email;
    
    private String fullName;
    
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

### 3️⃣ **UserRepository.java**

```java
package com.yourcompany.yourproject.repository;

import com.yourcompany.yourproject.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
}
```

### 4️⃣ **JwtUtil.java** — tạo & verify token

```java
package com.yourcompany.yourproject.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {
    
    @Value("${jwt.secret:your-super-secret-key-min-32-chars-change-me-now!!!!!!}")
    private String jwtSecret;
    
    @Value("${jwt.expiration:86400000}")  // 24 hours (milliseconds)
    private long jwtExpiration;
    
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }
    
    // ✅ Tạo token
    public String generateToken(String username, String userId) {
        return Jwts.builder()
                .setSubject(username)
                .claim("userId", userId)  // claim thêm ID
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    // ✅ Lấy username từ token
    public String getUsernameFromToken(String token) {
        return getClaims(token).getSubject();
    }
    
    // ✅ Lấy userId từ token
    public String getUserIdFromToken(String token) {
        return (String) getClaims(token).get("userId");
    }
    
    // ✅ Kiểm tra token còn hạn không
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            System.err.println("JWT validation failed: " + e.getMessage());
            return false;
        }
    }
    
    // ✅ Lấy claims từ token
    private Claims getClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
```

### 5️⃣ **CustomUserDetails.java**

```java
package com.yourcompany.yourproject.security;

import com.yourcompany.yourproject.domain.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.ArrayList;
import java.util.Collection;

public class CustomUserDetails implements UserDetails {
    
    private User user;
    
    public CustomUserDetails(User user) {
        this.user = user;
    }
    
    public User getUser() {
        return user;
    }
    
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return new ArrayList<>();  // Không cần role lúc này
    }
    
    @Override
    public String getPassword() {
        return user.getPassword();
    }
    
    @Override
    public String getUsername() {
        return user.getUsername();
    }
    
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
    
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }
    
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
    
    @Override
    public boolean isEnabled() {
        return user.getIsActive() != null ? user.getIsActive() : true;
    }
}
```

### 6️⃣ **CustomUserDetailsService.java**

```java
package com.yourcompany.yourproject.security;

import com.yourcompany.yourproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByUsername(username)
                .map(CustomUserDetails::new)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }
}
```

### 7️⃣ **JwtFilter.java** — bắt token từ header

```java
package com.yourcompany.yourproject.security;

import com.yourcompany.yourproject.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

@Component
public class JwtFilter extends OncePerRequestFilter {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private UserDetailsService userDetailsService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                     HttpServletResponse response, 
                                     FilterChain filterChain)
            throws ServletException, IOException {
        try {
            // Lấy token từ header: Authorization: Bearer <token>
            String token = getTokenFromRequest(request);
            
            if (token != null && jwtUtil.validateToken(token)) {
                String username = jwtUtil.getUsernameFromToken(token);
                
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                
                // Tạo authentication object
                UsernamePasswordAuthenticationToken authentication = 
                        new UsernamePasswordAuthenticationToken(
                            userDetails, 
                            null, 
                            userDetails.getAuthorities()
                        );
                
                // Đưa vào SecurityContext để controller có thể dùng
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: " + e.getMessage());
        }
        
        filterChain.doFilter(request, response);
    }
    
    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

### 8️⃣ **SecurityConfig.java** — filter chain

```java
package com.yourcompany.yourproject.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {
    
    @Autowired
    private JwtFilter jwtFilter;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> {})
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/login").permitAll()
                .requestMatchers("/api/auth/register").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

### 9️⃣ **AuthService.java** — business logic

```java
package com.yourcompany.yourproject.service;

import com.yourcompany.yourproject.domain.User;
import com.yourcompany.yourproject.dto.LoginRequest;
import com.yourcompany.yourproject.dto.LoginResponse;
import com.yourcompany.yourproject.dto.UserDto;
import com.yourcompany.yourproject.repository.UserRepository;
import com.yourcompany.yourproject.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class AuthService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    // ✅ Đăng nhập
    public LoginResponse login(LoginRequest request) {
        Optional<User> user = userRepository.findByUsername(request.getUsername());
        
        if (user.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        
        User userData = user.get();
        
        // Kiểm tra password
        if (!passwordEncoder.matches(request.getPassword(), userData.getPassword())) {
            throw new RuntimeException("Invalid password");
        }
        
        // Tạo token
        String token = jwtUtil.generateToken(userData.getUsername(), userData.getId().toString());
        
        return new LoginResponse(
            token,
            "Bearer",
            new UserDto(userData)
        );
    }
    
    // ✅ Đăng ký
    public UserDto register(String username, String password, String email, String fullName) {
        // Kiểm tra username có tồn tại không
        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("Username already exists");
        }
        
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already exists");
        }
        
        // Tạo user mới
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setFullName(fullName);
        newUser.setPassword(passwordEncoder.encode(password));  // ← Hash password
        newUser.setIsActive(true);
        
        User saved = userRepository.save(newUser);
        
        return new UserDto(saved);
    }
}
```

### 🔟 **LoginRequest.java** (DTO)

```java
package com.yourcompany.yourproject.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
}
```

### 1️⃣1️⃣ **LoginResponse.java** (DTO)

```java
package com.yourcompany.yourproject.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {
    private String token;
    private String tokenType;  // "Bearer"
    private UserDto user;
}
```

### 1️⃣2️⃣ **UserDto.java** (DTO)

```java
package com.yourcompany.yourproject.dto;

import com.yourcompany.yourproject.domain.User;
import lombok.Data;
import java.util.UUID;

@Data
public class UserDto {
    private UUID id;
    private String username;
    private String email;
    private String fullName;
    private Boolean isActive;
    
    public UserDto(User user) {
        if (user != null) {
            this.id = user.getId();
            this.username = user.getUsername();
            this.email = user.getEmail();
            this.fullName = user.getFullName();
            this.isActive = user.getIsActive();
        }
    }
}
```

### 1️⃣3️⃣ **AuthController.java** (REST API)

```java
package com.yourcompany.yourproject.rest;

import com.yourcompany.yourproject.dto.LoginRequest;
import com.yourcompany.yourproject.dto.LoginResponse;
import com.yourcompany.yourproject.dto.UserDto;
import com.yourcompany.yourproject.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Đăng nhập / Đăng ký")
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    // ✅ POST /api/auth/login
    @PostMapping("/login")
    @Operation(summary = "Đăng nhập", description = "Trả về JWT token")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(
                new ErrorResponse("LOGIN_FAILED", e.getMessage())
            );
        }
    }
    
    // ✅ POST /api/auth/register
    @PostMapping("/register")
    @Operation(summary = "Đăng ký", description = "Tạo tài khoản mới")
    public ResponseEntity<?> register(@RequestParam String username,
                                      @RequestParam String password,
                                      @RequestParam String email,
                                      @RequestParam String fullName) {
        try {
            UserDto user = authService.register(username, password, email, fullName);
            return ResponseEntity.ok(
                new ApiResponse("Đăng ký thành công", user)
            );
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(
                new ErrorResponse("REGISTER_FAILED", e.getMessage())
            );
        }
    }
    
    // ✅ GET /api/auth/profile (cần token)
    @GetMapping("/profile")
    @Operation(summary = "Lấy thông tin user hiện tại")
    public ResponseEntity<?> getProfile() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.badRequest().body(
                new ErrorResponse("NO_AUTH", "Không tìm thấy thông tin user")
            );
        }
        
        return ResponseEntity.ok(
            new ApiResponse("Thành công", auth.getName())
        );
    }
    
    // ✅ Helper classes
    public static class ApiResponse {
        public String message;
        public Object data;
        public ApiResponse(String message, Object data) {
            this.message = message;
            this.data = data;
        }
    }
    
    public static class ErrorResponse {
        public String error;
        public String message;
        public ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
        }
    }
}
```

### 1️⃣4️⃣ **application.yml** — config

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/my_db
    username: postgres
    password: 123456
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

server:
  port: 8080
  servlet:
    context-path: /

jwt:
  secret: "your-super-secret-key-min-32-chars-change-me-now!!!!!!"
  expiration: 86400000  # 24 hours (milliseconds)
```

---

## 📝 Luồng hoạt động

### **Đăng nhập:**
```
1. Client POST /api/auth/login
   { "username": "john", "password": "123" }

2. AuthService.login()
   → Tìm user by username
   → So sánh password (bcrypt)
   → Nếu OK: JwtUtil.generateToken(username, userId)

3. Trả về token + user info
   {
     "token": "eyJhbGc...",
     "tokenType": "Bearer",
     "user": { "id": "...", "username": "john", "email": "..." }
   }

4. Client lưu token (localStorage)
```

### **Sau này khi gọi API:**
```
1. Client thêm header: Authorization: Bearer <token>

2. JwtFilter bắt request
   → Lấy token từ header
   → JwtUtil.validateToken(token)
   → Nếu OK: lấy username → setAuthentication()

3. Controller chạy bình thường
   (có thể dùng @Secured, @PreAuthorize nếu muốn)
```

---

## ✅ Checklist triển khai

- [ ] Thêm jjwt dependency vào pom.xml
- [ ] Tạo User entity + UserRepository
- [ ] Viết JwtUtil (tạo token / verify token)
- [ ] Viết CustomUserDetails + CustomUserDetailsService
- [ ] Viết JwtFilter
- [ ] Viết SecurityConfig
- [ ] Viết AuthService (login + register logic)
- [ ] Viết DTOs (LoginRequest, LoginResponse, UserDto)
- [ ] Viết AuthController (3 endpoints: /login, /register, /profile)
- [ ] Config application.yml (jwt.secret + jwt.expiration)
- [ ] Test: POST /api/auth/register → POST /api/auth/login → GET /api/auth/profile với token

---

## 🧪 Test với Postman

### **1. Đăng ký:**
```
POST http://localhost:8080/api/auth/register?username=john&password=pass123&email=john@example.com&fullName=John Doe
```

### **2. Đăng nhập:**
```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "username": "john",
  "password": "pass123"
}

→ Response:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "user": {...}
}
```

### **3. Lấy profile (cần token):**
```
GET http://localhost:8080/api/auth/profile
Authorization: Bearer eyJhbGc...
```

---

## 📚 Ghi chú quan trọng

| Khía cạnh | So với ECDS (công ty) | Phiên bản đơn |
|---|---|---|
| **Password** | LDAP / OAuth | bcrypt (JPA) |
| **Token** | /oauth/token (core JAR) | JwtUtil (custom) |
| **RBAC** | role_privilege.csv + EcdsRbacConfigService | Không cần (chỉ username) |
| **Captcha** | LoginWrapperController | Không cần |
| **Scopes** | DataPermissionService | Không cần |
| **Complexity** | ~1500 dòng + 5 JAR deps | ~300 dòng + 3 JAR deps |

---

## 🎯 Tiếp theo

- Sau khi login, frontend lưu token ở `localStorage`:
  ```javascript
  localStorage.setItem("token", response.token);
  ```
- Mỗi request gửi token ở header:
  ```javascript
  headers: { "Authorization": "Bearer " + localStorage.getItem("token") }
  ```
- Khi token hết hạn → redirect tới /login
