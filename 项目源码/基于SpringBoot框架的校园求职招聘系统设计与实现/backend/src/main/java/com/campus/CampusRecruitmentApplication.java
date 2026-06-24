package com.campus;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 校园求职招聘系统启动类
 *
 * @author campus
 */
@SpringBootApplication
@MapperScan("com.campus.mapper")
public class CampusRecruitmentApplication {

    public static void main(String[] args) {
        SpringApplication.run(CampusRecruitmentApplication.class, args);
        System.out.println("\n==============================================");
        System.out.println("  校园求职招聘系统启动成功！");
        System.out.println("  后端接口地址： http://localhost:8081/api");
        System.out.println("==============================================\n");
    }
}
