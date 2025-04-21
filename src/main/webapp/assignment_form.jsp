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
    request.setAttribute("pageTitle", title + " - 과제 관리 시스템");

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
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/button-override.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="container">
    <jsp:include page="header.jsp" />

    <main>
        <section class="form-container">
            <h2><i class="fas fa-edit"></i> <%= title %></h2>
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
                    <button type="submit" class="btn btn-primary">
                        <i class="fas <%= isEdit ? "fa-save" : "fa-plus" %>"></i> <%= isEdit ? "수정" : "등록" %>
                    </button>
                    <a href="assignment_management.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> 취소
                    </a>
                </div>
            </form>
        </section>
    </main>

    <jsp:include page="footer.jsp" />
</div>
</body>
</html>
