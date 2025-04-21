<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }

    int professorId = (Integer) session.getAttribute("userId");

    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getCoursesByProfessor(professorId);

    String assignmentId = request.getParameter("id");
    boolean isEdit = assignmentId != null && !assignmentId.isEmpty();
    String title = isEdit ? "과제 수정" : "새 과제 등록";

    Assignment assignment = null;
    if (isEdit) {
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
        if (assignment == null) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }
        Course course = courseDAO.getCourseById(assignment.getCourseId());
        if (course == null || course.getProfessorId() != professorId) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %> - 과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <header>
        <h1>과제 관리 시스템</h1>
        <nav>
            <ul>
                <li><a href="index.jsp">홈</a></li>
                <li><a href="course_management.jsp">과목 관리</a></li>
                <li><a href="assignment_management.jsp" class="active">과제 관리</a></li>
                <li><a href="logout.jsp">로그아웃</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section class="form-container">
            <h2><%= title %></h2>
            <form action="<%= isEdit ? "assignmentUpdate" : "assignmentAdd" %>" method="post" enctype="multipart/form-data">

                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= assignment.getId() %>">
                    <input type="hidden" name="courseId" value="<%= assignment.getCourseId() %>">
                <% } %>

                <div class="form-group">
                    <label for="courseId">과목:</label>
                    <select id="courseId" name="courseId" required <%= isEdit ? "disabled" : "" %>>
                        <option value="">과목을 선택하세요</option>
                        <% for (Course course : courses) { %>
                            <option value="<%= course.getId() %>" <%= isEdit && assignment.getCourseId() == course.getId() ? "selected" : "" %>>
                                <%= course.getCourseName() %> (<%= course.getSemester() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="title">제목:</label>
                    <input type="text" id="title" name="title" required value="<%= isEdit ? assignment.getTitle() : "" %>">
                </div>

                <div class="form-group">
                    <label for="description">설명:</label>
                    <textarea id="description" name="description" rows="6" required><%= isEdit ? assignment.getDescription() : "" %></textarea>
                </div>

                <div class="form-group">
                    <label for="dueDate">마감일:</label>
                    <input type="date" id="dueDate" name="dueDate" required value="<%= isEdit ? assignment.getDueDate() : "" %>">
                </div>

                <div class="form-group">
                    <label for="file">첨부 파일:</label>
                    <input type="file" id="file" name="file">
                    <% if (isEdit && assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
                        <p class="file-info">현재 파일: <%= assignment.getFileName() %></p>
                    <% } %>
                </div>

                <div class="form-group">
                    <button type="submit" class="btn"><%= isEdit ? "수정" : "등록" %></button>
                    <a href="assignment_management.jsp" class="btn btn-secondary">취소</a>
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
