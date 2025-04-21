<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 수정 모드인지 확인
    String courseId = request.getParameter("id");
    boolean isEdit = courseId != null && !courseId.isEmpty();
    String title = isEdit ? "과목 수정" : "새 과목 개설";
    
    // 수정 모드일 경우 과목 정보 가져오기
    Course course = null;
    if (isEdit) {
        CourseDAO courseDAO = new CourseDAO();
        course = courseDAO.getCourseById(Integer.parseInt(courseId));
        
        // 해당 과목이 없거나 현재 교수의 과목이 아닌 경우
        if (course == null || course.getProfessorId() != (Integer) session.getAttribute("userId")) {
            response.sendRedirect("course_management.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= title %> - 과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1><i class="fas fa-graduation-cap"></i> 과제 관리 시스템</h1>
            <nav>
                <ul>
                    <li><a href="index.jsp"><i class="fas fa-home"></i> 홈</a></li>
                    <li><a href="course_management.jsp" class="active"><i class="fas fa-book"></i> 과목 관리</a></li>
                    <li><a href="assignment_management.jsp"><i class="fas fa-tasks"></i> 과제 관리</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="form-container">
                <h2><%= isEdit ? "<i class=\"fas fa-edit\"></i> " + title : "<i class=\"fas fa-plus\"></i> " + title %></h2>
                <form action="<%= isEdit ? "courseUpdateProcess.jsp" : "courseAddProcess.jsp" %>" method="post">
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= course.getId() %>">
                    <% } %>
                    <div class="form-group">
                        <label for="courseName"><i class="fas fa-book"></i> 과목명:</label>
                        <input type="text" id="courseName" name="courseName" required
                               value="<%= isEdit ? course.getCourseName() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="courseCode"><i class="fas fa-hashtag"></i> 과목 코드:</label>
                        <input type="text" id="courseCode" name="courseCode" required
                               value="<%= isEdit ? course.getCourseCode() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="semester"><i class="fas fa-calendar-alt"></i> 학기:</label>
                        <select id="semester" name="semester" required>
                            <option value="">선택하세요</option>
                            <option value="2025-1" <%= isEdit && course.getSemester().equals("2025-1") ? "selected" : "" %>>2025년 1학기</option>
                            <option value="2025-2" <%= isEdit && course.getSemester().equals("2025-2") ? "selected" : "" %>>2025년 2학기</option>
                            <option value="2026-1" <%= isEdit && course.getSemester().equals("2026-1") ? "selected" : "" %>>2026년 1학기</option>
                            <option value="2026-2" <%= isEdit && course.getSemester().equals("2026-2") ? "selected" : "" %>>2026년 2학기</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="description"><i class="fas fa-align-left"></i> 과목 설명:</label>
                        <textarea id="description" name="description" rows="4"><%= isEdit ? course.getDescription() : "" %></textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn"><%= isEdit ? "<i class=\"fas fa-save\"></i> 수정" : "<i class=\"fas fa-plus\"></i> 개설" %></button>
                        <a href="course_management.jsp" class="btn btn-secondary"><i class="fas fa-times"></i> 취소</a>
                    </div>
                </form>
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
