<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }

    int professorId = (Integer) session.getAttribute("userId");

    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getCoursesByProfessor(professorId);

    String assignmentId = request.getParameter("id");
    boolean isEdit = assignmentId != null && !assignmentId.isEmpty();
    String title = isEdit ? "과제 수정" : "새 과제 등록";
    request.setAttribute("pageTitle", title + " - 과제 관리 시스템");

    Assignment assignment = null;
    List<Map<String, Object>> attachments = null;
    
    if (isEdit) {
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        assignment = assignmentDAO.getAssignmentById(Integer.parseInt(assignmentId));
        if (assignment == null) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }
        Course course = courseDAO.getCourseById(assignment.getCourseId());
        if (course == null || course.getProfessorId() != professorId) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }
        
        // 첨부파일 목록 가져오기
        AttachmentDAO attachmentDAO = new AttachmentDAO();
        attachments = attachmentDAO.getAttachmentsByAssignmentId(Integer.parseInt(assignmentId));
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/button-override.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .file-input-container {
            margin-bottom: 10px;
        }
        .add-file-btn {
            margin-top: 5px;
            display: inline-block;
            padding: 5px 10px;
            font-size: 14px;
            cursor: pointer;
        }
        .attachment-list {
            margin-top: 10px;
        }
        .attachment-list li {
            margin-bottom: 5px;
        }
        .remove-file {
            color: red;
            cursor: pointer;
            margin-left: 10px;
        }
    </style>
</head>
<body>
<div class="container">
    <jsp:include page="header.jsp" />

    <main>
        <section class="form-container">
            <h2><i class="fas fa-edit"></i> <%= title %></h2>
            <form action="<%= isEdit ? "assignmentUpdate" : "assignmentAdd" %>" method="post" enctype="multipart/form-data">

                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= assignment.getId() %>">
                    <input type="hidden" name="courseId" value="<%= assignment.getCourseId() %>">
                <% } %>

                <div class="form-group">
                    <label for="courseId">과목:</label>
                    <select id="courseId" name="courseId" required <%= isEdit ? "disabled" : "" %>>
                        <option value="">과목을 선택하세요</option>
                        <% for (Course course : courses) { %>
                            <option value="<%= course.getId() %>" <%= isEdit && assignment.getCourseId() == course.getId() ? "selected" : "" %>>
                                <%= course.getCourseName() %> (<%= course.getSemester() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="title">제목:</label>
                    <input type="text" id="title" name="title" required value="<%= isEdit ? assignment.getTitle() : "" %>">
                </div>

                <div class="form-group">
                    <label for="description">설명:</label>
                    <textarea id="description" name="description" rows="6" required><%= isEdit ? assignment.getDescription() : "" %></textarea>
                </div>

                <div class="form-group">
                    <label for="dueDate">마감일:</label>
                    <input type="date" id="dueDate" name="dueDate" required value="<%= isEdit ? assignment.getDueDate() : "" %>">
                </div>

                <div class="form-group">
                    <label>첨부 파일:</label>
                    <div id="file-inputs-container">
                        <div class="file-input-container">
                            <input type="file" name="files" class="file-input">
                        </div>
                    </div>
                    <a href="javascript:void(0)" id="add-file-btn" class="btn btn-small add-file-btn">
                        <i class="fas fa-plus"></i> 파일 추가
                    </a>
                    
                    <% if (isEdit && assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
                        <p class="file-info">현재 파일: <%= assignment.getFileName() %></p>
                    <% } %>
                    
                    <% if (isEdit && attachments != null && !attachments.isEmpty()) { %>
                        <div class="attachment-list">
                            <p><strong>첨부된 파일 목록:</strong></p>
                            <ul>
                                <% for (Map<String, Object> attachment : attachments) { %>
                                    <li>
                                        <i class="fas fa-file"></i>
                                        <a href="download.jsp?type=attachment&id=<%= attachment.get("id") %>">
                                            <%= attachment.get("originalFileName") %>
                                        </a>
                                        <a href="javascript:void(0)" class="remove-file" 
                                           data-id="<%= attachment.get("id") %>" onclick="deleteAttachment(this)">
                                            <i class="fas fa-trash"></i>
                                        </a>
                                    </li>
                                <% } %>
                            </ul>
                        </div>
                    <% } %>
                </div>

                <div class="form-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas <%= isEdit ? "fa-save" : "fa-plus" %>"></i> <%= isEdit ? "수정" : "등록" %>
                    </button>
                    <a href="assignment_management.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> 취소
                    </a>
                </div>
            </form>
        </section>
    </main>

    <jsp:include page="footer.jsp" />
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // 파일 입력 필드 추가
        document.getElementById('add-file-btn').addEventListener('click', function() {
            var container = document.getElementById('file-inputs-container');
            var fileInputContainer = document.createElement('div');
            fileInputContainer.className = 'file-input-container';
            
            var fileInput = document.createElement('input');
            fileInput.type = 'file';
            fileInput.name = 'files';
            fileInput.className = 'file-input';
            
            var removeBtn = document.createElement('a');
            removeBtn.href = 'javascript:void(0)';
            removeBtn.className = 'remove-file';
            removeBtn.innerHTML = '<i class="fas fa-times"></i>';
            removeBtn.onclick = function() {
                container.removeChild(fileInputContainer);
            };
            
            fileInputContainer.appendChild(fileInput);
            fileInputContainer.appendChild(removeBtn);
            container.appendChild(fileInputContainer);
        });
    });
    
    // 첨부파일 삭제
    function deleteAttachment(element) {
        if (confirm('첨부파일을 삭제하시겠습니까?')) {
            var attachmentId = element.getAttribute('data-id');
            fetch('deleteAttachment?id=' + attachmentId, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 성공적으로 삭제된 경우 해당 항목 제거
                    element.parentElement.remove();
                } else {
                    alert('첨부파일 삭제에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('첨부파일 삭제 중 오류가 발생했습니다.');
            });
        }
    }
</script>
</body>
</html>
