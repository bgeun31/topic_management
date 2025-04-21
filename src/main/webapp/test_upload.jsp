<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.util.FileUtil" %>
<%@ page import="jakarta.servlet.http.Part" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>파일 업로드 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #333; }
        .container { max-width: 800px; margin: 0 auto; }
        .file-list { margin: 20px 0; background: #f5f5f5; padding: 10px; border-radius: 5px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input[type="file"] { padding: 5px; }
        button { padding: 8px 16px; background: #4b70dd; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background: #3759c2; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <h1>파일 업로드 테스트</h1>
        
        <% 
        // D:\uploads 폴더 확인
        String uploadDir = "D:\\uploads";
        File uploadFolder = new File(uploadDir);
        
        if (!uploadFolder.exists()) {
            out.println("<p class='error'>D:\\uploads 폴더가 존재하지 않습니다. 수동으로 생성해주세요.</p>");
        } else {
            out.println("<p class='success'>D:\\uploads 폴더 확인됨. 쓰기 권한: " + uploadFolder.canWrite() + "</p>");
            
            // 폴더 내 파일 목록 표시
            File[] files = uploadFolder.listFiles();
            if (files != null && files.length > 0) {
                out.println("<div class='file-list'>");
                out.println("<h2>D:\\uploads 폴더 내 파일 목록 (" + files.length + "개)</h2>");
                out.println("<ul>");
                for (File file : files) {
                    if (file.isFile()) {
                        out.println("<li>" + file.getName() + " (" + (file.length() / 1024) + " KB)</li>");
                    }
                }
                out.println("</ul>");
                out.println("</div>");
            } else {
                out.println("<p>D:\\uploads 폴더에 파일이 없습니다.</p>");
            }
        }
        
        // 파일 업로드 처리
        String message = null;
        if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
            try {
                Collection<Part> parts = request.getParts();
                Collection<Part> fileParts = new ArrayList<>();
                
                for (Part part : parts) {
                    if (part != null && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                        fileParts.add(part);
                    }
                }
                
                if (!fileParts.isEmpty()) {
                    List<Map<String, String>> uploadedFiles = FileUtil.uploadMultipleFiles(fileParts, "test");
                    
                    if (uploadedFiles != null && !uploadedFiles.isEmpty()) {
                        message = "✅ " + uploadedFiles.size() + "개의 파일이 성공적으로 업로드되었습니다.";
                        out.println("<p class='success'>" + message + "</p>");
                        
                        out.println("<div class='file-list'>");
                        out.println("<h2>업로드된 파일 정보</h2>");
                        out.println("<ul>");
                        for (Map<String, String> fileInfo : uploadedFiles) {
                            out.println("<li>원본 파일명: " + fileInfo.get("originalFileName") + "<br>");
                            out.println("저장된 파일명: " + fileInfo.get("savedFileName") + "<br>");
                            out.println("파일 경로: " + fileInfo.get("filePath") + "<br>");
                            out.println("MIME 타입: " + fileInfo.get("contentType") + "</li>");
                        }
                        out.println("</ul>");
                        out.println("</div>");
                    } else {
                        message = "❌ 파일 업로드 결과가 비어있습니다.";
                        out.println("<p class='error'>" + message + "</p>");
                    }
                }
            } catch (Exception e) {
                message = "❌ 파일 업로드 중 오류가 발생했습니다: " + e.getMessage();
                out.println("<p class='error'>" + message + "</p>");
                e.printStackTrace();
            }
        }
        %>
        
        <h2>파일 업로드 폼</h2>
        <form action="test_upload.jsp" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="files">파일 선택:</label>
                <input type="file" id="files" name="files" multiple>
            </div>
            <button type="submit">업로드</button>
        </form>
        
        <p>업로드된 파일은 D:\uploads 폴더에 저장됩니다.</p>
        <p><a href="test_image.jsp">이미지 테스트 페이지로 이동</a></p>
    </div>
</body>
</html> 