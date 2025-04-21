<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }

    int professorId = (Integer) request.getAttribute("userId");

    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getCoursesByProfessor(professorId);

    String selectedCourseId = request.getParameter("courseId");
    List<Assignment> assignments = new ArrayList<>();

    if (selectedCourseId != null && !selectedCourseId.isEmpty()) {
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        assignments = assignmentDAO.getAssignmentsByCourse(Integer.parseInt(selectedCourseId));
    }
%>

<main>
    <section class="content-header">
        <h2>과제 관리</h2>
        <% if (!courses.isEmpty()) { %>
        <a href="assignment_form.jsp" class="btn">새 과제 등록</a>
        <% } %>
    </section>

    <section class="course-selector">
        <h3>과목 선택</h3>
        <% if (courses.isEmpty()) { %>
        <p>개설한 과목이 없습니다. <a href="course_form.jsp">과목을 먼저 개설</a>해주세요.</p>
        <% } else { %>
        <form action="assignment_management.jsp" method="get">
            <div class="form-group">
                <select name="courseId" onchange="this.form.submit()">
                    <option value="">과목을 선택하세요</option>
                    <% for (Course course : courses) { %>
                    <option value="<%= course.getId() %>" <%= selectedCourseId != null && selectedCourseId.equals(String.valueOf(course.getId())) ? "selected" : "" %>>
                        <%= course.getCourseName() %> (<%= course.getSemester() %>)
                    </option>
                    <% } %>
                </select>
            </div>
        </form>
        <% } %>
    </section>

    <% if (selectedCourseId != null && !selectedCourseId.isEmpty()) { %>
    <section class="assignment-list">
        <h3>과제 목록</h3>
        <% if (assignments.isEmpty()) { %>
        <p>등록된 과제가 없습니다.</p>
        <% } else { %>
        <table class="data-table">
            <thead>
                <tr>
                    <th>제목</th>
                    <th>등록일</th>
                    <th>마감일</th>
                    <th>제출 현황</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% for (Assignment assignment : assignments) { %>
                <tr>
                    <td><%= assignment.getTitle() %></td>
                    <td><%= assignment.getCreatedDate() %></td>
                    <td><%= assignment.getDueDate() %></td>
                    <td><%= assignment.getSubmissionCount() %>/<%= assignment.getTotalStudents() %></td>
                    <td>
                        <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn-small">상세</a>
                        <a href="assignment_edit.jsp?id=<%= assignment.getId() %>" class="btn-small">수정</a>
                        <a href="assignment_delete.jsp?id=<%= assignment.getId() %>" class="btn-small btn-danger" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </section>
    <% } %>
</main>

<%@ include file="footer.jsp" %>
