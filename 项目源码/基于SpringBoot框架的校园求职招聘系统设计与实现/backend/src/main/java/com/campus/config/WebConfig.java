package com.campus.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Web 配置：拦截器、跨域、静态资源映射
 *
 * @author campus
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private AuthInterceptor authInterceptor;

    @Value("${campus.upload.path}")
    private String uploadPath;

    @Value("${campus.upload.prefix}")
    private String uploadPrefix;

    /** 注册拦截器，配置放行白名单 */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        // 认证相关
                        "/auth/**",
                        // 公共接口（首页、职位浏览、公告等无需登录）
                        "/public/**",
                        // 文件访问
                        "/upload/**",
                        // 错误页
                        "/error"
                );
    }

    /** 跨域配置 */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    /** 静态资源映射：上传文件访问 */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path uploadRoot = Paths.get(uploadPath).toAbsolutePath().normalize();
        String resourceLocation = uploadRoot.toUri().toString();
        if (!resourceLocation.endsWith("/")) {
            resourceLocation += "/";
        }

        registry.addResourceHandler(uploadPrefix + "**")
                .addResourceLocations(resourceLocation);
    }
}
