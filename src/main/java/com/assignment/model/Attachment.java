package com.assignment.model;

/**
 * 첨부파일 정보를 관리하는 모델 클래스
 */
public class Attachment {
    private int id;
    private int refId;          // 참조 ID (과제 ID, 제출물 ID 등)
    private String refType;     // 참조 타입 (assignment, submission 등)
    private String fileName;    // 파일 이름
    private String filePath;    // 파일 경로
    private String fileType;    // 파일 타입 (MIME 타입)
    private String uploadDate;  // 업로드 날짜
    
    public Attachment() {}
    
    public Attachment(int refId, String refType, String fileName, String filePath, String fileType) {
        this.refId = refId;
        this.refType = refType;
        this.fileName = fileName;
        this.filePath = filePath;
        this.fileType = fileType;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRefId() {
        return refId;
    }

    public void setRefId(int refId) {
        this.refId = refId;
    }

    public String getRefType() {
        return refType;
    }

    public void setRefType(String refType) {
        this.refType = refType;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public String getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(String uploadDate) {
        this.uploadDate = uploadDate;
    }
    
    // 파일이 이미지인지 확인
    public boolean isImage() {
        return fileType != null && fileType.startsWith("image/");
    }
    
    // 파일 확장자 추출
    public String getFileExtension() {
        if (fileName != null && fileName.contains(".")) {
            return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        }
        return "";
    }
} 