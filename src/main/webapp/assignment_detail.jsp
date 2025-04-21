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
    
    if (course == null) {
        if (userType.equals("professor")) {
            response.sendRedirect("assignment_management.jsp");
        } else {
            response.sendRedirect("assignment_list.jsp");
        }
        return;
    }
    
    // 교수인 경우 권한 확인
    if (userType.equals("professor")) {
        if (course.getProfessorId() != (Integer) session.getAttribute("userId")) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }
    }
    
    // 학생인 경우 수강 여부 확인
    if (userType.equals("student")) {
        int studentId = (Integer) session.getAttribute("userId");
        EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
        boolean isEnrolled = enrollmentDAO.isEnrolled(studentId, assignment.getCourseId());
        
        if (!isEnrolled) {
            response.sendRedirect("assignment_list.jsp");
            return;
        }
    }
    
    // 제출 정보 가져오기
    List<Submission> submissions = new ArrayList<>();
    Submission studentSubmission = null;
    
    if (userType.equals("professor")) {
        // 교수인 경우 모든 제출 정보 가져오기
        SubmissionDAO submissionDAO = new SubmissionDAO();
        submissions = submissionDAO.getSubmissionsByAssignment(Integer.parseInt(assignmentId));
    } else if (userType.equals("student")) {
        // 학생인 경우 자신의 제출 정보 가져오기
        int studentId = (Integer) session.getAttribute("userId");
        SubmissionDAO submissionDAO = new SubmissionDAO();
        studentSubmission = submissionDAO.getSubmission(studentId, Integer.parseInt(assignmentId));
    }
    
    // 성공 메시지 확인
    String success = request.getParameter("success");
%>

<main>
    <section class="content-header">
        <h2><i class="fas fa-tasks"></i> 과제 상세</h2>
        <div class="action-buttons">
            <% if (userType.equals("professor")) { %>
                <a href="assignment_management.jsp?courseId=<%= assignment.getCourseId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 목록으로</a>
                <a href="assignment_edit.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-edit"></i> 수정</a>
                <a href="assignment_delete.jsp?id=<%= assignment.getId() %>" class="btn btn-danger" onclick="return confirm('정말 삭제하시겠습니까? 모든 제출 정보도 함께 삭제됩니다.');"><i class="fas fa-trash-alt"></i> 삭제</a>
            <% } else { %>
                <a href="assignment_list.jsp?courseId=<%= assignment.getCourseId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 목록으로</a>
            <% } %>
        </div>
    </section>
    
    <% if (success != null) { %>
        <div class="success-message">
            <% if (success.equals("submit")) { %>
                <i class="fas fa-check-circle"></i> 과제가 성공적으로 제출되었습니다.
            <% } else if (success.equals("grade")) { %>
                <i class="fas fa-check-circle"></i> 성적이 성공적으로 등록되었습니다.
            <% } %>
        </div>
    <% } %>
    
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
    
    <% if (userType.equals("student")) { %>
        <section class="submission-info">
            <h3><i class="fas fa-upload"></i> 제출 정보</h3>
            <% if (studentSubmission != null) { %>
                <div class="info-box">
                    <p><i class="fas fa-calendar-check"></i> <strong>제출일:</strong> <%= studentSubmission.getSubmissionDate() %></p>
                    <p><i class="fas fa-comment"></i> <strong>내용:</strong> <%= studentSubmission.getContent() %></p>
                    <% if (studentSubmission.getFileName() != null && !studentSubmission.getFileName().isEmpty()) { %>
                        <p><i class="fas fa-file-alt"></i> <strong>첨부 파일:</strong> <a href="download.jsp?type=submission&id=<%= studentSubmission.getId() %>"><%= studentSubmission.getFileName() %></a></p>
                    <% } %>
                    <% if (studentSubmission.getGrade() != null && !studentSubmission.getGrade().isEmpty()) { %>
                        <p><i class="fas fa-star"></i> <strong>성적:</strong> <%= studentSubmission.getGrade() %></p>
                        <% if (studentSubmission.getFeedback() != null && !studentSubmission.getFeedback().isEmpty()) { %>
                            <p><i class="fas fa-comment-dots"></i> <strong>피드백:</strong> <%= studentSubmission.getFeedback() %></p>
                        <% } %>
                    <% } %>
                </div>
                <div class="action-buttons">
                    <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-sync-alt"></i> 재제출</a>
                </div>
            <% } else { %>
                <p>아직 제출하지 않았습니다.</p>
                <div class="action-buttons">
                    <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn btn-primary"><i class="fas fa-upload"></i> 제출하기</a>
                </div>
            <% } %>
        </section>
    <% } else if (userType.equals("professor")) { %>
        <section class="submissions-list">
            <h3><i class="fas fa-list"></i> 제출 목록</h3>
            <% if (submissions.isEmpty()) { %>
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
                            <% for (Submission submission : submissions) { %>
                                <tr>
                                    <td><%= submission.getStudentName() %></td>
                                    <td><%= submission.getSubmissionDate() %></td>
                                    <td>
                                        <% if (submission.getFileName() != null && !submission.getFileName().isEmpty()) { %>
                                            <a href="download.jsp?type=submission&id=<%= submission.getId() %>"><%= submission.getFileName() %></a>
                                        <% } else { %>
                                            -
                                        <% } %>
                                    </td>
                                    <td><%= submission.getGrade() != null && !submission.getGrade().isEmpty() ? submission.getGrade() : "미채점" %></td>
                                    <td class="actions">
                                        <a href="submission_view.jsp?id=<%= submission.getId() %>" class="btn-small" title="상세보기"><i class="fas fa-eye"></i></a>
                                        <a href="grade_form.jsp?id=<%= submission.getId() %>" class="btn-small" title="채점"><i class="fas fa-star"></i></a>
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
