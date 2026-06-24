package com.campus.service;

import com.campus.dto.*;
import com.campus.vo.LoginVO;

/**
 * 认证服务：登录、注册、改密码（三类角色）
 *
 * @author campus
 */
public interface AuthService {

    /** 统一登录 */
    LoginVO login(LoginDTO dto);

    /** 学生注册 */
    void studentRegister(StudentRegisterDTO dto);

    /** 企业注册 */
    void enterpriseRegister(EnterpriseRegisterDTO dto);

    /** 修改密码 */
    void changePassword(ChangePasswordDTO dto);
}
