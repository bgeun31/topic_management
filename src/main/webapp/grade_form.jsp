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
    request.setAttribute("pageTitle", "채점 - 과제 관리 시스템");
%>

<main>
    <section class="content-header">
        <h2><i class="fas fa-star"></i> 채점</h2>
        <div class="action-buttons">
            <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 상세로 돌아가기</a>
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
        </div>
    </section>
    
    <section class="grade-form">
        <h3><i class="fas fa-pen"></i> 채점하기</h3>
        <form action="gradeProcess" method="post" class="styled-form">
            <input type="hidden" name="submissionId" value="<%= submission.getId() %>">
            <input type="hidden" name="assignmentId" value="<%= assignment.getId() %>">
            <input type="hidden" name="studentId" value="<%= submission.getStudentId() %>">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            
            <div class="form-group">
                <label for="grade"><i class="fas fa-star"></i> 성적:</label>
                <input type="text" id="grade" name="grade" value="<%= submission.getGrade() != null ? submission.getGrade() : "" %>" required>
                <small>점수 또는 등급(A, B, C 등)을 입력하세요.</small>
            </div>
            
            <div class="form-group">
                <label for="feedback"><i class="fas fa-comment-dots"></i> 피드백:</label>
                <textarea id="feedback" name="feedback" rows="6"><%= submission.getFeedback() != null ? submission.getFeedback() : "" %></textarea>
            </div>
            
            <div class="form-group">
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> 저장</button>
                <a href="submission_view.jsp?id=<%= submission.getId() %>" class="btn">취소</a>
            </div>
        </form>
    </section>
</main>

<style>
.submission-content {
    padding: 15px;
    margin: 10px 0;
    background-color: #f9f9f9;
    border: 1px solid #eee;
    border-radius: 4px;
    white-space: pre-wrap;
}

.styled-form {
    background-color: #f8f9fa;
    border: 1px solid #eee;
    border-radius: 5px;
    padding: 20px;
    margin-top: 15px;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: 500;
}

.form-group input[type="text"], 
.form-group textarea {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

.form-group small {
    display: block;
    margin-top: 5px;
    color: #6c757d;
}
</style>

<%@ include file="footer.jsp" %> 