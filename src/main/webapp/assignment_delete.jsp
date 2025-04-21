<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.AssignmentDAO" %>
<%@ page import="com.assignment.model.Assignment" %>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%@ page import="com.assignment.model.Course" %>
<%@ page import="com.assignment.util.FileUtil" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int professorId = (Integer) session.getAttribute("userId");
    
    // 과제 ID 확인
    String assignmentId = request.getParameter("id");
    if (assignmentId == null || assignmentId.isEmpty()) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과제 정보 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    Assignment assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
    
    if (assignment == null) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(assignment.getCourseId());
    
    // 권한 확인 (해당 과목의 교수인지)
    if (course == null || course.getProfessorId() != professorId) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과제 파일이 있는 경우 삭제
    if (assignment.getFilePath() != null && !assignment.getFilePath().isEmpty()) {
        FileUtil.deleteFile(request, assignment.getFilePath());
    }
    
    // 과제 삭제
    boolean result = assignmentDAO.deleteAssignment(Integer.parseInt(assignmentId), assignment.getCourseId());
    
    if (result) {
        response.sendRedirect("assignment_management.jsp?courseId=" + assignment.getCourseId() + "&success=delete");
    } else {
        response.sendRedirect("assignment_detail.jsp?id=" + assignmentId + "&error=delete");
    }
%>
