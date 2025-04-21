<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.util.DBUtil" %>
<%
    DBUtil.initializeDatabase();
%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1><i class="fas fa-graduation-cap"></i> 과제 관리 시스템</h1>
            <nav>
                <ul>
                    <li><a href="index.jsp" class="active"><i class="fas fa-home"></i> 홈</a></li>
                    <%
                        String userType = (String) session.getAttribute("userType");
                        if (userType == null) {
                    %>
                    <li><a href="login.jsp"><i class="fas fa-sign-in-alt"></i> 로그인</a></li>
                    <li><a href="register.jsp"><i class="fas fa-user-plus"></i> 회원가입</a></li>
                    <%
                        } else if (userType.equals("professor")) {
                    %>
                    <li><a href="course_management.jsp"><i class="fas fa-book"></i> 과목 관리</a></li>
                    <li><a href="assignment_management.jsp"><i class="fas fa-tasks"></i> 과제 관리</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                    <%
                        } else if (userType.equals("student")) {
                    %>
                    <li><a href="course_list.jsp"><i class="fas fa-list"></i> 수강 과목</a></li>
                    <li><a href="assignment_list.jsp"><i class="fas fa-clipboard-list"></i> 과제 목록</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                    <%
                        }
                    %>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="welcome">
                <h2><i class="fas fa-hand-paper"></i> 환영합니다!</h2>
                <p>이 시스템은 교수님과 학생들 간의 과제 관리를 위한 플랫폼입니다.</p>
                
                <%
                    if (userType == null) {
                %>
                <div class="action-buttons">
                    <a href="login.jsp" class="btn"><i class="fas fa-sign-in-alt"></i> 로그인</a>
                    <a href="register.jsp" class="btn"><i class="fas fa-user-plus"></i> 회원가입</a>
                </div>
                <%
                    } else {
                        String userName = (String) session.getAttribute("userName");
                %>
                <p><strong><%= userName %></strong>님 환영합니다.</p>
                <%
                    }
                %>
            </section>
            
            <%
                if (userType != null) {
                    CourseDAO courseDAO = new CourseDAO();
                    List<Course> recentCourses = courseDAO.getRecentCourses(5);
            %>
            <section class="recent-courses">
                <h2><i class="fas fa-clock"></i> 최근 개설된 과목</h2>
                <div class="course-cards">
                    <% for (Course course : recentCourses) { %>
                    <div class="course-card">
                        <h3><%= course.getCourseName() %></h3>
                        <p><i class="fas fa-user-tie"></i> 교수: <%= course.getProfessorName() %></p>
                        <p><i class="fas fa-calendar-alt"></i> 개설일: <%= course.getCreatedDate() %></p>
                        <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small"><i class="fas fa-info-circle"></i> 상세보기</a>
                    </div>
                    <% } %>
                </div>
            </section>
            <%
                }
            %>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
