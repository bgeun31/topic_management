<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.util.FileUtil" %>
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
    
    // 첨부파일 정보 가져오기
    AttachmentDAO attachmentDAO = new AttachmentDAO();
    List<Attachment> attachments = attachmentDAO.getAttachmentsByRef(Integer.parseInt(assignmentId), "assignment");
    
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
            
            <% if (!attachments.isEmpty()) { %>
                <div class="attachment-section">
                    <h4><i class="fas fa-paperclip"></i> 첨부파일 목록</h4>
                    <div class="attachment-grid">
                        <% for (Attachment attachment : attachments) { %>
                            <% 
                            String contentType = attachment.getFileType();
                            String fileName = attachment.getFileName();
                            String iconClass = FileUtil.getFileIconClass(contentType, fileName);
                            boolean isImage = attachment.isImage();
                            String fileExt = "";
                            if (fileName.contains(".")) {
                                fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toUpperCase();
                            }
                            %>
                            <div class="attachment-card">
                                <div class="attachment-card-content">
                                    <% if (isImage) { %>
                                        <div class="attachment-preview">
                                            <img src="download.jsp?type=attachment&id=<%= attachment.getId() %>" alt="<%= fileName %>" />
                                        </div>
                                    <% } else { %>
                                        <div class="attachment-icon">
                                            <i class="<%= iconClass %>"></i>
                                            <span class="file-ext"><%= fileExt %></span>
                                        </div>
                                    <% } %>
                                    <div class="attachment-details">
                                        <div class="file-name" title="<%= fileName %>"><%= fileName %></div>
                                        <div class="file-meta">
                                            <span class="upload-date"><i class="fas fa-calendar-alt"></i> <%= attachment.getUploadDate().substring(0, 10) %></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="attachment-actions">
                                    <a href="download.jsp?type=attachment&id=<%= attachment.getId() %>" class="download-btn">
                                        <i class="fas fa-download"></i> 다운로드
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
                
                <style>
                    .attachment-section {
                        margin-top: 20px;
                        border: 1px solid #e0e0e0;
                        border-radius: 8px;
                        padding: 20px;
                        background-color: #f9f9f9;
                    }
                    
                    .attachment-section h4 {
                        margin-top: 0;
                        margin-bottom: 15px;
                        color: #333;
                        font-size: 1.2rem;
                        border-bottom: 1px solid #e0e0e0;
                        padding-bottom: 10px;
                    }
                    
                    .attachment-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 15px;
                    }
                    
                    .attachment-card {
                        background: white;
                        border-radius: 8px;
                        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
                        overflow: hidden;
                        transition: transform 0.3s, box-shadow 0.3s;
                        display: flex;
                        flex-direction: column;
                        height: 100%;
                    }
                    
                    .attachment-card:hover {
                        transform: translateY(-5px);
                        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                    }
                    
                    .attachment-card-content {
                        padding: 15px;
                        flex: 1;
                    }
                    
                    .attachment-preview {
                        height: 120px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        overflow: hidden;
                        margin-bottom: 10px;
                        background-color: #f0f0f0;
                        border-radius: 4px;
                    }
                    
                    .attachment-preview img {
                        max-width: 100%;
                        max-height: 100%;
                        object-fit: contain;
                    }
                    
                    .attachment-icon {
                        height: 100px;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        margin-bottom: 10px;
                        background-color: #f5f5f5;
                        border-radius: 4px;
                        position: relative;
                    }
                    
                    .attachment-icon i {
                        font-size: 3rem;
                        color: #555;
                    }
                    
                    .attachment-icon .file-ext {
                        margin-top: 5px;
                        font-size: 0.8rem;
                        background-color: #555;
                        color: white;
                        padding: 2px 5px;
                        border-radius: 3px;
                    }
                    
                    .attachment-details {
                        margin-top: 5px;
                    }
                    
                    .file-name {
                        font-weight: 600;
                        margin-bottom: 5px;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }
                    
                    .file-meta {
                        display: flex;
                        font-size: 0.8rem;
                        color: #777;
                    }
                    
                    .upload-date {
                        display: flex;
                        align-items: center;
                        gap: 5px;
                    }
                    
                    .attachment-actions {
                        padding: 10px 15px;
                        background-color: #f7f7f7;
                        border-top: 1px solid #eee;
                    }
                    
                    .download-btn {
                        display: block;
                        text-align: center;
                        background-color: #4b70dd;
                        color: white;
                        padding: 8px 0;
                        border-radius: 4px;
                        text-decoration: none;
                        font-weight: 500;
                        transition: background-color 0.2s;
                    }
                    
                    .download-btn:hover {
                        background-color: #3759c2;
                    }
                    
                    /* Responsive styles */
                    @media (max-width: 768px) {
                        .attachment-grid {
                            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                        }
                    }
                    
                    @media (max-width: 480px) {
                        .attachment-grid {
                            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
                        }
                        
                        .attachment-icon i {
                            font-size: 2.5rem;
                        }
                    }
                </style>
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
                                        <a href="submission_view.jsp?id=<%= submission.getId() %>" class="btn-small">상세</a>
                                        <a href="grade_form.jsp?id=<%= submission.getId() %>" class="btn-small">채점</a>
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
