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
    
    // 학생이 해당 과목을 수강 중인지 확인
    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    boolean isEnrolled = enrollmentDAO.isEnrolled(studentId, assignment.getCourseId());
    
    if (!isEnrolled) {
        response.sendRedirect("assignment_list.jsp");
        return;
    }
    
    // 이전 제출 정보 가져오기
    SubmissionDAO submissionDAO = new SubmissionDAO();
    Submission submission = submissionDAO.getSubmission(studentId, Integer.parseInt(assignmentId));
    boolean isResubmission = submission != null;
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", (isResubmission ? "과제 재제출" : "과제 제출") + " - 과제 관리 시스템");
%>

        
<main>
    <section class="content-header">
        <h2><i class="fas fa-upload"></i> <%= isResubmission ? "과제 재제출" : "과제 제출" %></h2>
        <a href="assignment_list.jsp?courseId=<%= assignment.getCourseId() %>" class="btn"><i class="fas fa-arrow-left"></i> 목록으로</a>
    </section>
    
    <section class="assignment-info">
        <h3><i class="fas fa-info-circle"></i> 과제 정보</h3>
        <div class="info-box">
            <p><i class="fas fa-heading"></i> <strong>제목:</strong> <%= assignment.getTitle() %></p>
            <p><i class="fas fa-calendar-times"></i> <strong>마감일:</strong> <%= assignment.getDueDate() %></p>
            <p><i class="fas fa-align-left"></i> <strong>설명:</strong> <%= assignment.getDescription() %></p>
            <% if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
            <p><i class="fas fa-paperclip"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=assignment&id=<%= assignment.getId() %>"><%= assignment.getFileName() %></a></p>
            <% } %>
        </div>
    </section>
    
    <section class="form-container">
        <h3><i class="fas fa-paper-plane"></i> <%= isResubmission ? "과제 재제출" : "과제 제출" %></h3>
        <form action="submissionProcess" method="post" enctype="multipart/form-data">
            <input type="hidden" name="assignmentId" value="<%= assignment.getId() %>">
            <input type="hidden" name="courseId" value="<%= assignment.getCourseId() %>">
            
            <div class="form-group">
                <label for="content"><i class="fas fa-file-alt"></i> 내용:</label>
                <textarea id="content" name="content" rows="6" required><%= isResubmission ? submission.getContent() : "" %></textarea>
            </div>
            
            <div class="form-group">
                <label for="file"><i class="fas fa-paperclip"></i> 첨부 파일:</label>
                <input type="file" id="file" name="file">
                <% if (isResubmission && submission.getFileName() != null && !submission.getFileName().isEmpty()) { %>
                <p class="file-info">현재 파일: <%= submission.getFileName() %></p>
                <% } %>
            </div>
            
            <div class="form-group">
                <button type="submit" class="btn">제출</button>
                <a href="assignment_list.jsp?courseId=<%= assignment.getCourseId() %>" class="btn btn-secondary">취소</a>
            </div>
        </form>
    </section>
</main>

<%@ include file="footer.jsp" %>
