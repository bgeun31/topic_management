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
    
    // 선택된 과목에 대한 과제 목록 가져오기
    String selectedCourseId = request.getParameter("courseId");
    List<Assignment> assignments = new ArrayList<>();
    
    if (selectedCourseId != null && !selectedCourseId.isEmpty()) {
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        assignments = assignmentDAO.getAssignmentsByCourse(Integer.parseInt(selectedCourseId));
        
        // 각 과제에 대한 제출 상태 확인
        SubmissionDAO submissionDAO = new SubmissionDAO();
        for (Assignment assignment : assignments) {
            Submission submission = submissionDAO.getSubmission(studentId, assignment.getId());
            if (submission != null) {
                assignment.setSubmitted(true);
                assignment.setSubmissionDate(submission.getSubmissionDate());
            } else {
                assignment.setSubmitted(false);
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>과제 목록 - 과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="container">
        <main>
            <section class="content-header">
                <h2>과제 목록</h2>
            </section>
            
            <section class="course-selector">
                <h3>과목 선택</h3>
                <% if (enrolledCourses.isEmpty()) { %>
                <p>수강 중인 과목이 없습니다. <a href="course_list.jsp">과목을 먼저 수강신청</a>해주세요.</p>
                <% } else { %>
                <form action="assignment_list.jsp" method="get">
                    <div class="form-group">
                        <select name="courseId" onchange="this.form.submit()">
                            <option value="">과목을 선택하세요</option>
                            <% for (Course course : enrolledCourses) { %>
                            <option value="<%= course.getId() %>" <%= selectedCourseId != null && selectedCourseId.equals(String.valueOf(course.getId())) ? "selected" : "" %>>
                                <%= course.getCourseName() %> (<%= course.getProfessorName() %>)
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
                            <th>상태</th>
                            <th>액션</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Assignment assignment : assignments) { %>
                        <tr>
                            <td><%= assignment.getTitle() %></td>
                            <td><%= assignment.getCreatedDate() %></td>
                            <td><%= assignment.getDueDate() %></td>
                            <td>
                                <% if (assignment.isSubmitted()) { %>
                                <span class="status-submitted">제출 완료 (<%= assignment.getSubmissionDate() %>)</span>
                                <% } else { %>
                                <span class="status-pending">미제출</span>
                                <% } %>
                            </td>
                            <td>
                                <a href="assignment_view.jsp?id=<%= assignment.getId() %>" class="btn-small">보기</a>
                                <% if (!assignment.isSubmitted()) { %>
                                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small btn-primary">제출</a>
                                <% } else { %>
                                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small">재제출</a>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </section>
            <% } %>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
