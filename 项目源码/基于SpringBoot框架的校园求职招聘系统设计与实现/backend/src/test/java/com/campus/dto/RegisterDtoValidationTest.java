package com.campus.dto;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertTrue;

class RegisterDtoValidationTest {

    private static Validator validator;

    @BeforeAll
    static void setUpValidator() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }

    @Test
    void studentRegisterRejectsShortPassword() {
        StudentRegisterDTO dto = new StudentRegisterDTO();
        dto.setUsername("student");
        dto.setPassword("12345");
        dto.setRealName("张三");
        dto.setSchool("清华大学");
        dto.setStudentNo("20260001");
        dto.setPhone("13800138000");

        Set<ConstraintViolation<StudentRegisterDTO>> violations = validator.validate(dto);

        assertTrue(hasMessage(violations, "密码至少6位"));
    }

    @Test
    void enterpriseRegisterRejectsShortPassword() {
        EnterpriseRegisterDTO dto = new EnterpriseRegisterDTO();
        dto.setUsername("company");
        dto.setPassword("12345");
        dto.setCompanyName("测试企业");
        dto.setCreditCode("913100001234567890");
        dto.setIndustry("互联网");
        dto.setCity("上海");
        dto.setContactName("李四");
        dto.setContactPhone("13800138000");
        dto.setAgreeTerms(Boolean.TRUE);

        Set<ConstraintViolation<EnterpriseRegisterDTO>> violations = validator.validate(dto);

        assertTrue(hasMessage(violations, "密码至少6位"));
    }

    private boolean hasMessage(Set<? extends ConstraintViolation<?>> violations, String message) {
        return violations.stream().anyMatch(violation -> message.equals(violation.getMessage()));
    }
}
