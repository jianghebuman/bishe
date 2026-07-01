package com.campus.service.impl;

import com.campus.common.BusinessException;
import com.campus.dto.EnterpriseRegisterDTO;
import com.campus.dto.StudentRegisterDTO;
import com.campus.service.EnterpriseHrService;
import com.campus.service.EnterpriseService;
import com.campus.service.StudentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class AuthServiceImplTest {

    private final StudentService studentService = mock(StudentService.class);
    private final EnterpriseService enterpriseService = mock(EnterpriseService.class);
    private final EnterpriseHrService enterpriseHrService = mock(EnterpriseHrService.class);
    private final BCryptPasswordEncoder passwordEncoder = mock(BCryptPasswordEncoder.class);

    private AuthServiceImpl authService;

    @BeforeEach
    void setUp() {
        authService = new AuthServiceImpl();
        ReflectionTestUtils.setField(authService, "studentService", studentService);
        ReflectionTestUtils.setField(authService, "enterpriseService", enterpriseService);
        ReflectionTestUtils.setField(authService, "enterpriseHrService", enterpriseHrService);
        ReflectionTestUtils.setField(authService, "passwordEncoder", passwordEncoder);
        when(passwordEncoder.encode(any(String.class))).thenReturn("encoded");
    }

    @Test
    void studentRegisterReportsSchoolStudentNoConflict() {
        doThrow(new DuplicateKeyException("Duplicate entry for key 'uk_student_school_no'"))
                .when(studentService).save(any());

        BusinessException ex = assertThrows(BusinessException.class,
                () -> authService.studentRegister(buildStudentRegisterDTO()));

        assertEquals("同一学校下学号已存在", ex.getMessage());
    }

    @Test
    void enterpriseRegisterReportsCreditCodeConflict() {
        doThrow(new DuplicateKeyException("Duplicate entry for key 'uk_enterprise_credit_code'"))
                .when(enterpriseService).save(any());

        BusinessException ex = assertThrows(BusinessException.class,
                () -> authService.enterpriseRegister(buildEnterpriseRegisterDTO()));

        assertEquals("该企业已入驻，请联系企业主管HR添加账号", ex.getMessage());
    }

    private StudentRegisterDTO buildStudentRegisterDTO() {
        StudentRegisterDTO dto = new StudentRegisterDTO();
        dto.setUsername("student");
        dto.setPassword("123456");
        dto.setRealName("张三");
        dto.setSchool("清华大学");
        dto.setStudentNo("20260001");
        dto.setPhone("13800138000");
        return dto;
    }

    private EnterpriseRegisterDTO buildEnterpriseRegisterDTO() {
        EnterpriseRegisterDTO dto = new EnterpriseRegisterDTO();
        dto.setUsername("company");
        dto.setPassword("123456");
        dto.setCompanyName("测试企业");
        dto.setCreditCode("913100001234567890");
        dto.setIndustry("互联网");
        dto.setCity("上海");
        dto.setContactName("李四");
        dto.setContactPhone("13800138000");
        dto.setAgreeTerms(Boolean.TRUE);
        return dto;
    }
}
