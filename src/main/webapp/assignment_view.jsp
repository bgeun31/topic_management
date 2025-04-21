<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인
    
    if (userType == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 과제 ID 확인
    String assignmentId = request.getParameter("id");
    if (assignmentId == null || assignmentId.isEmpty()) {
        if (userType.equals("professor")) {
            response.sendRedirect("assignment_management.jsp");
        } else {
            response.sendRedirect("assignment_list.jsp");
        }
        return;
    }
    
    // 과제 정보 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    Assignment assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
    
    if (assignment == null) {
        if (userType.equals("professor")) {
            response.sendRedirect("assignment_management.jsp");
        } else {
            response.sendRedirect("assignment_list.jsp");
        }
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(assignment.getCourseId());
    
    // 제출 정보 가져오기 (학생인 경우)
    Submission submission = null;
    if (userType.equals("student")) {
        int studentId = (Integer) session.getAttribute("userId");
        SubmissionDAO submissionDAO = new SubmissionDAO();
        submission = submissionDAO.getSubmission(studentId, Integer.parseInt(assignmentId));
    }
    
    // 모든 제출 정보 가져오기 (교수인 경우)
    List<Submission> submissions = null;
    if (userType.equals("professor")) {
        SubmissionDAO submissionDAO = new SubmissionDAO();
        submissions = submissionDAO.getSubmissionsByAssignment(Integer.parseInt(assignmentId));
    }
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "과제 상세 - 과제 관리 시스템");
%>

        
<main>
    <section class="content-header">
        <h2><i class="fas fa-clipboard-check"></i> 과제 상세</h2>
        <% if (userType.equals("professor")) { %>
        <a href="assignment_management.jsp?courseId=<%= assignment.getCourseId() %>" class="btn">과제 목록으로</a>
        <% } else { %>
        <a href="assignment_list.jsp?courseId=<%= assignment.getCourseId() %>" class="btn">과제 목록으로</a>
        <% } %>
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
            <p><i class="fas fa-paperclip"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=assignment&id=<%= assignment.getId() %>"><%= assignment.getFileName() %></a></p>
            <% } %>
        </div>
    </section>
    
    <% if (userType.equals("student")) { %>
        <section class="submission-info">
            <h3><i class="fas fa-upload"></i> 제출 정보</h3>
            <% if (submission != null) { %>
            <div class="info-box">
                <p><i class="fas fa-calendar-check"></i> <strong>제출일:</strong> <%= submission.getSubmissionDate() %></p>
                <p><i class="fas fa-file-alt"></i> <strong>내용:</strong> <%= submission.getContent() %></p>
                <% if (submission.getFileName() != null && !submission.getFileName().isEmpty()) { %>
                <p><i class="fas fa-paperclip"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=submission&id=<%= submission.getId() %>"><%= submission.getFileName() %></a></p>
                <% } %>
                <% if (submission.getGrade() != null && !submission.getGrade().isEmpty()) { %>
                <p><i class="fas fa-star"></i> <strong>성적:</strong> <%= submission.getGrade() %></p>
                <% if (submission.getFeedback() != null && !submission.getFeedback().isEmpty()) { %>
                <p><i class="fas fa-comment"></i> <strong>피드백:</strong> <%= submission.getFeedback() %></p>
                <% } %>
                <% } %>
            </div>
            <div class="action-buttons">
                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small">재제출</a>
            </div>
            <% } else { %>
            <p>아직 제출하지 않았습니다.</p>
            <div class="action-buttons">
                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small">제출하기</a>
            </div>
            <% } %>
        </section>
    <% } else if (userType.equals("professor")) { %>
        <section class="submissions-list">
            <h3><i class="fas fa-list"></i> 제출 목록</h3>
            <% if (submissions == null || submissions.isEmpty()) { %>
            <p>아직 제출된 과제가 없습니다.</p>
            <% } else { %>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>학생</th>
                            <th>제출일</th>
                            <th>파일</th>
                            <th>성적</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Submission sub : submissions) { %>
                        <tr>
                            <td><%= sub.getStudentName() %></td>
                            <td><%= sub.getSubmissionDate() %></td>
                            <td>
                                <% if (sub.getFileName() != null && !sub.getFileName().isEmpty()) { %>
                                <a href="download.jsp?type=submission&id=<%= sub.getId() %>"><%= sub.getFileName() %></a>
                                <% } else { %>
                                -
                                <% } %>
                            </td>
                            <td><%= sub.getGrade() != null ? sub.getGrade() : "미채점" %></td>
                            <td class="actions">
                                <a href="submission_view.jsp?id=<%= sub.getId() %>" class="btn-small">상세</a>
                                <a href="grade_form.jsp?id=<%= sub.getId() %>" class="btn-small">채점</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </section>
    <% } %>
</main>

<%@ include file="footer.jsp" %>
