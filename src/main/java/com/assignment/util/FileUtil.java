package com.assignment.util;

import java.io.*;
import java.util.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

public class FileUtil {

    private static final String UPLOAD_DIR = "/opt/tomcat/apache-tomcat-10.1.18/webapps/uploads/sskm0116";

    // 파일 업로드 메소드
    public static String uploadFile(HttpServletRequest request, String paramName, String subDir) {
        try {
            String uploadPath = UPLOAD_DIR;

            if (subDir != null && !subDir.isEmpty()) {
                uploadPath = uploadPath + File.separator + subDir;
            }

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            if (request.getContentType() != null &&
                request.getContentType().toLowerCase().startsWith("multipart/")) {
                Part filePart = request.getPart(paramName);
                if (filePart != null && filePart.getSize() > 0) {
                    String originalFileName = getFileName(filePart);
                    if (originalFileName != null && !originalFileName.isEmpty()) {
                        // 실제 이름으로 저장되게 설정
                        String filePath = uploadPath + File.separator + originalFileName;

                        filePart.write(filePath);

                        return "uploads/sskm0116/" + (subDir != null ? subDir + "/" : "") + originalFileName;
                    }
                }
            }
        } catch (Exception e) {
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

    // ✅ 파일 삭제 메소드 (수정됨)
    public static boolean deleteFile(HttpServletRequest request, String filePath) {
        if (filePath != null && !filePath.isEmpty()) {
            try {
                // 수정된 경로 사용
                String fullPath = UPLOAD_DIR + File.separator + filePath.replace("uploads/sskm0116/", "").replace("/", File.separator);
                File file = new File(fullPath);
                if (file.exists()) {
                    return file.delete();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }
}