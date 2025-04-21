package com.assignment.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.assignment.model.Attachment;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

public class FileUtil {

    // 상대 경로 지정 (웹 앱 내부에 저장)
    private static final String UPLOAD_DIR = getOSUploadPath();
    
    // 로그인 ID (서버 환경에서 사용)
    private static final String LOGIN_ID = "sskm0116";
    
    // 초기화 블록: 클래스가 로드될 때 한 번 실행됩니다.
    static {
        try {
            // D 드라이브와 uploads 폴더 확인
            File dDrive = new File("D:\\");
            if (dDrive.exists()) {
                System.out.println("D 드라이브 존재: " + dDrive.getAbsolutePath());
                System.out.println("D 드라이브 쓰기 권한: " + dDrive.canWrite());
                
                // uploads 폴더 확인
                File uploadsDir = new File("D:\\uploads");
                if (!uploadsDir.exists()) {
                    boolean created = uploadsDir.mkdir();
                    System.out.println("D:\\uploads 폴더 생성: " + (created ? "성공" : "실패"));
                } else {
                    System.out.println("D:\\uploads 폴더 이미 존재");
                    System.out.println("uploads 폴더 쓰기 권한: " + uploadsDir.canWrite());
                }
                
                // 테스트 파일 생성 (권한 확인용)
                File testFile = new File("D:\\uploads\\test.txt");
                try {
                    if (testFile.exists()) {
                        testFile.delete();
                    }
                    boolean fileCreated = testFile.createNewFile();
                    System.out.println("테스트 파일 생성: " + (fileCreated ? "성공" : "실패"));
                    
                    if (fileCreated) {
                        try (FileWriter writer = new FileWriter(testFile)) {
                            writer.write("테스트 파일 내용 - " + new Date());
                            System.out.println("테스트 파일에 내용 쓰기 성공");
                        }
                        
                        // 테스트 후 정리
                        testFile.delete();
                        System.out.println("테스트 파일 삭제");
                    }
                } catch (Exception e) {
                    System.out.println("테스트 파일 생성/쓰기 중 오류: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                System.out.println("D 드라이브가 존재하지 않습니다!");
            }
        } catch (Exception e) {
            System.out.println("초기화 블록 실행 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * OS에 따라 적절한 업로드 경로를 반환합니다.
     * @return 운영체제에 맞는 업로드 경로
     */
    public static String getOSUploadPath() {
        
        String fixedPath = "D:\\uploads";
        
        System.out.println("고정 업로드 경로 사용: " + fixedPath);
        
        // 폴더 존재 확인 및 생성
        File dir = new File(fixedPath);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            System.out.println("uploads 폴더 생성 " + (created ? "성공" : "실패") + ": " + fixedPath);
            if (!created) {
                System.out.println("폴더를 수동으로 생성해주세요: " + fixedPath);
                
                // 문제 해결 지침 출력
                System.out.println("D:\\uploads 폴더가 없거나 접근할 수 없습니다.");
                System.out.println("1. D 드라이브에 'uploads' 폴더를 수동으로 생성하세요.");
                System.out.println("2. 폴더에 모든 사용자 쓰기 권한이 있는지 확인하세요.");
            }
        }
        
        return fixedPath;
    }
    
    /**
     * OS에 따라 적절한 웹 경로를 반환합니다.
     * @param subPath 하위 경로
     * @return 웹 접근 경로
     */
    public static String getWebPath(String subPath) {
        // 파일명만 반환 (경로 정보 없이)
        if (subPath != null && subPath.contains("/")) {
            subPath = subPath.substring(subPath.lastIndexOf("/") + 1);
        }
        // 단순히 파일명만 반환
        return subPath;
    }
    
    /**
     * 파일 경로에 대한 웹 접근 URL을 생성합니다.
     * @param request HTTP 요청 객체
     * @param filePath 파일 경로 (uploads/ 형태) 또는 파일명
     * @return 파일 접근 URL (FileServlet을 통한 접근)
     */
    public static String getFileUrl(HttpServletRequest request, String filePath) {
        // 파일 경로가 null인 경우
        if (filePath == null || filePath.isEmpty()) {
            return null;
        }
        
        // 파일명만 추출
        String fileName = filePath;
        if (fileName.contains("/")) {
            fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
        }
        
        // 컨텍스트 경로
        String contextPath = request.getContextPath();
        
        // FileServlet을 통한 파일 접근 URL 생성
        String fileUrl = contextPath + "/files/" + fileName;
        
        System.out.println("🔗 파일 URL 생성: " + fileUrl);
        return fileUrl;
    }
    
    /**
     * 첨부파일 ID로 다운로드 URL을 생성합니다.
     * @param request HTTP 요청 객체
     * @param attachmentId 첨부파일 ID
     * @return 다운로드 URL
     */
    public static String getDownloadUrl(HttpServletRequest request, int attachmentId) {
        String serverUrl;
        boolean isLocalDev = "localhost".equals(request.getServerName()) || "127.0.0.1".equals(request.getServerName());
        
        if (isLocalDev) {
            // 로컬 개발 환경
            serverUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
        } else {
            // 서버 환경 (하드코딩)
            serverUrl = "http://210.119.103.168:8080";
        }
        
        return serverUrl + "/download.jsp?type=attachment&id=" + attachmentId;
    }

    /**
     * 업로드된 파일의 직접 접근 URL을 생성합니다 (download.jsp를 거치지 않고 직접 파일에 접근).
     * @param request HTTP 요청 객체
     * @param fileName 파일명
     * @return 파일 직접 접근 URL
     */
    public static String getDirectFileUrl(HttpServletRequest request, String fileName) {
        // 기본 서버 URL 설정
        String serverUrl;
        boolean isLocalDev = "localhost".equals(request.getServerName()) || "127.0.0.1".equals(request.getServerName());
        
        if (isLocalDev) {
            // 로컬 개발 환경
            serverUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
        } else {
            // 서버 환경 (서버 IP 하드코딩)
            serverUrl = "http://210.119.103.168:8080";
        }
        
        // 파일명 확인
        if (fileName == null || fileName.isEmpty()) {
            return null;
        }
        
        // 이미 uploads/ 경로를 포함하는 경우
        if (fileName.startsWith("uploads/")) {
            return serverUrl + "/" + fileName;
        }
        
        // uploads/ 경로를 포함하지 않는 경우 추가
        return serverUrl + "/uploads/" + fileName;
    }
    
    /**
     * 첨부파일의 시스템 저장 파일명을 기반으로 직접 URL을 생성합니다.
     * @param request HTTP 요청 객체
     * @param attachment 첨부파일 객체
     * @return 직접 접근 URL
     */
    public static String getDirectAttachmentUrl(HttpServletRequest request, Attachment attachment) {
        if (attachment == null) {
            return null;
        }
        
        System.out.println("📎 첨부파일 URL 생성 시작 - ID: " + attachment.getId());
        System.out.println("📎 첨부파일 타입: " + attachment.getFileType());
        
        // 컨텍스트 경로 가져오기
        String contextPath = request.getContextPath();
        
        // 새로운 서블릿 경로를 사용하여 파일 접근
        String fileName = null;
        
        // 저장된 파일명 먼저 사용 (가장 신뢰할 수 있음)
        if (attachment.getSavedFileName() != null && !attachment.getSavedFileName().isEmpty()) {
            fileName = attachment.getSavedFileName();
            System.out.println("📎 저장된 파일명 사용: " + fileName);
        }
        // 파일 경로가 있는 경우 파일명 추출
        else if (attachment.getFilePath() != null && !attachment.getFilePath().isEmpty()) {
            String filePath = attachment.getFilePath();
            System.out.println("📎 파일 경로 사용: " + filePath);
            
            // 파일명 추출
            if (filePath.contains("/")) {
                fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
            } else {
                fileName = filePath;
            }
        }
        // 마지막으로 원본 파일명 사용
        else if (attachment.getFileName() != null && !attachment.getFileName().isEmpty()) {
            fileName = attachment.getFileName();
            System.out.println("📎 원본 파일명 사용: " + fileName);
        }
        
        if (fileName == null) {
            System.out.println("⚠️ 첨부파일에 유효한 파일명이 없습니다!");
            return null;
        }
        
        // 파일 서블릿을 통한 URL 생성
        String fileUrl = contextPath + "/files/" + fileName;
        System.out.println("📎 생성된 최종 URL: " + fileUrl);
        
        return fileUrl;
    }

    // 단일 파일 업로드 메소드
    public static String uploadFile(HttpServletRequest request, String paramName, String subDir) {
        try {
            // 파일 업로드 디렉토리 생성
            String uploadPath = UPLOAD_DIR;
            
            // 디버그용 로그
            System.out.println("📁 업로드 기본 디렉토리: " + uploadPath);
            
            // 기본 업로드 디렉토리 생성
            File baseUploadDir = new File(uploadPath);
            if (!baseUploadDir.exists()) {
                try {
                    boolean created = baseUploadDir.mkdirs();
                    System.out.println("📁 기본 업로드 디렉토리 생성 " + (created ? "성공" : "실패") + ": " + uploadPath);
                    
                    if (!created) {
                        // 권한 확인 및 더 자세한 정보 출력
                        System.out.println("❌ 디렉토리 생성 실패 - 권한 문제 또는 드라이브가 존재하지 않을 수 있습니다.");
                        System.out.println("💡 팁: D 드라이브에 수동으로 'uploads' 폴더를 생성하세요.");
                        
                        // 파일 쓰기 권한 확인
                        File parentDir = baseUploadDir.getParentFile();
                        if (parentDir != null) {
                            System.out.println("부모 디렉토리 존재 여부: " + parentDir.exists());
                            System.out.println("부모 디렉토리 쓰기 권한: " + parentDir.canWrite());
                        }
                    }
                } catch (Exception e) {
                    System.out.println("❌ 디렉토리 생성 중 예외 발생: " + e.getMessage());
                    e.printStackTrace();
                }
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
                        // 파일명 준비
                        String fileExtension = "";
                        String fileNameWithoutExt = originalFileName;
                        if (originalFileName.contains(".")) {
                            fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                            fileNameWithoutExt = originalFileName.substring(0, originalFileName.lastIndexOf("."));
                        }
                        
                        // 중복 파일 처리
                        String finalFileName = originalFileName;
                        File file = new File(uploadPath + File.separator + finalFileName);
                        
                        // 파일이 존재하면 파일명에 번호를 추가하는 방식으로 중복 처리
                        int count = 1;
                        while (file.exists()) {
                            finalFileName = fileNameWithoutExt + "(" + count + ")" + fileExtension;
                            file = new File(uploadPath + File.separator + finalFileName);
                            count++;
                        }
                        
                        String filePath = uploadPath + File.separator + finalFileName;
                        
                        // 디버그용 로그
                        System.out.println("📄 파일 저장 경로: " + filePath);
                        
                        try {
                            // 파일 저장 시도 (Part.write 메서드 사용)
                            System.out.println("📄 Part.write 메서드로 파일 저장 시도: " + filePath);
                        filePart.write(filePath);

                            // 파일 저장 성공 여부 확인
                            File savedFile = new File(filePath);
                            if (savedFile.exists() && savedFile.length() > 0) {
                                System.out.println("✅ 파일 저장 성공! 파일 크기: " + savedFile.length() + " bytes");
                            } else {
                                System.out.println("⚠️ Part.write 메서드로 파일 저장 실패, 수동 방식으로 재시도합니다.");
                                
                                // 수동으로 파일 저장 시도 (InputStream 사용)
                                try (InputStream inputStream = filePart.getInputStream();
                                     FileOutputStream outputStream = new FileOutputStream(filePath)) {
                                    
                                    byte[] buffer = new byte[8192];
                                    int bytesRead;
                                    int totalBytes = 0;
                                    
                                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                                        outputStream.write(buffer, 0, bytesRead);
                                        totalBytes += bytesRead;
                                    }
                                    
                                    System.out.println("✅ 수동 파일 저장 성공! 파일 크기: " + totalBytes + " bytes");
                                } catch (Exception e) {
                                    System.out.println("❌ 수동 파일 저장 중 오류: " + e.getMessage());
                                    e.printStackTrace();
                                }
                            }
                        } catch (Exception e) {
                            System.out.println("❌ Part.write 메서드 실행 중 오류: " + e.getMessage());
                            e.printStackTrace();
                            
                            // 오류 발생 시 수동으로 파일 저장 시도
                            try (InputStream inputStream = filePart.getInputStream();
                                 FileOutputStream outputStream = new FileOutputStream(filePath)) {
                                
                                byte[] buffer = new byte[8192];
                                int bytesRead;
                                int totalBytes = 0;
                                
                                while ((bytesRead = inputStream.read(buffer)) != -1) {
                                    outputStream.write(buffer, 0, bytesRead);
                                    totalBytes += bytesRead;
                                }
                                
                                System.out.println("✅ 수동 파일 저장 성공! 파일 크기: " + totalBytes + " bytes");
                            } catch (Exception ex) {
                                System.out.println("❌ 수동 파일 저장 중 오류: " + ex.getMessage());
                                ex.printStackTrace();
                            }
                        }
                        
                        // 파일 타입 추출
                        String fileType = filePart.getContentType();
                        
                        // DB에 저장할 상대 경로 구성 (웹에서 접근 가능한 경로)
                        String webPath = "uploads/" + finalFileName;
                        
                        // DB에 저장할 상대 경로와 파일 타입을 Map으로 반환
                        Map<String, String> fileInfo = new HashMap<>();
                        fileInfo.put("path", webPath);
                        fileInfo.put("type", fileType);
                        fileInfo.put("name", finalFileName);
                        
                        return fileInfo.get("path");
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("❌ 파일 업로드 에러: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }
    
    // 여러 파일 업로드 메소드
    public static List<Map<String, String>> uploadMultipleFiles(Collection<Part> parts, String folderPath) {
        List<Map<String, String>> uploadedFiles = new ArrayList<>();
        
        if (parts == null || parts.isEmpty()) {
            System.out.println("파일 파트가 없음");
            return uploadedFiles; // 파일이 없으면 빈 목록 반환
        }
        
        try {
            System.out.println("요청된 폴더 경로 (참고용): " + folderPath);
            
            // 물리적 업로드 경로 가져오기 (webapp/uploads 폴더)
            String finalUploadPath = getOSUploadPath();
            System.out.println("✅ 파일이 저장될 물리적 경로: " + finalUploadPath);
            
            // 디렉토리 확실히 생성
            File uploadDir = new File(finalUploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                if (!created) {
                    System.out.println("❌ 업로드 디렉토리 생성 실패! 수동으로 다음 경로를 생성해주세요: " + finalUploadPath);
                    // 수동 폴더 생성을 위한 상세 안내
                    System.out.println("1. 탐색기로 다음 경로를 열어주세요: " + finalUploadPath.substring(0, finalUploadPath.lastIndexOf(File.separator)));
                    System.out.println("2. 'uploads' 폴더를 생성해주세요.");
                    System.out.println("3. 톰캣 서버를 재시작해주세요.");
                    return uploadedFiles;
                } else {
                    System.out.println("✅ 업로드 디렉토리 성공적으로 생성됨: " + finalUploadPath);
                }
            }
            
            // 폴더 쓰기 권한 확인
            if (!uploadDir.canWrite()) {
                System.out.println("❌ 폴더에 쓰기 권한이 없습니다: " + finalUploadPath);
                return uploadedFiles;
            }
            
            // 파일 저장
            for (Part part : parts) {
                if (part != null && part.getSize() > 0 && 
                    part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    
                    try {
                        String originalFileName = part.getSubmittedFileName();
                        String contentType = part.getContentType();
                        
                        // 고유 파일명 생성
                        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
                        String savedFileName = uniqueId + "_" + originalFileName;
                        
                        // 전체 파일 경로 (물리적 경로)
                        String fullFilePath = finalUploadPath + File.separator + savedFileName;
                        System.out.println("파일 저장 경로: " + fullFilePath);
                        
                        // 파일 저장 시도
                        try {
                            // InputStream을 통한 직접 저장 방식 사용
                            try (InputStream inputStream = part.getInputStream();
                                 FileOutputStream outputStream = new FileOutputStream(fullFilePath)) {
                                
                                byte[] buffer = new byte[8192];
                                int bytesRead;
                                int totalBytes = 0;
                                
                                while ((bytesRead = inputStream.read(buffer)) != -1) {
                                    outputStream.write(buffer, 0, bytesRead);
                                    totalBytes += bytesRead;
                                }
                                
                                System.out.println("✅ 파일 저장 성공! 크기: " + totalBytes + " bytes");
                            }
                            
                            // 파일 저장 성공 확인
                            File savedFile = new File(fullFilePath);
                            if (savedFile.exists() && savedFile.length() > 0) {
                                System.out.println("✅ 파일 저장 확인: " + savedFile.length() + " bytes");
                            } else {
                                System.out.println("❌ 파일이 존재하지 않거나 크기가 0입니다!");
                                continue;
                            }
                        } catch (Exception e) {
                            System.out.println("❌ 파일 저장 중 오류: " + e.getMessage());
                            e.printStackTrace();
                            continue;
                        }
                        
                        // DB에 저장할 상대 경로 (웹 접근 경로)
                        String relativeFilePath = savedFileName;
                        
                        // 파일 정보 기록
                        Map<String, String> fileInfo = new HashMap<>();
                        fileInfo.put("originalFileName", originalFileName);
                        fileInfo.put("savedFileName", savedFileName);
                        fileInfo.put("filePath", relativeFilePath);
                        fileInfo.put("contentType", contentType);
                        
                        uploadedFiles.add(fileInfo);
                        System.out.println("파일 업로드 완료: " + originalFileName + " -> " + relativeFilePath);
                    } catch (Exception e) {
                        System.out.println("파일 처리 중 오류: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            
        } catch (Exception e) {
            System.out.println("파일 업로드 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        return uploadedFiles;
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
                // 웹 경로를 절대 경로로 변환
                String webPathPart = filePath;
                String fileName = "";
                
                // uploads/파일명 형식에서 파일명만 추출
                if (webPathPart.startsWith("uploads/")) {
                    fileName = webPathPart.substring("uploads/".length());
                } else if (webPathPart.contains("/")) {
                    fileName = webPathPart.substring(webPathPart.lastIndexOf("/") + 1);
                } else {
                    fileName = webPathPart;
                }
                
                // OS별 업로드 경로와 결합 (파일명만 사용)
                String fullPath = getOSUploadPath() + File.separator + fileName;
                
                // 디버그용 로그
                System.out.println("🗑️ 파일 삭제 경로: " + fullPath);
                
                File file = new File(fullPath);
                if (file.exists()) {
                    return file.delete();
                } else {
                    System.out.println("⚠️ 삭제할 파일이 존재하지 않습니다: " + fullPath);
                    
                    // 원래 경로에서 파일이 발견되지 않으면, assignments 하위에서도 검색
                    File dir = new File(getOSUploadPath());
                    boolean found = false;
                    
                    // uploads 폴더 아래 모든 디렉토리에서 파일 검색
                    if (dir.exists() && dir.isDirectory()) {
                        found = findAndDeleteFile(dir, fileName);
                    }
                    
                    if (!found) {
                        System.out.println("⚠️ 모든 위치에서 파일을 찾을 수 없습니다: " + fileName);
                    }
                    
                    return found;
                }
            } catch (Exception e) {
                System.out.println("❌ 파일 삭제 에러: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return false;
    }
    
    // 지정된 디렉토리와 하위 디렉토리에서 파일을 찾아 삭제
    private static boolean findAndDeleteFile(File directory, String fileName) {
        if (!directory.isDirectory()) {
            return false;
        }
        
        File[] files = directory.listFiles();
        if (files == null) {
            return false;
        }
        
        for (File file : files) {
            if (file.isDirectory()) {
                if (findAndDeleteFile(file, fileName)) {
                    return true;
                }
            } else if (file.getName().equals(fileName)) {
                System.out.println("🔍 파일 발견: " + file.getAbsolutePath());
                boolean deleted = file.delete();
                System.out.println("🗑️ 파일 삭제 " + (deleted ? "성공" : "실패") + ": " + file.getAbsolutePath());
                return deleted;
            }
        }
        
        return false;
    }
    
    /**
     * 파일 타입과 파일명에 따라 Bootstrap Icons 클래스를 반환합니다.
     * @param fileType 파일 MIME 타입
     * @param fileName 파일 이름
     * @return Bootstrap Icons 클래스명
     */
    public static String getFileIconClass(String fileType, String fileName) {
        if (fileType == null || fileType.isEmpty()) {
            fileType = getMIMEType(fileName);
        }
        
        if (fileType.startsWith("image/")) {
            return "bi-file-image";
        } else if (fileType.startsWith("video/")) {
            return "bi-file-play";
        } else if (fileType.startsWith("audio/")) {
            return "bi-file-music";
        } else if (fileType.equals("application/pdf")) {
            return "bi-file-pdf";
        } else if (fileType.equals("application/msword") || 
                   fileType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document")) {
            return "bi-file-word";
        } else if (fileType.equals("application/vnd.ms-excel") ||
                   fileType.equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")) {
            return "bi-file-excel";
        } else if (fileType.equals("application/vnd.ms-powerpoint") ||
                   fileType.equals("application/vnd.openxmlformats-officedocument.presentationml.presentation")) {
            return "bi-file-ppt";
        } else if (fileType.equals("application/zip") || 
                   fileType.equals("application/x-rar-compressed") ||
                   fileType.equals("application/x-7z-compressed")) {
            return "bi-file-zip";
        } else if (fileType.startsWith("text/")) {
            return "bi-file-text";
        } else {
            return "bi-file-earmark";
        }
    }

    /**
     * 주어진 파일 타입이 이미지인지 확인합니다.
     * @param fileType 파일 MIME 타입
     * @return 이미지 여부
     */
    public static boolean isImage(String fileType) {
        return fileType != null && fileType.startsWith("image/");
    }

    /**
     * 파일 확장자로부터 파일이 이미지인지 확인합니다.
     * @param fileName 파일 이름
     * @return 이미지 여부
     */
    public static boolean isImageByFileName(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return false;
        }
        
        String mimeType = getMIMEType(fileName);
        return isImage(mimeType);
    }

    /**
     * 파일명으로부터 MIME 타입을 추정합니다.
     * @param fileName 파일 이름
     * @return 추정된 MIME 타입
     */
    public static String getMIMEType(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "application/octet-stream";
        }
        
        String extension = "";
        if (fileName.contains(".")) {
            extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        }
        
        switch (extension) {
            // 이미지
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "bmp":
                return "image/bmp";
            case "webp":
                return "image/webp";
            case "svg":
                return "image/svg+xml";
                
            // 문서
            case "pdf":
                return "application/pdf";
            case "doc":
                return "application/msword";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls":
                return "application/vnd.ms-excel";
            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "ppt":
                return "application/vnd.ms-powerpoint";
            case "pptx":
                return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case "txt":
                return "text/plain";
            case "csv":
                return "text/csv";
                
            // 압축파일
            case "zip":
                return "application/zip";
            case "rar":
                return "application/x-rar-compressed";
            case "7z":
                return "application/x-7z-compressed";
                
            // 오디오
            case "mp3":
                return "audio/mpeg";
            case "wav":
                return "audio/wav";
            case "ogg":
                return "audio/ogg";
                
            // 비디오
            case "mp4":
                return "video/mp4";
            case "avi":
                return "video/x-msvideo";
            case "mov":
                return "video/quicktime";
            case "wmv":
                return "video/x-ms-wmv";
                
            // 코드
            case "html":
            case "htm":
                return "text/html";
            case "css":
                return "text/css";
            case "js":
                return "application/javascript";
            case "json":
                return "application/json";
            case "xml":
                return "application/xml";
            case "java":
                return "text/x-java-source";
            case "py":
                return "text/x-python";
            case "c":
                return "text/x-c";
            case "cpp":
                return "text/x-c++";
                
            default:
                return "application/octet-stream";
        }
    }

    /**
     * 지정된 파일명으로 여러 파일 중 특정 파일을 찾습니다.
     * @param request 요청 객체
     * @param fileInputName 파일 입력 필드 이름
     * @return 파일 파트 리스트
     */
    public static Collection<Part> getFileParts(HttpServletRequest request, String fileInputName) {
        try {
            Collection<Part> parts = request.getParts();
            List<Part> fileParts = new ArrayList<>();
            
            for (Part part : parts) {
                if (part.getName().equals(fileInputName) && part.getSize() > 0 && 
                    part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    fileParts.add(part);
                }
            }
            
            return fileParts;
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // 파일 직접 저장 유틸리티 메서드 (테스트 및 디버깅용)
    public static boolean saveTestFile(String content) {
        try {
            // 테스트 파일 저장 경로
            String testFilePath = UPLOAD_DIR + File.separator + "test_" + System.currentTimeMillis() + ".txt";
            File testFile = new File(testFilePath);
            
            // 파일 저장
            try (FileWriter writer = new FileWriter(testFile)) {
                writer.write(content);
            }
            
            // 파일 생성 여부 확인
            boolean success = testFile.exists() && testFile.length() > 0;
            System.out.println("테스트 파일 저장 " + (success ? "성공" : "실패") + ": " + testFilePath);
            return success;
        } catch (Exception e) {
            System.out.println("테스트 파일 저장 중 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}