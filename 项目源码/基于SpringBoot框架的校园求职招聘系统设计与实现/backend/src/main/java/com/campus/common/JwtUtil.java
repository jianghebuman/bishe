package com.campus.common;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具类
 *
 * @author campus
 */
@Slf4j
@Component
public class JwtUtil {

    @Value("${campus.jwt.secret}")
    private String secret;

    @Value("${campus.jwt.expire}")
    private Long expire;

    /** 生成 token */
    public String createToken(Long userId, String username, String role) {
        Map<String, Object> claims = new HashMap<>(4);
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", role);
        Date now = new Date();
        Date expireDate = new Date(now.getTime() + expire);
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(expireDate)
                .signWith(SignatureAlgorithm.HS256, secret)
                .compact();
    }

    /** 解析 token */
    public Claims parseToken(String token) {
        try {
            return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
        } catch (Exception e) {
            log.warn("token解析失败：{}", e.getMessage());
            return null;
        }
    }

    /** 从 token 中获取登录用户 */
    public LoginUser getLoginUser(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        LoginUser user = new LoginUser();
        user.setUserId(Long.valueOf(claims.get("userId").toString()));
        user.setUsername(claims.get("username").toString());
        user.setRole(claims.get("role").toString());
        return user;
    }
}
