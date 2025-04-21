package com.assignment.dao;

import java.sql.*;
import java.util.*;
import com.assignment.model.Submission;
import com.assignment.util.DBUtil;

public class SubmissionDAO {
    
    public Submission getSubmission(int studentId, int assignmentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Submission submission = null;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT s.*, u.name AS student_name FROM submissions s " +
                         "JOIN sskm0116db.users u ON s.student_id = u.id " +
                         "WHERE s.student_id = ? AND s.assignment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, assignmentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                submission = new Submission();
                submission.setId(rs.getInt("id"));
                submission.setAssignmentId(rs.getInt("assignment_id"));
                submission.setStudentId(rs.getInt("student_id"));
                submission.setStudentName(rs.getString("student_name"));
                submission.setContent(rs.getString("content"));
                submission.setSubmissionDate(rs.getString("submission_date"));
                submission.setFileName(rs.getString("file_name"));
                submission.setFilePath(rs.getString("file_path"));
                submission.setGrade(rs.getString("grade"));
                submission.setFeedback(rs.getString("feedback"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return submission;
    }
    
    public List<Submission> getSubmissionsByAssignment(int assignmentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Submission> submissions = new ArrayList<>();
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT s.*, u.name AS student_name FROM submissions s " +
                         "JOIN sskm0116db.users u ON s.student_id = u.id " +
                         "WHERE s.assignment_id = ? " +
                         "ORDER BY s.submission_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Submission submission = new Submission();
                submission.setId(rs.getInt("id"));
                submission.setAssignmentId(rs.getInt("assignment_id"));
                submission.setStudentId(rs.getInt("student_id"));
                submission.setStudentName(rs.getString("student_name"));
                submission.setContent(rs.getString("content"));
                submission.setSubmissionDate(rs.getString("submission_date"));
                submission.setFileName(rs.getString("file_name"));
                submission.setFilePath(rs.getString("file_path"));
                submission.setGrade(rs.getString("grade"));
                submission.setFeedback(rs.getString("feedback"));
                submissions.add(submission);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return submissions;
    }
    
    public boolean addSubmission(Submission submission) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO submissions (assignment_id, student_id, content, submission_date, file_name, file_path) " +
                         "VALUES (?, ?, ?, NOW(), ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, submission.getAssignmentId());
            pstmt.setInt(2, submission.getStudentId());
            pstmt.setString(3, submission.getContent());
            pstmt.setString(4, submission.getFileName());
            pstmt.setString(5, submission.getFilePath());
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }
    
    public boolean updateSubmission(Submission submission) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE submissions SET content = ?, submission_date = NOW()";
            
            // 파일이 있는 경우에만 파일 정보 업데이트
            if (submission.getFileName() != null && !submission.getFileName().isEmpty()) {
                sql += ", file_name = ?, file_path = ?";
            }
            
            sql += " WHERE id = ? AND student_id = ? AND assignment_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, submission.getContent());
            
            int paramIndex = 2;
            if (submission.getFileName() != null && !submission.getFileName().isEmpty()) {
                pstmt.setString(paramIndex++, submission.getFileName());
                pstmt.setString(paramIndex++, submission.getFilePath());
            }
            
            pstmt.setInt(paramIndex++, submission.getId());
            pstmt.setInt(paramIndex++, submission.getStudentId());
            pstmt.setInt(paramIndex, submission.getAssignmentId());
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }
    
    public boolean gradeSubmission(int submissionId, String grade, String feedback) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE submissions SET grade = ?, feedback = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, grade);
            pstmt.setString(2, feedback);
            pstmt.setInt(3, submissionId);
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }
    
    public Submission getSubmissionById(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Submission submission = null;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT s.*, u.name AS student_name FROM submissions s " +
                         "JOIN sskm0116db.users u ON s.student_id = u.id " +
                         "WHERE s.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                submission = new Submission();
                submission.setId(rs.getInt("id"));
                submission.setAssignmentId(rs.getInt("assignment_id"));
                submission.setStudentId(rs.getInt("student_id"));
                submission.setStudentName(rs.getString("student_name"));
                submission.setContent(rs.getString("content"));
                submission.setSubmissionDate(rs.getString("submission_date"));
                submission.setFileName(rs.getString("file_name"));
                submission.setFilePath(rs.getString("file_path"));
                submission.setGrade(rs.getString("grade"));
                submission.setFeedback(rs.getString("feedback"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return submission;
    }
    
    public boolean submitOrUpdate(int assignmentId, int studentId, String content, String fileName, String filePath) {
        Submission existing = getSubmission(studentId, assignmentId);
        Submission submission = new Submission();
        submission.setAssignmentId(assignmentId);
        submission.setStudentId(studentId);
        submission.setContent(content);
        submission.setFileName(fileName);
        submission.setFilePath(filePath);

        if (existing == null) {
            return addSubmission(submission);
        } else {
            submission.setId(existing.getId());  // 기존 제출 ID 설정
            return updateSubmission(submission);
        }
    }
}
