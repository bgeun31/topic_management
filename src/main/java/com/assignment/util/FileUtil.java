package com.assignment.util;

import java.io.*;
import java.util.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

public class FileUtil {

    // 상대 경로 지정 (웹 앱 내부에 저장)
    private static final String UPLOAD_DIR = "uploads";

    // 파일 업로드 메소드
    public static String uploadFile(HttpServletRequest request, String paramName, String subDir) {
        try {
            // 애플리케이션 실제 경로 가져오기
            String applicationPath = request.getServletContext().getRealPath("");
            
            // 파일 업로드 디렉토리 생성
            String uploadPath = applicationPath + UPLOAD_DIR;
            
            // 디버그용 로그
            System.out.println("📁 업로드 기본 디렉토리: " + uploadPath);
            
            // 기본 업로드 디렉토리 생성
            File baseUploadDir = new File(uploadPath);
            if (!baseUploadDir.exists()) {
                boolean created = baseUploadDir.mkdirs();
                System.out.println("📁 기본 업로드 디렉토리 생성 " + (created ? "성공" : "실패"));
            }

            // 하위 디렉토리가 있는 경우 추가
            if (subDir != null && !subDir.isEmpty()) {
                uploadPath = uploadPath + File.separator + subDir;
            }
            
            // 디버그용 로그
            System.out.println("📁 최종 업로드 경로: " + uploadPath);
            
            // 최종 업로드 디렉토리 생성
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("📁 최종 업로드 디렉토리 생성 " + (created ? "성공" : "실패"));
            }

            if (request.getContentType() != null &&
                request.getContentType().toLowerCase().startsWith("multipart/")) {
                Part filePart = request.getPart(paramName);
                if (filePart != null && filePart.getSize() > 0) {
                    String originalFileName = getFileName(filePart);
                    if (originalFileName != null && !originalFileName.isEmpty()) {
                        // 파일명이 중복되지 않도록 타임스탬프 추가
                        String fileExtension = "";
                        if (originalFileName.contains(".")) {
                            fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                            originalFileName = originalFileName.substring(0, originalFileName.lastIndexOf("."));
                        }
                        
                        String uniqueFileName = originalFileName + "_" + System.currentTimeMillis() + fileExtension;
                        String filePath = uploadPath + File.separator + uniqueFileName;
                        
                        // 디버그용 로그
                        System.out.println("📄 파일 저장 경로: " + filePath);
                        
                        // 파일 저장
                        filePart.write(filePath);
                        
                        // DB에 저장할 상대 경로 반환
                        return UPLOAD_DIR + "/" + (subDir != null ? subDir + "/" : "") + uniqueFileName;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("❌ 파일 업로드 에러: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    // Part에서 파일명 추출
    private static String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");

        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                String fileName = item.substring(item.indexOf("=") + 2, item.length() - 1);
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }

        return null;
    }

    // 파일 삭제 메소드
    public static boolean deleteFile(HttpServletRequest request, String filePath) {
        if (filePath != null && !filePath.isEmpty()) {
            try {
                String applicationPath = request.getServletContext().getRealPath("");
                String fullPath = applicationPath + filePath;
                
                // 디버그용 로그
                System.out.println("🗑️ 파일 삭제 경로: " + fullPath);
                
                File file = new File(fullPath);
                if (file.exists()) {
                    return file.delete();
                } else {
                    System.out.println("⚠️ 삭제할 파일이 존재하지 않습니다: " + fullPath);
                }
            } catch (Exception e) {
                System.out.println("❌ 파일 삭제 에러: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return false;
    }
}