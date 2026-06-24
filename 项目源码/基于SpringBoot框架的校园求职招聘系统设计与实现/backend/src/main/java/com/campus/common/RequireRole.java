package com.campus.common;

import java.lang.annotation.*;

/**
 * 角色权限注解：标注在 Controller 方法或类上，限制可访问的角色。
 * 不标注则只要登录即可访问；标注则必须是指定角色之一。
 *
 * @author campus
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequireRole {

    /** 允许的角色：ADMIN/ENTERPRISE/STUDENT */
    String[] value();
}
