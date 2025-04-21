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
    
    // 첨부 파일 정보 가져오기
    AttachmentDAO attachmentDAO = new AttachmentDAO();
    List<Attachment> attachments = attachmentDAO.getAttachmentsByRef(assignment.getId(), "assignment");
    
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
                <label for="files"><i class="fas fa-file-upload"></i> 새 첨부 파일 추가:</label>
                <input type="file" id="files" name="files" multiple>
                <p class="help-text">여러 파일을 한 번에 선택하여 업로드할 수 있습니다.</p>
            </div>
            
            <% if (!attachments.isEmpty()) { %>
                <div class="form-group">
                    <label><i class="fas fa-paperclip"></i> 현재 첨부 파일:</label>
                    <div class="attachment-cards">
                        <% for (Attachment attachment : attachments) { %>
                            <div class="attachment-card">
                                <% if (attachment.isImage()) { %>
                                    <div class="attachment-preview">
                                        <img src="<%= attachment.getFilePath() %>" alt="<%= attachment.getFileName() %>">
                                    </div>
                                <% } else { %>
                                    <div class="attachment-icon">
                                        <i class="bi <%= com.assignment.util.FileUtil.getFileIconClass(attachment.getFileType(), attachment.getFileName()) %>"></i>
                                    </div>
                                <% } %>
                                <div class="attachment-info">
                                    <span class="attachment-filename"><%= attachment.getFileName() %></span>
                                </div>
                                <div class="attachment-actions">
                                    <a href="javascript:void(0)" class="btn-small delete-file" data-id="<%= attachment.getId() %>" onclick="deleteAttachment(this)">
                                        <i class="fas fa-trash"></i> 파일 삭제
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } else if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) { %>
                <!-- 기존 단일 파일 첨부 지원 (하위 호환성) -->
                <div class="form-group">
                    <label><i class="fas fa-paperclip"></i> 현재 첨부 파일:</label>
                    <p class="file-info"><%= assignment.getFileName() %></p>
                    <a href="javascript:void(0)" class="btn-small delete-file" onclick="deleteOriginalFile()">
                        <i class="fas fa-trash"></i> 파일 삭제
                    </a>
                </div>
            <% } %>
            
            <div class="form-group">
                <button type="submit" class="btn"><i class="fas fa-save"></i> 저장</button>
                <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn btn-secondary"><i class="fas fa-times"></i> 취소</a>
            </div>
        </form>
    </section>
</main>

<style>
.attachment-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-top: 10px;
}

.attachment-card {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 12px;
    width: 200px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    background-color: #fff;
    display: flex;
    flex-direction: column;
}

.attachment-preview {
    height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    margin-bottom: 10px;
    background-color: #f8f9fa;
    border-radius: 4px;
}

.attachment-preview img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.attachment-icon {
    height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 10px;
    font-size: 3rem;
    color: #6c757d;
    background-color: #f8f9fa;
    border-radius: 4px;
}

.attachment-info {
    margin-bottom: 10px;
}

.attachment-filename {
    font-size: 0.9rem;
    word-break: break-all;
    display: block;
}

.attachment-actions {
    margin-top: auto;
}
</style>

<script>
// 첨부파일 삭제 처리
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
                element.closest('.attachment-card').remove();
            } else {
                alert('첨부파일 삭제에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('첨부파일 삭제 중 오류가 발생했습니다.');
        });
    }
}

// 기존 단일 파일 삭제 처리
function deleteOriginalFile() {
    if (confirm('현재 첨부된 파일을 삭제하시겠습니까?')) {
        // 숨겨진 필드 추가하여 원본 파일 삭제 표시
        var form = document.querySelector('form');
        var hiddenField = document.createElement('input');
        hiddenField.type = 'hidden';
        hiddenField.name = 'removeFile';
        hiddenField.value = 'true';
        form.appendChild(hiddenField);
        
        // 화면에서 파일 정보와 삭제 버튼 제거
        var fileInfoContainer = document.querySelector('.file-info').parentNode;
        fileInfoContainer.innerHTML = '<p>파일이 삭제됩니다. 변경사항을 저장하려면 저장 버튼을 클릭하세요.</p>';
    }
}

// 파일 입력 필드 처리 (여러 파일 선택 시 모든 파일 표시)
document.getElementById('files').addEventListener('change', function(e) {
    var fileList = e.target.files;
    var filesInfo = document.createElement('div');
    filesInfo.className = 'selected-files-info';
    
    if (fileList.length > 0) {
        var fileListHeader = document.createElement('p');
        fileListHeader.innerHTML = '<strong>선택된 파일:</strong>';
        filesInfo.appendChild(fileListHeader);
        
        var fileListUl = document.createElement('ul');
        for (var i = 0; i < fileList.length; i++) {
            var fileItem = document.createElement('li');
            fileItem.textContent = fileList[i].name;
            fileListUl.appendChild(fileItem);
        }
        filesInfo.appendChild(fileListUl);
        
        // 기존 파일 정보 제거 후 새 파일 정보 추가
        var existingInfo = document.querySelector('.selected-files-info');
        if (existingInfo) {
            existingInfo.remove();
        }
        
        this.parentNode.appendChild(filesInfo);
    }
});
</script>

<%@ include file="footer.jsp" %>