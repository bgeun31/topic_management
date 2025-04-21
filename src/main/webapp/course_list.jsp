<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인 및 학생 권한 확인
    if (userType == null || !userType.equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int studentId = (Integer) session.getAttribute("userId");
    
    // 수강 중인 과목 목록 가져오기
    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    List<Course> enrolledCourses = enrollmentDAO.getEnrolledCourses(studentId);
    
    // 수강 가능한 과목 목록 가져오기
    CourseDAO courseDAO = new CourseDAO();
    List<Course> availableCourses = courseDAO.getAvailableCourses(studentId);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>수강 과목 - 과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <main>
            <section class="content-header">
                <h2>수강 과목</h2>
            </section>
            
            <section class="enrolled-courses">
                <h3>내 수강 과목</h3>
                <% if (enrolledCourses.isEmpty()) { %>
                <p>수강 중인 과목이 없습니다.</p>
                <% } else { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>과목명</th>
                            <th>교수</th>
                            <th>학기</th>
                            <th>수강 신청일</th>
                            <th>액션</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Course course : enrolledCourses) { %>
                        <tr>
                            <td><%= course.getCourseName() %></td>
                            <td><%= course.getProfessorName() %></td>
                            <td><%= course.getSemester() %></td>
                            <td><%= course.getEnrollmentDate() %></td>
                            <td>
                                <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세</a>
                                <a href="assignment_list.jsp?courseId=<%= course.getId() %>" class="btn-small">과제</a>
                                <a href="unenroll.jsp?id=<%= course.getId() %>" class="btn-small btn-danger" onclick="return confirm('정말 수강 취소하시겠습니까?');">수강 취소</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </section>
            
            <section class="available-courses">
                <h3>수강 가능한 과목</h3>
                <% if (availableCourses.isEmpty()) { %>
                <p>현재 수강 가능한 과목이 없습니다.</p>
                <% } else { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>과목명</th>
                            <th>교수</th>
                            <th>학기</th>
                            <th>개설일</th>
                            <th>액션</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Course course : availableCourses) { %>
                        <tr>
                            <td><%= course.getCourseName() %></td>
                            <td><%= course.getProfessorName() %></td>
                            <td><%= course.getSemester() %></td>
                            <td><%= course.getCreatedDate() %></td>
                            <td>
                                <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세</a>
                                <a href="enroll.jsp?id=<%= course.getId() %>" class="btn-small btn-primary">수강 신청</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
