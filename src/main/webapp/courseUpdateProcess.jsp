<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    
    int courseId = Integer.parseInt(request.getParameter("id"));
    String courseName = request.getParameter("courseName");
    String courseCode = request.getParameter("courseCode");
    String semester = request.getParameter("semester");
    String description = request.getParameter("description");
    int professorId = (Integer) session.getAttribute("userId");
    
    // 과목 객체 생성
    Course course = new Course();
    course.setId(courseId);
    course.setCourseName(courseName);
    course.setCourseCode(courseCode);
    course.setSemester(semester);
    course.setDescription(description);
    course.setProfessorId(professorId);
    
    // 과목 수정
    CourseDAO courseDAO = new CourseDAO();
    boolean result = courseDAO.updateCourse(course);
    
    if (result) {
        response.sendRedirect("course_management.jsp?success=update");
    } else {
        response.sendRedirect("course_form.jsp?id=" + courseId + "&error=1");
    }
%>
