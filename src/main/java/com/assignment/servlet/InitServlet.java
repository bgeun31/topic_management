package com.assignment.servlet;

import com.assignment.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

@WebServlet(urlPatterns = "/init", loadOnStartup = 1)
public class InitServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("🔄 InitServlet 실행 중 - DB 초기화 시도 중...");
        DBUtil.initializeDatabase();
        System.out.println("✅ InitServlet 완료 - DB 초기화 성공 또는 이미 존재함");
    }
}
