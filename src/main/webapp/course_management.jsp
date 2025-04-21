<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인 및 교수 권한 확인
   
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int professorId = (Integer) session.getAttribute("userId");
    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getCoursesByProfessor(professorId);
    
    // 성공 메시지 확인
    String success = request.getParameter("success");
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "과목 관리 - 과제 관리 시스템");
%>

        
<main>
    <section class="content-header">
        <h2><i class="fas fa-book"></i> 과목 관리</h2>
        <a href="course_form.jsp" class="btn"><i class="fas fa-plus"></i> 새 과목 개설</a>
    </section>
    
    <% if (success != null) { %>
    <div class="success-message">
        <% if (success.equals("add")) { %>
            <i class="fas fa-check-circle"></i> 과목이 성공적으로 개설되었습니다.
        <% } else if (success.equals("update")) { %>
            <i class="fas fa-check-circle"></i> 과목 정보가 성공적으로 수정되었습니다.
        <% } else if (success.equals("delete")) { %>
            <i class="fas fa-check-circle"></i> 과목이 성공적으로 삭제되었습니다.
        <% } %>
    </div>
    <% } %>
    
    <section class="course-list">
        <h3><i class="fas fa-list"></i> 내 개설 과목</h3>
        <% if (courses.isEmpty()) { %>
        <p class="empty-list">개설한 과목이 없습니다.</p>
        <% } else { %>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>과목명</th>
                        <th>과목 코드</th>
                        <th>학기</th>
                        <th>개설일</th>
                        <th>수강생 수</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Course course : courses) { %>
                    <tr>
                        <td><%= course.getCourseName() %></td>
                        <td><%= course.getCourseCode() %></td>
                        <td><%= course.getSemester() %></td>
                        <td><%= course.getCreatedDate() %></td>
                        <td><span class="badge"><%= course.getStudentCount() %></span></td>
                        <td class="actions">
                            <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세</a>
                            <a href="course_form.jsp?id=<%= course.getId() %>" class="btn-small">수정</a>
                            <a href="course_delete.jsp?id=<%= course.getId() %>" class="btn-small">삭제</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>

<%@ include file="footer.jsp" %>
