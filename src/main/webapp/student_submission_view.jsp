<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인 (학생만 접근 가능)
    if (userType == null || !userType.equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int studentId = (Integer) session.getAttribute("userId");
    
    // 과제 ID 확인
    String assignmentId = request.getParameter("id");
    if (assignmentId == null || assignmentId.isEmpty()) {
        response.sendRedirect("assignment_list.jsp");
        return;
    }
    
    // 과제 정보 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    Assignment assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
    
    if (assignment == null) {
        response.sendRedirect("assignment_list.jsp");
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(assignment.getCourseId());
    
    if (course == null) {
        response.sendRedirect("assignment_list.jsp");
        return;
    }
    
    // 수강 여부 확인
    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    boolean isEnrolled = enrollmentDAO.isEnrolled(studentId, assignment.getCourseId());
    
    if (!isEnrolled) {
        response.sendRedirect("assignment_list.jsp");
        return;
    }
    
    // 제출 정보 가져오기
    SubmissionDAO submissionDAO = new SubmissionDAO();
    Submission submission = submissionDAO.getSubmission(studentId, Integer.parseInt(assignmentId));
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "내 제출물 - 과제 관리 시스템");
%>

<main>
    <section class="content-header">
        <h2><i class="fas fa-file-alt"></i> 내 제출물</h2>
        <div class="action-buttons">
            <a href="assignment_list.jsp?courseId=<%= assignment.getCourseId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 목록으로</a>
            <% if (submission == null) { %>
                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn btn-primary"><i class="fas fa-upload"></i> 제출하기</a>
            <% } else { %>
                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-sync-alt"></i> 재제출</a>
            <% } %>
        </div>
    </section>
    
    <section class="assignment-info">
        <h3><i class="fas fa-info-circle"></i> 과제 정보</h3>
        <div class="info-box">
            <p><i class="fas fa-book"></i> <strong>과목:</strong> <%= course.getCourseName() %> (<%= course.getSemester() %>)</p>
            <p><i class="fas fa-heading"></i> <strong>제목:</strong> <%= assignment.getTitle() %></p>
            <p><i class="fas fa-calendar-plus"></i> <strong>등록일:</strong> <%= assignment.getCreatedDate() %></p>
            <p><i class="fas fa-calendar-times"></i> <strong>마감일:</strong> <%= assignment.getDueDate() %></p>
            <p><i class="fas fa-align-left"></i> <strong>설명:</strong> <%= assignment.getDescription() %></p>
            <% if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
                <p><i class="fas fa-file-alt"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=assignment&id=<%= assignment.getId() %>"><%= assignment.getFileName() %></a></p>
            <% } %>
        </div>
    </section>
    
    <% if (submission != null) { %>
        <section class="submission-info">
            <h3><i class="fas fa-upload"></i> 제출 정보</h3>
            <div class="info-box">
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
    <% } else { %>
        <section class="no-submission">
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i> 아직 제출하지 않은 과제입니다.
            </div>
        </section>
    <% } %>
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

.alert-warning {
    background-color: #fff9e6;
    border: 1px solid #ffe7a0;
    color: #856404;
    padding: 15px;
    border-radius: 4px;
    margin: 20px 0;
}
</style>

<%@ include file="footer.jsp" %> 