package com.assignment.servlet;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;

import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/files/*")
public class FileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // 파일이 저장된 기본 경로 - 동적으로 설정
    private String getUploadDirectory() {
        // FileUtil의 경로 설정 사용
        return FileUtil.getOSUploadPath();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // URL에서 파일 경로 추출
        String requestedFile = request.getPathInfo();
        System.out.println("FileServlet: 요청된 파일 경로: " + requestedFile);
        
        if (requestedFile == null || requestedFile.equals("/")) {
            System.out.println("FileServlet: 요청 경로가 비어있습니다.");
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // 파일 이름만 추출 (경로의 마지막 부분)
        String fileName = requestedFile.substring(requestedFile.lastIndexOf('/') + 1);
        
        // 업로드 디렉토리 가져오기
        String uploadDirectory = getUploadDirectory();
        System.out.println("FileServlet: 업로드 디렉토리: " + uploadDirectory);
        
        // 여러 위치에서 파일 찾기 시도
        File file = new File(uploadDirectory, fileName);
        System.out.println("FileServlet: 찾는 파일: " + file.getAbsolutePath());
        
        if (!file.exists()) {
            System.out.println("FileServlet: 파일이 존재하지 않습니다: " + file.getAbsolutePath());
            
            // 대체 경로 시도 - 웹 애플리케이션 내부의 uploads 폴더
            String webappUploadsPath = getServletContext().getRealPath("/uploads");
            file = new File(webappUploadsPath, fileName);
            System.out.println("FileServlet: 대체 경로 시도: " + file.getAbsolutePath());
            
            if (!file.exists()) {
                System.out.println("FileServlet: 대체 경로에서도 파일을 찾을 수 없습니다");
                
                // 두 번째 대체 경로 - uploads/{LOGIN_ID} 폴더
                String webappLoginUploadsPath = getServletContext().getRealPath("/uploads/sskm0116");
                file = new File(webappLoginUploadsPath, fileName);
                System.out.println("FileServlet: 두 번째 대체 경로 시도: " + file.getAbsolutePath());
                
                if (!file.exists()) {
                    // 파일을 찾을 수 없음
                    System.out.println("FileServlet: 모든 경로에서 파일을 찾을 수 없습니다");
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            }
        }
        
        // 파일의 MIME 타입 설정
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            // 파일 확장자 기반으로 MIME 타입 추측
            if (file.getName().toLowerCase().endsWith(".jfif")) {
                contentType = "image/jpeg";
            } else if (file.getName().toLowerCase().endsWith(".jpg") || 
                       file.getName().toLowerCase().endsWith(".jpeg")) {
                contentType = "image/jpeg";
            } else if (file.getName().toLowerCase().endsWith(".png")) {
                contentType = "image/png";
            } else if (file.getName().toLowerCase().endsWith(".gif")) {
                contentType = "image/gif"; 
            } else {
                contentType = "application/octet-stream";
            }
        }
        
        System.out.println("FileServlet: 파일 제공: " + file.getName() + " (" + contentType + ")");
        
        // 응답 헤더 설정 - 캐시 비활성화
        response.setContentType(contentType);
        response.setContentLength((int) file.length());
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        // 파일 내용을 응답 스트림으로 복사
        try (BufferedInputStream input = new BufferedInputStream(new FileInputStream(file));
             BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream())) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            long totalBytes = 0;
            
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
                totalBytes += bytesRead;
            }
            
            output.flush();
            System.out.println("FileServlet: 파일 전송 완료: " + totalBytes + " 바이트");
        } catch (IOException e) {
            System.out.println("FileServlet: 파일 전송 중 오류: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
} 