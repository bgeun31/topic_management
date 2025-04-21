<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.AssignmentDAO" %>
<%@ page import="com.assignment.model.Assignment" %>
<%@ page import="com.assignment.util.FileUtil" %>
<%@ page import="com.assignment.dao.NotificationDAO" %>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%@ page import="com.assignment.model.Course" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    request.setCharacterEncoding("UTF-8");
    
    int courseId = Integer.parseInt(request.getParameter("courseId"));
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String dueDate = request.getParameter("dueDate");
    int professorId = (Integer) session.getAttribute("userId");
    
    // 과목이 현재 교수의 과목인지 확인
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(courseId);
    
    if (course == null || course.getProfessorId() != professorId) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 파일 업로드 처리
    String fileName = null;
    String filePath = null;
    
    // 멀티파트 요청인 경우 파일 업로드 처리
    if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
        filePath = FileUtil.uploadFile(request, "file", "assignments");
        if (filePath != null) {
            fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
        }
    }
    
    // 과제 객체 생성
    Assignment assignment = new Assignment();
    assignment.setCourseId(courseId);
    assignment.setTitle(title);
    assignment.setDescription(description);
    assignment.setDueDate(dueDate);
    assignment.setFileName(fileName);
    assignment.setFilePath(filePath);
    
    // 과제 추가
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    boolean result = assignmentDAO.addAssignment(assignment);
    
    if (result) {
        // 과제 ID 가져오기 (알림용)
        int assignmentId = assignmentDAO.getLastInsertedId();
        
        // 수강생들에게 알림 생성
        NotificationDAO notificationDAO = new NotificationDAO();
        notificationDAO.notifyNewAssignment(courseId, assignmentId, title);
        
        response.sendRedirect("assignment_management.jsp?courseId=" + courseId + "&success=add");
    } else {
        response.sendRedirect("assignment_form.jsp?error=1");
    }
%>
