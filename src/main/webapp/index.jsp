<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.util.DBUtil" %>
<%@ include file="header.jsp" %>
<%
    DBUtil.initializeDatabase();
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "홈 - 과제 관리 시스템");
    
%>

        
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
                <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세보기</a>
            </div>
            <% } %>
        </div>
    </section>
    <%
        }
    %>
</main>

<%@ include file="footer.jsp" %>
