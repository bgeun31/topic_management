<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>업로드 폴더 확인</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #333; }
        .container { max-width: 800px; margin: 0 auto; }
        .file-list { margin: 20px 0; background: #f5f5f5; padding: 10px; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        tr:hover { background-color: #f9f9f9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>업로드 폴더 확인</h1>
        
        <% 
       
        String externalDir = "D:\\uploads\\sskm0116";
        File externalFolder = new File(externalDir);
        
        if (!externalFolder.exists()) {
            out.println("<p class='error'>외부 폴더가 존재하지 않습니다: " + externalDir + "</p>");
        } else {
            out.println("<p class='success'>외부 폴더 확인됨: " + externalDir + "</p>");
            out.println("<p>쓰기 권한: " + externalFolder.canWrite() + "</p>");
            
            // 파일 목록 표시
            File[] files = externalFolder.listFiles();
            if (files != null && files.length > 0) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                
                out.println("<h2>외부 폴더 파일 목록 (" + files.length + "개)</h2>");
                out.println("<table>");
                out.println("<tr><th>파일명</th><th>크기</th><th>수정일</th></tr>");
                
                for (File file : files) {
                    if (file.isFile()) {
                        out.println("<tr>");
                        out.println("<td>" + file.getName() + "</td>");
                        out.println("<td>" + (file.length() / 1024) + " KB</td>");
                        out.println("<td>" + sdf.format(new Date(file.lastModified())) + "</td>");
                        out.println("</tr>");
                    }
                }
                
                out.println("</table>");
            } else {
                out.println("<p>외부 폴더에 파일이 없습니다.</p>");
            }
        }
        
        // 웹 애플리케이션 내부 폴더 확인
        String internalDir = application.getRealPath("/uploads/sskm0116");
        File internalFolder = new File(internalDir);
        
        out.println("<h2>웹 애플리케이션 내부 폴더</h2>");
        out.println("<p>경로: " + internalDir + "</p>");
        
        if (!internalFolder.exists()) {
            out.println("<p class='error'>내부 폴더가 존재하지 않습니다.</p>");
        } else {
            out.println("<p class='success'>내부 폴더 확인됨</p>");
            
            // 파일 목록 표시
            File[] webFiles = internalFolder.listFiles();
            if (webFiles != null && webFiles.length > 0) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                
                out.println("<h3>내부 폴더 파일 목록 (" + webFiles.length + "개)</h3>");
                out.println("<table>");
                out.println("<tr><th>파일명</th><th>크기</th><th>수정일</th></tr>");
                
                for (File file : webFiles) {
                    if (file.isFile()) {
                        out.println("<tr>");
                        out.println("<td>" + file.getName() + "</td>");
                        out.println("<td>" + (file.length() / 1024) + " KB</td>");
                        out.println("<td>" + sdf.format(new Date(file.lastModified())) + "</td>");
                        out.println("</tr>");
                    }
                }
                
                out.println("</table>");
            } else {
                out.println("<p>내부 폴더에 파일이 없습니다.</p>");
            }
        }
        %>
        
        <p><a href="test_image.jsp">이미지 테스트 페이지로 이동</a></p>
    </div>
</body>
</html> 