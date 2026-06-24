package com.campus.config;

import com.campus.common.*;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 登录与权限拦截器
 *
 * @author campus
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${campus.jwt.header}")
    private String header;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 放行非控制器方法（如静态资源）
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }
        HandlerMethod handlerMethod = (HandlerMethod) handler;

        // 取 token
        String token = request.getHeader(header);
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        if (token == null || token.isEmpty()) {
            writeUnauthorized(response, "未登录或登录已过期，请重新登录");
            return false;
        }

        Claims claims = jwtUtil.parseToken(token);
        if (claims == null) {
            writeUnauthorized(response, "登录状态无效，请重新登录");
            return false;
        }

        // 设置上下文
        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(Long.valueOf(claims.get("userId").toString()));
        loginUser.setUsername(claims.get("username").toString());
        loginUser.setRole(claims.get("role").toString());
        UserContext.set(loginUser);

        // 角色校验
        RequireRole requireRole = handlerMethod.getMethodAnnotation(RequireRole.class);
        if (requireRole == null) {
            requireRole = handlerMethod.getBeanType().getAnnotation(RequireRole.class);
        }
        if (requireRole != null) {
            boolean allowed = false;
            for (String role : requireRole.value()) {
                if (role.equals(loginUser.getRole())) {
                    allowed = true;
                    break;
                }
            }
            if (!allowed) {
                writeForbidden(response, "无权限访问该资源");
                return false;
            }
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }

    private void writeUnauthorized(HttpServletResponse response, String msg) throws Exception {
        writeJson(response, 401, msg);
    }

    private void writeForbidden(HttpServletResponse response, String msg) throws Exception {
        writeJson(response, 403, msg);
    }

    private void writeJson(HttpServletResponse response, int code, String msg) throws Exception {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"code\":" + code + ",\"message\":\"" + msg + "\",\"data\":null}");
    }
}
