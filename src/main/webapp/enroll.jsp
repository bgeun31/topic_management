<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.EnrollmentDAO" %>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%@ page import="com.assignment.model.Course" %>
<%@ page import="com.assignment.dao.NotificationDAO" %>
<%@ page import="com.assignment.model.Notification" %>
<%
    // 로그인 확인 및 학생 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int studentId = (Integer) session.getAttribute("userId");
    String studentName = (String) session.getAttribute("userName");
    
    // 과목 ID 확인
    String courseId = request.getParameter("id");
    if (courseId == null || courseId.isEmpty()) {
        response.sendRedirect("course_list.jsp");
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(Integer.parseInt(courseId));
    
    if (course == null) {
        response.sendRedirect("course_list.jsp");
        return;
    }
    
    // 이미 수강 중인지 확인
    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    boolean isEnrolled = enrollmentDAO.isEnrolled(studentId, Integer.parseInt(courseId));
    
    if (isEnrolled) {
        response.sendRedirect("course_list.jsp?error=already_enrolled");
        return;
    }
    
    // 수강 신청 처리
    boolean result = enrollmentDAO.enrollCourse(studentId, Integer.parseInt(courseId));
    
    if (result) {
        // 교수에게 알림 생성
        NotificationDAO notificationDAO = new NotificationDAO();
        Notification notification = new Notification();
        notification.setUserId(course.getProfessorId());
        notification.setMessage(studentName + " 학생이 '" + course.getCourseName() + "' 과목을 수강 신청했습니다.");
        notification.setLink("course_detail.jsp?id=" + courseId);
        notificationDAO.addNotification(notification);
        
        response.sendRedirect("course_list.jsp?success=enroll");
    } else {
        response.sendRedirect("course_list.jsp?error=enroll");
    }
%>
