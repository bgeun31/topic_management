package com.assignment.servlet;

import com.assignment.util.DBUtil;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

@WebServlet(urlPatterns = "/init", loadOnStartup = 1)
public class InitServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("🔄 InitServlet 실행 중 - DB 초기화 시도 중...");
        
        // 데이터베이스 초기화
        DBUtil.initializeDatabase();
        System.out.println("✅ 데이터베이스 및 테이블 초기화 완료");
        
        // 서블릿 컨텍스트 설정 - 파일 업로드에 사용
        FileUtil.setServletContext(getServletContext());
        System.out.println("✅ ServletContext 설정 완료 - 파일 업로드 경로 설정");
        
        // 업로드 디렉토리 생성
        String uploadPath = FileUtil.getOSUploadPath();
        System.out.println("✅ 업로드 경로 확인: " + uploadPath);
    }
}
