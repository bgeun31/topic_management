<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int courseId = Integer.parseInt(request.getParameter("id"));
    int professorId = (Integer) session.getAttribute("userId");
    
    // 과목 삭제
    CourseDAO courseDAO = new CourseDAO();
    boolean result = courseDAO.deleteCourse(courseId, professorId);
    
    if (result) {
        response.sendRedirect("course_management.jsp?success=delete");
    } else {
        response.sendRedirect("course_management.jsp?error=delete");
    }
%>
