package com.campus.service.impl;

import com.campus.common.*;
import com.campus.dto.*;
import com.campus.entity.AdminUser;
import com.campus.entity.Enterprise;
import com.campus.entity.EnterpriseHr;
import com.campus.entity.Student;
import com.campus.service.*;
import com.campus.vo.LoginVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private EnterpriseHrService enterpriseHrService;
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
            EnterpriseHr hr = enterpriseHrService.getByUsername(dto.getUsername());
            checkUser(hr == null, hr != null && hr.getStatus() == 0, hr == null ? null : hr.getPassword(), dto.getPassword());
            Enterprise e = enterpriseService.getById(hr.getEnterpriseId());
            if (e == null || Integer.valueOf(0).equals(e.getStatus())) {
                throw new BusinessException("企业已被禁用，请联系管理员");
            }
            hr.setLastLogin(new Date());
            enterpriseHrService.updateById(hr);
            vo.setToken(jwtUtil.createToken(hr.getId(), hr.getUsername(), role, hr.getEnterpriseId(), hr.getHrRole()));
            vo.setUserId(hr.getId());
            vo.setUsername(hr.getUsername());
            vo.setName(hr.getRealName() == null || hr.getRealName().trim().isEmpty() ? e.getCompanyName() : hr.getRealName());
            vo.setAvatar(e.getLogo());
            vo.setAuditStatus(e.getAuditStatus());
            vo.setEnterpriseId(hr.getEnterpriseId());
            vo.setHrRole(hr.getHrRole());
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
        Student s = new Student();
        s.setUsername(dto.getUsername());
        s.setPassword(passwordEncoder.encode(dto.getPassword()));
        s.setRealName(dto.getRealName());
        s.setSchool(dto.getSchool());
        s.setStudentNo(dto.getStudentNo());
        s.setCollege(dto.getCollege());
        s.setMajor(dto.getMajor());
        s.setGrade(dto.getGrade());
        s.setPhone(dto.getPhone());
        s.setEmail(dto.getEmail());
        s.setEducation("本科");
        s.setStatus(1);
        try {
            studentService.save(s);
        } catch (DuplicateKeyException e) {
            String msg = e.getMessage() == null ? "" : e.getMessage();
            if (msg.contains("uk_student_school_no")) {
                throw new BusinessException("同一学校下学号已存在");
            }
            throw new BusinessException("账号已存在");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enterpriseRegister(EnterpriseRegisterDTO dto) {
        Enterprise e = new Enterprise();
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
        try {
            enterpriseService.save(e);
            EnterpriseHr hr = new EnterpriseHr();
            hr.setEnterpriseId(e.getId());
            hr.setUsername(dto.getUsername());
            hr.setPassword(passwordEncoder.encode(dto.getPassword()));
            hr.setRealName(dto.getContactName());
            hr.setPhone(dto.getContactPhone());
            hr.setEmail(dto.getEmail());
            hr.setHrRole(EnterpriseHrService.ROLE_SUPERVISOR);
            hr.setStatus(1);
            enterpriseHrService.save(hr);
        } catch (DuplicateKeyException ex) {
            String msg = ex.getMessage() == null ? "" : ex.getMessage();
            if (msg.contains("uk_enterprise_credit_code")) {
                throw new BusinessException("该企业已入驻，请联系企业主管HR添加账号");
            }
            throw new BusinessException("账号已存在");
        }
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
            EnterpriseHr hr = enterpriseHrService.getById(user.getUserId());
            verifyOldPwd(dto.getOldPassword(), hr.getPassword());
            hr.setPassword(encoded);
            enterpriseHrService.updateById(hr);
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
