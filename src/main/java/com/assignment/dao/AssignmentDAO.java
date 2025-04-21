package com.assignment.dao;

import java.sql.*;
import java.util.*;
import com.assignment.model.Assignment;
import com.assignment.util.DBUtil;

public class AssignmentDAO {
    
    public List<Assignment> getAssignmentsByCourse(int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Assignment> assignments = new ArrayList<>();
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT a.*, " +
                         "(SELECT COUNT(*) FROM sskm0116db.submissions s WHERE s.assignment_id = a.id) AS submission_count, " +
                         "(SELECT COUNT(*) FROM sskm0116db.enrollments e WHERE e.course_id = a.course_id) AS total_students " +
                         "FROM sskm0116db.assignments a WHERE a.course_id = ? ORDER BY a.created_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Assignment assignment = new Assignment();
                assignment.setId(rs.getInt("id"));
                assignment.setCourseId(rs.getInt("course_id"));
                assignment.setTitle(rs.getString("title"));
                assignment.setDescription(rs.getString("description"));
                assignment.setCreatedDate(rs.getString("created_date"));
                assignment.setDueDate(rs.getString("due_date"));
                assignment.setFileName(rs.getString("file_name"));
                assignment.setFilePath(rs.getString("file_path"));
                assignment.setSubmissionCount(rs.getInt("submission_count"));
                assignment.setTotalStudents(rs.getInt("total_students"));
                assignments.add(assignment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return assignments;
    }

    public Assignment getAssignmentById(int assignmentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Assignment assignment = null;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT * FROM sskm0116db.assignments WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                assignment = new Assignment();
                assignment.setId(rs.getInt("id"));
                assignment.setCourseId(rs.getInt("course_id"));
                assignment.setTitle(rs.getString("title"));
                assignment.setDescription(rs.getString("description"));
                assignment.setCreatedDate(rs.getString("created_date"));
                assignment.setDueDate(rs.getString("due_date"));
                assignment.setFileName(rs.getString("file_name"));
                assignment.setFilePath(rs.getString("file_path"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return assignment;
    }

    public boolean addAssignment(Assignment assignment) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO sskm0116db.assignments (course_id, title, description, created_date, due_date, file_name, file_path) " +
                         "VALUES (?, ?, ?, NOW(), ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignment.getCourseId());
            pstmt.setString(2, assignment.getTitle());
            pstmt.setString(3, assignment.getDescription());
            pstmt.setString(4, assignment.getDueDate());
            pstmt.setString(5, assignment.getFileName());
            pstmt.setString(6, assignment.getFilePath());
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }

    public boolean updateAssignment(Assignment assignment) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE sskm0116db.assignments SET title = ?, description = ?, due_date = ?";
            
            // 파일이 있는 경우에만 파일 정보 업데이트
            if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) {
                sql += ", file_name = ?, file_path = ?";
            }
            
            sql += " WHERE id = ? AND course_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, assignment.getTitle());
            pstmt.setString(2, assignment.getDescription());
            pstmt.setString(3, assignment.getDueDate());
            
            int paramIndex = 4;
            if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) {
                pstmt.setString(paramIndex++, assignment.getFileName());
                pstmt.setString(paramIndex++, assignment.getFilePath());
            }
            
            pstmt.setInt(paramIndex++, assignment.getId());
            pstmt.setInt(paramIndex, assignment.getCourseId());
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }

    public boolean deleteAssignment(int assignmentId, int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "DELETE FROM sskm0116db.assignments WHERE id = ? AND course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            pstmt.setInt(2, courseId);
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }
        
        return result;
    }

    // 마지막으로 삽입된 과제 ID 가져오기
    public int getLastInsertedId() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int id = -1;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT LAST_INSERT_ID() as id";
            pstmt = conn.prepareStatement(sql);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                id = rs.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
        
        return id;
    }
    
    /**
     * 과제를 추가하고 생성된 ID를 반환합니다.
     * @param courseId 과정 ID
     * @param title 과제 제목
     * @param description 과제 설명
     * @param dueDate 마감일
     * @param fileName 파일명 (선택 사항)
     * @param filePath 파일 경로 (선택 사항)
     * @return 생성된 과제 ID 또는 실패 시 -1
     */
    public int addAssignmentAndGetId(int courseId, String title, String description, String dueDate, 
                                    String fileName, String filePath) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedId = -1;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO assignments (course_id, title, description, created_date, due_date, file_name, file_path) " +
                         "VALUES (?, ?, ?, NOW(), ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, courseId);
            pstmt.setString(2, title);
            pstmt.setString(3, description);
            pstmt.setString(4, dueDate);
            pstmt.setString(5, fileName);
            pstmt.setString(6, filePath);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    generatedId = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(rs, pstmt, conn);
        }
        
        return generatedId;
    }
}
