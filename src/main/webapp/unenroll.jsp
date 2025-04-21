<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.util.SecurityUtil" %>
<%
    // 로그인 확인 및 학생 권한 확인
    if (session.getAttribute("userType") == null || !session.getAttribute("userType").equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // CSRF 보호
    String token = request.getParameter("csrfToken");
    String sessionToken = (String) session.getAttribute("csrfToken");
    
    // 파라미터 가져오기
    String courseIdStr = request.getParameter("id");
    int courseId = 0;
    int studentId = (Integer) session.getAttribute("userId");
    boolean success = false;
    String message = "";
    
    if (courseIdStr != null && !courseIdStr.isEmpty()) {
        try {
            courseId = Integer.parseInt(courseIdStr);
            
            // 수강 취소 처리
            EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
            
            // 해당 과목을 수강 중인지 확인
            if (enrollmentDAO.isEnrolled(studentId, courseId)) {
                success = enrollmentDAO.unenrollCourse(studentId, courseId);
                if (success) {
                    message = "성공적으로 수강을 취소했습니다.";
                } else {
                    message = "수강 취소 중 오류가 발생했습니다.";
                }
            } else {
                message = "해당 과목에 수강 신청되어 있지 않습니다.";
            }
        } catch (NumberFormatException e) {
            message = "잘못된 과목 ID입니다.";
        }
    } else {
        message = "과목 ID가 제공되지 않았습니다.";
    }
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "수강 취소 - 과제 관리 시스템");
%>

<%@ include file="header.jsp" %>

<main>
    <section class="content-header">
        <h2><i class="fas fa-book"></i> 수강 취소</h2>
    </section>
    
    <section class="form-container">
        <div class="notification <%= success ? "success" : "error" %>">
            <p><%= message %></p>
        </div>
        
        <div class="action-links">
            <a href="course_list.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i> 수강 과목 목록으로
            </a>
        </div>
    </section>
</main>

<%@ include file="footer.jsp" %> 