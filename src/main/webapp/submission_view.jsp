<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인 (교수만 접근 가능)
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 제출 ID 확인
    String submissionId = request.getParameter("id");
    if (submissionId == null || submissionId.isEmpty()) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 제출 정보 가져오기
    SubmissionDAO submissionDAO = new SubmissionDAO();
    Submission submission = submissionDAO.getSubmissionById(Integer.parseInt(submissionId));
    
    if (submission == null) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과제 정보 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    Assignment assignment = assignmentDAO.getAssignmentById(submission.getAssignmentId());
    
    if (assignment == null) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(assignment.getCourseId());
    
    if (course == null) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 교수 권한 확인
    if (course.getProfessorId() != (Integer) session.getAttribute("userId")) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 학생 정보 가져오기
    UserDAO userDAO = new UserDAO();
    User student = userDAO.getUserById(submission.getStudentId());
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "제출 상세 - 과제 관리 시스템");
%>

<main>
    <section class="content-header">
        <h2><i class="fas fa-file-alt"></i> 제출 상세</h2>
        <div class="action-buttons">
            <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 상세로 돌아가기</a>
            <a href="grade_form.jsp?id=<%= submission.getId() %>" class="btn btn-primary"><i class="fas fa-star"></i> 채점하기</a>
        </div>
    </section>
    
    <section class="submission-info">
        <h3><i class="fas fa-info-circle"></i> 제출 정보</h3>
        <div class="info-box">
            <p><i class="fas fa-book"></i> <strong>과목:</strong> <%= course.getCourseName() %> (<%= course.getSemester() %>)</p>
            <p><i class="fas fa-tasks"></i> <strong>과제:</strong> <%= assignment.getTitle() %></p>
            <p><i class="fas fa-user"></i> <strong>학생:</strong> <%= student.getName() %> (<%= student.getUsername() %>)</p>
            <p><i class="fas fa-calendar-check"></i> <strong>제출일:</strong> <%= submission.getSubmissionDate() %></p>
            <p><i class="fas fa-comment"></i> <strong>내용:</strong></p>
            <div class="submission-content">
                <%= submission.getContent() %>
            </div>
            <% if (submission.getFileName() != null && !submission.getFileName().isEmpty()) { %>
                <p><i class="fas fa-file-alt"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=submission&id=<%= submission.getId() %>"><%= submission.getFileName() %></a></p>
            <% } %>
            <% if (submission.getGrade() != null && !submission.getGrade().isEmpty()) { %>
                <div class="grade-info">
                    <p><i class="fas fa-star"></i> <strong>성적:</strong> <%= submission.getGrade() %></p>
                    <% if (submission.getFeedback() != null && !submission.getFeedback().isEmpty()) { %>
                        <p><i class="fas fa-comment-dots"></i> <strong>피드백:</strong></p>
                        <div class="feedback-content">
                            <%= submission.getFeedback() %>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <p class="no-grade"><i class="fas fa-exclamation-circle"></i> 아직 채점되지 않았습니다.</p>
            <% } %>
        </div>
    </section>
</main>

<style>
.submission-content, .feedback-content {
    padding: 15px;
    margin: 10px 0;
    background-color: #f9f9f9;
    border: 1px solid #eee;
    border-radius: 4px;
    white-space: pre-wrap;
}

.grade-info {
    margin-top: 20px;
    padding: 15px;
    background-color: #f0f7ff;
    border: 1px solid #cce5ff;
    border-radius: 4px;
}

.no-grade {
    margin-top: 20px;
    padding: 10px;
    background-color: #fff9e6;
    border: 1px solid #ffe7a0;
    border-radius: 4px;
    color: #856404;
}
</style>

<%@ include file="footer.jsp" %> 