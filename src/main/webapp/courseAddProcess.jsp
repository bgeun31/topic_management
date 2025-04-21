<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%@ page import="com.assignment.model.Course" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    request.setCharacterEncoding("UTF-8");
    
    String courseName = request.getParameter("courseName");
    String courseCode = request.getParameter("courseCode");
    String semester = request.getParameter("semester");
    String description = request.getParameter("description");
    int professorId = (Integer) session.getAttribute("userId");
    
    // 현재 날짜 생성
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String createdDate = sdf.format(new Date());
    
    // 과목 객체 생성
    Course course = new Course();
    course.setCourseName(courseName);
    course.setCourseCode(courseCode);
    course.setSemester(semester);
    course.setDescription(description);
    course.setProfessorId(professorId);
    course.setCreatedDate(createdDate);
    
    // 과목 추가
    CourseDAO courseDAO = new CourseDAO();
    boolean result = courseDAO.addCourse(course);
    
    if (result) {
        response.sendRedirect("course_management.jsp?success=add");
    } else {
        response.sendRedirect("course_form.jsp?error=1");
    }
%>
