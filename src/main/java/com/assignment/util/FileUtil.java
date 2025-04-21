package com.assignment.util;

import java.io.*;
import java.util.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;

public class FileUtil {

    // 상대 경로 지정 (웹 앱 내부에 저장)
    private static final String UPLOAD_DIR = "uploads";

    // 단일 파일 업로드 메소드
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
                        
                        // 파일 저장
                        filePart.write(filePath);
                        
                        // 파일 타입 추출
                        String fileType = filePart.getContentType();
                        
                        // DB에 저장할 상대 경로와 파일 타입을 Map으로 반환
                        Map<String, String> fileInfo = new HashMap<>();
                        fileInfo.put("path", UPLOAD_DIR + "/" + (subDir != null ? subDir + "/" : "") + finalFileName);
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
    public static List<Map<String, String>> uploadMultipleFiles(HttpServletRequest request, String paramName, String subDir) {
        List<Map<String, String>> fileInfoList = new ArrayList<>();
        
        try {
            // 애플리케이션 실제 경로 가져오기
            String applicationPath = request.getServletContext().getRealPath("");
            
            // 파일 업로드 디렉토리 생성
            String uploadPath = applicationPath + UPLOAD_DIR;
            
            // 디버그용 로그
            System.out.println("📁 다중 업로드 기본 디렉토리: " + uploadPath);
            
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
            
            // 최종 업로드 디렉토리 생성
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("📁 최종 업로드 디렉토리 생성 " + (created ? "성공" : "실패"));
            }

            if (request.getContentType() != null &&
                request.getContentType().toLowerCase().startsWith("multipart/")) {
                
                // 여러 파일 처리
                Collection<Part> fileParts = request.getParts();
                for (Part filePart : fileParts) {
                    // 파일 파트인지 확인
                    if (filePart.getName().equals(paramName) && filePart.getSize() > 0) {
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
                            
                            // 파일 저장
                            filePart.write(filePath);
                            
                            // 파일 타입 추출
                            String fileType = filePart.getContentType();
                            
                            // DB에 저장할 상대 경로와 파일 타입을 Map으로 반환
                            Map<String, String> fileInfo = new HashMap<>();
                            fileInfo.put("path", UPLOAD_DIR + "/" + (subDir != null ? subDir + "/" : "") + finalFileName);
                            fileInfo.put("type", fileType);
                            fileInfo.put("name", finalFileName);
                            
                            fileInfoList.add(fileInfo);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("❌ 다중 파일 업로드 에러: " + e.getMessage());
            e.printStackTrace();
        }

        return fileInfoList;
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
     * 여러 파일을 저장하고 저장된 파일 정보 리스트를 반환합니다.
     * @param parts 파일 파트 리스트
     * @param folderPath 저장할 폴더 경로
     * @return 저장된 파일 정보 리스트 (원래 파일명, 저장된 파일명, 파일 경로, MIME 타입)
     */
    public static List<Map<String, String>> uploadMultipleFiles(Collection<Part> parts, String folderPath) {
        List<Map<String, String>> uploadedFiles = new ArrayList<>();
        
        if (parts.isEmpty()) {
            return uploadedFiles; // 파일이 없으면 빈 목록 반환
        }
        
        try {
            // 현재 작업 디렉토리 기준으로 전체 경로 생성
            String basePath = System.getProperty("user.dir");
            // 톰캣의 경우 기본적으로 webapp 폴더를 기준으로 함
            // 하지만 Eclipse의 경우 프로젝트 폴더가 아닌 워크스페이스 폴더일 수 있음
            
            // 웹앱 루트가 있는지 확인해보고 있으면 그것을 사용
            File webappRoot = new File(basePath, "src/main/webapp");
            if (webappRoot.exists() && webappRoot.isDirectory()) {
                basePath = webappRoot.getAbsolutePath();
            }
            
            // 전체 경로 생성
            String fullFolderPath = basePath + File.separator + folderPath;
            File uploadDir = new File(fullFolderPath);
            
            System.out.println("파일 업로드 시도 중... 폴더 경로: " + fullFolderPath);
            
            // 디렉터리가 없으면 모든 부모 경로와 함께 생성
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                if (!created) {
                    System.out.println("경로 생성 실패: " + fullFolderPath);
                    
                    // 다른 방법 시도: 시스템 임시 디렉토리 사용
                    String tempDir = System.getProperty("java.io.tmpdir");
                    fullFolderPath = tempDir + File.separator + folderPath;
                    uploadDir = new File(fullFolderPath);
                    created = uploadDir.mkdirs();
                    
                    if (!created) {
                        System.out.println("임시 경로 생성 실패: " + fullFolderPath);
                        return uploadedFiles;
                    }
                    System.out.println("임시 경로 사용: " + fullFolderPath);
                } else {
                    System.out.println("경로 생성 성공: " + fullFolderPath);
                }
            }
            
            for (Part part : parts) {
                if (part != null && part.getSize() > 0 && 
                    part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    try {
                        String submittedFileName = part.getSubmittedFileName();
                        String contentType = part.getContentType();
                        
                        // 파일명 충돌 방지를 위한 접두사 생성
                        String uniquePrefix = UUID.randomUUID().toString().substring(0, 8);
                        String savedFileName = uniquePrefix + "_" + submittedFileName;
                        
                        // 파일 저장 경로 (전체 경로)
                        String fullFilePath = fullFolderPath + File.separator + savedFileName;
                        System.out.println("파일 저장 경로: " + fullFilePath);
                        
                        // 파일 저장 - 직접 파일 복사 방식으로 변경
                        try (InputStream input = part.getInputStream();
                             OutputStream output = new FileOutputStream(fullFilePath)) {
                            
                            byte[] buffer = new byte[1024];
                            int length;
                            while ((length = input.read(buffer)) > 0) {
                                output.write(buffer, 0, length);
                            }
                            System.out.println("파일 저장 성공: " + fullFilePath);
                        }
                        
                        // 상대 경로 계산 (DB에 저장)
                        String relativeFilePath = folderPath + "/" + savedFileName;
                        
                        // 파일 정보 저장
                        Map<String, String> fileInfo = new HashMap<>();
                        fileInfo.put("name", submittedFileName);
                        fileInfo.put("savedFileName", savedFileName);
                        fileInfo.put("path", relativeFilePath);
                        fileInfo.put("type", contentType);
                        
                        uploadedFiles.add(fileInfo);
                    } catch (Exception e) {
                        System.out.println("파일 저장 중 오류 발생: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("파일 처리 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
        
        return uploadedFiles;
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
}