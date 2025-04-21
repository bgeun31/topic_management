package com.assignment.listener;

import java.io.File;

import com.assignment.util.FileUtil;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

/**
 * 웹 애플리케이션 시작/종료 시 실행되는 리스너 클래스입니다.
 * 애플리케이션 시작 시 필요한 디렉토리 구조를 생성합니다.
 */
public class ApplicationListener implements ServletContextListener {

    private static final String LOGIN_ID = "sskm0116";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=== 웹 애플리케이션 시작 ===");
        ServletContext context = sce.getServletContext();
        
        // FileUtil에 ServletContext 설정
        FileUtil.setServletContext(context);
        
        // 웹 애플리케이션 내 uploads 디렉토리 생성
        createDirectory(context, "/uploads");
        createDirectory(context, "/uploads/" + LOGIN_ID);
        
        System.out.println("웹 애플리케이션 초기화 완료");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("=== 웹 애플리케이션 종료 ===");
    }
    
    /**
     * 웹 애플리케이션 내에 디렉토리를 생성합니다.
     * @param context 서블릿 컨텍스트
     * @param path 생성할 디렉토리 경로 (컨텍스트 루트 기준)
     */
    private void createDirectory(ServletContext context, String path) {
        String realPath = context.getRealPath(path);
        if (realPath != null) {
            File dir = new File(realPath);
            if (!dir.exists()) {
                boolean created = dir.mkdirs();
                System.out.println("디렉토리 생성 " + (created ? "성공" : "실패") + ": " + realPath);
            } else {
                System.out.println("디렉토리 이미 존재함: " + realPath);
            }
        } else {
            System.out.println("경로를 가져올 수 없음: " + path);
        }
    }
} 