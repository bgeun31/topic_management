package com.assignment.model;

public class Course {
    private int id;
    private String courseName;
    private String courseCode;
    private String semester;
    private String description;
    private int professorId;
    private String professorName;
    private String createdDate;
    private int studentCount;
    private String enrollmentDate;
    
    public Course() {}
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getCourseName() {
        return courseName;
    }
    
    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }
    
    public String getCourseCode() {
        return courseCode;
    }
    
    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }
    
    public String getSemester() {
        return semester;
    }
    
    public void setSemester(String semester) {
        this.semester = semester;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getProfessorId() {
        return professorId;
    }
    
    public void setProfessorId(int professorId) {
        this.professorId = professorId;
    }
    
    public String getProfessorName() {
        return professorName;
    }
    
    public void setProfessorName(String professorName) {
        this.professorName = professorName;
    }
    
    public String getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }
    
    public int getStudentCount() {
        return studentCount;
    }
    
    public void setStudentCount(int studentCount) {
        this.studentCount = studentCount;
    }
    
    public String getEnrollmentDate() {
        return enrollmentDate;
    }
    
    public void setEnrollmentDate(String enrollmentDate) {
        this.enrollmentDate = enrollmentDate;
    }
}
