<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %>
<%
    // 로그인 확인 및 교수 권한 확인
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int professorId = (Integer) session.getAttribute("userId");
    
    // 과제 ID 확인
    String assignmentId = request.getParameter("id");
    if (assignmentId == null || assignmentId.isEmpty()) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과제 정보 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    Assignment assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
    
    if (assignment == null) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(assignment.getCourseId());
    
    // 권한 확인 (해당 과목의 교수인지)
    if (course == null || course.getProfessorId() != professorId) {
        response.sendRedirect("assignment_management.jsp");
        return;
    }
    
    // 에러 메시지 확인
    String error = request.getParameter("error");
%>

<main>
    <section class="content-header">
        <h2><i class="fas fa-edit"></i> 과제 수정</h2>
        <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn"><i class="fas fa-arrow-left"></i> 과제 상세로 돌아가기</a>
    </section>
    
    <% if (error != null) { %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i> 과제 수정 중 오류가 발생했습니다.
        </div>
    <% } %>
    
    <section class="form-container">
        <h3><i class="fas fa-tasks"></i> 과제 정보 수정</h3>
        <form action="assignmentUpdate" method="post" enctype="multipart/form-data">
            <input type="hidden" name="id" value="<%= assignment.getId() %>">
            <input type="hidden" name="courseId" value="<%= assignment.getCourseId() %>">
            
            <div class="form-group">
                <label for="title"><i class="fas fa-heading"></i> 제목:</label>
                <input type="text" id="title" name="title" value="<%= assignment.getTitle() %>" required>
            </div>
            
            <div class="form-group">
                <label for="description"><i class="fas fa-align-left"></i> 설명:</label>
                <textarea id="description" name="description" rows="6" required><%= assignment.getDescription() %></textarea>
            </div>
            
            <div class="form-group">
                <label for="dueDate"><i class="fas fa-calendar-times"></i> 마감일:</label>
                <input type="date" id="dueDate" name="dueDate" value="<%= assignment.getDueDate() %>" required>
            </div>
            
            <div class="form-group">
                <label for="file"><i class="fas fa-file-upload"></i> 첨부 파일:</label>
                <input type="file" id="file" name="file">
                <% if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
                    <p class="file-info">현재 파일: <%= assignment.getFileName() %></p>
                    <div class="checkbox-group">
                        <input type="checkbox" id="removeFile" name="removeFile" value="true">
                        <label for="removeFile">파일 삭제</label>
                    </div>
                <% } %>
                <p class="help-text">새 파일을 업로드하면 기존 파일은 대체됩니다.</p>
            </div>
            
            <div class="form-group">
                <button type="submit" class="btn"><i class="fas fa-save"></i> 저장</button>
                <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn btn-secondary"><i class="fas fa-times"></i> 취소</a>
            </div>
        </form>
    </section>
</main>

<%@ include file="footer.jsp" %>