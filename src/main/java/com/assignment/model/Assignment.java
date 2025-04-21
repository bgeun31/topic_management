package com.assignment.model;

public class Assignment {
    private int id;
    private int courseId;
    private String title;
    private String description;
    private String createdDate;
    private String dueDate;
    private String fileName;
    private String filePath;
    private int submissionCount;
    private int totalStudents;
    private boolean submitted;
    private String submissionDate;
    
    public Assignment() {}
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getCourseId() {
        return courseId;
    }
    
    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(String dueDate) {
        this.dueDate = dueDate;
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
    
    public int getSubmissionCount() {
        return submissionCount;
    }
    
    public void setSubmissionCount(int submissionCount) {
        this.submissionCount = submissionCount;
    }
    
    public int getTotalStudents() {
        return totalStudents;
    }
    
    public void setTotalStudents(int totalStudents) {
        this.totalStudents = totalStudents;
    }
    
    public boolean isSubmitted() {
        return submitted;
    }
    
    public void setSubmitted(boolean submitted) {
        this.submitted = submitted;
    }
    
    public String getSubmissionDate() {
        return submissionDate;
    }
    
    public void setSubmissionDate(String submissionDate) {
        this.submissionDate = submissionDate;
    }
}
