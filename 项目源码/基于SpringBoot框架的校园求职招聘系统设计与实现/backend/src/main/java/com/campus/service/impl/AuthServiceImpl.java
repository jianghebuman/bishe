package com.campus.service.impl;

import com.campus.common.*;
import com.campus.dto.*;
import com.campus.entity.AdminUser;
import com.campus.entity.Enterprise;
import com.campus.entity.Student;
import com.campus.service.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.vo.LoginVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * 认证服务实现
 *
 * @author campus
 */
@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private StudentService studentService;
    @Autowired
    private EnterpriseService enterpriseService;
    @Autowired
    private AdminUserService adminUserService;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private OperationLogService operationLogService;

    @Override
    public LoginVO login(LoginDTO dto) {
        String role = dto.getRole();
        LoginVO vo = new LoginVO();
        if ("STUDENT".equals(role)) {
            Student s = studentService.getByUsername(dto.getUsername());
            checkUser(s == null, s != null && s.getStatus() == 0, s == null ? null : s.getPassword(), dto.getPassword());
            s.setLastLogin(new Date());
            studentService.updateById(s);
            vo.setToken(jwtUtil.createToken(s.getId(), s.getUsername(), role));
            vo.setUserId(s.getId());
            vo.setUsername(s.getUsername());
            vo.setName(s.getRealName());
            vo.setAvatar(s.getAvatar());
        } else if ("ENTERPRISE".equals(role)) {
            Enterprise e = enterpriseService.getByUsername(dto.getUsername());
            checkUser(e == null, e != null && e.getStatus() == 0, e == null ? null : e.getPassword(), dto.getPassword());
            e.setLastLogin(new Date());
            enterpriseService.updateById(e);
            vo.setToken(jwtUtil.createToken(e.getId(), e.getUsername(), role));
            vo.setUserId(e.getId());
            vo.setUsername(e.getUsername());
            vo.setName(e.getCompanyName());
            vo.setAvatar(e.getLogo());
            vo.setAuditStatus(e.getAuditStatus());
        } else if ("ADMIN".equals(role)) {
            AdminUser a = adminUserService.getByUsername(dto.getUsername());
            checkUser(a == null, a != null && a.getStatus() == 0, a == null ? null : a.getPassword(), dto.getPassword());
            a.setLastLogin(new Date());
            adminUserService.updateById(a);
            vo.setToken(jwtUtil.createToken(a.getId(), a.getUsername(), role));
            vo.setUserId(a.getId());
            vo.setUsername(a.getUsername());
            vo.setName(a.getRealName());
            vo.setAvatar(a.getAvatar());
        } else {
            throw new BusinessException("不支持的登录身份");
        }
        vo.setRole(role);
        // 记录登录日志
        try {
            OperationLogServiceImpl impl = (OperationLogServiceImpl) operationLogService;
            com.campus.entity.OperationLog log = new com.campus.entity.OperationLog();
            log.setLogType("LOGIN");
            log.setModule("登录");
            log.setOperation(role + " 登录系统");
            log.setUserName(dto.getUsername());
            log.setUserType(role);
            log.setUserId(vo.getUserId());
            log.setStatus(1);
            impl.save(log);
        } catch (Exception ignore) {
        }
        return vo;
    }

    /** 统一校验：是否存在、是否禁用、密码是否正确 */
    private void checkUser(boolean notExist, boolean disabled, String encodedPwd, String rawPwd) {
        if (notExist) {
            throw new BusinessException("账号不存在");
        }
        if (disabled) {
            throw new BusinessException("账号已被禁用，请联系管理员");
        }
        if (!passwordEncoder.matches(rawPwd, encodedPwd)) {
            throw new BusinessException("密码错误");
        }
    }

    @Override
    public void studentRegister(StudentRegisterDTO dto) {
        if (studentService.getByUsername(dto.getUsername()) != null) {
            throw new BusinessException("账号已存在");
        }
        Student s = new Student();
        s.setUsername(dto.getUsername());
        s.setPassword(passwordEncoder.encode(dto.getPassword()));
        s.setRealName(dto.getRealName());
        s.setStudentNo(dto.getStudentNo());
        s.setCollege(dto.getCollege());
        s.setMajor(dto.getMajor());
        s.setGrade(dto.getGrade());
        s.setPhone(dto.getPhone());
        s.setEmail(dto.getEmail());
        s.setEducation("本科");
        s.setStatus(1);
        studentService.save(s);
    }

    @Override
    public void enterpriseRegister(EnterpriseRegisterDTO dto) {
        if (enterpriseService.getByUsername(dto.getUsername()) != null) {
            throw new BusinessException("账号已存在");
        }
        long creditCodeCount = enterpriseService.count(new LambdaQueryWrapper<Enterprise>()
                .eq(Enterprise::getCreditCode, dto.getCreditCode()));
        if (creditCodeCount > 0) {
            throw new BusinessException("该统一社会信用代码已注册");
        }
        Enterprise e = new Enterprise();
        e.setUsername(dto.getUsername());
        e.setPassword(passwordEncoder.encode(dto.getPassword()));
        e.setCompanyName(dto.getCompanyName());
        e.setCreditCode(dto.getCreditCode());
        e.setIndustry(dto.getIndustry());
        e.setScale(dto.getScale());
        e.setCity(dto.getCity());
        e.setContactName(dto.getContactName());
        e.setContactPhone(dto.getContactPhone());
        e.setEmail(dto.getEmail());
        e.setWebsite(dto.getWebsite());
        e.setAuditStatus(0);
        e.setStatus(1);
        enterpriseService.save(e);
    }

    @Override
    public void changePassword(ChangePasswordDTO dto) {
        LoginUser user = UserContext.get();
        if (user == null) {
            throw new BusinessException("未登录");
        }
        String role = user.getRole();
        String encoded = passwordEncoder.encode(dto.getNewPassword());
        if ("STUDENT".equals(role)) {
            Student s = studentService.getById(user.getUserId());
            verifyOldPwd(dto.getOldPassword(), s.getPassword());
            s.setPassword(encoded);
            studentService.updateById(s);
        } else if ("ENTERPRISE".equals(role)) {
            Enterprise e = enterpriseService.getById(user.getUserId());
            verifyOldPwd(dto.getOldPassword(), e.getPassword());
            e.setPassword(encoded);
            enterpriseService.updateById(e);
        } else if ("ADMIN".equals(role)) {
            AdminUser a = adminUserService.getById(user.getUserId());
            verifyOldPwd(dto.getOldPassword(), a.getPassword());
            a.setPassword(encoded);
            adminUserService.updateById(a);
        }
    }

    private void verifyOldPwd(String raw, String encoded) {
        if (!passwordEncoder.matches(raw, encoded)) {
            throw new BusinessException("原密码错误");
        }
    }
}
