package com.assignment.dao;

import java.sql.*;
import java.sql.DatabaseMetaData;
import java.util.*;
import com.assignment.model.Attachment;
import com.assignment.util.DBUtil;

/**
 * 첨부파일 관련 데이터베이스 작업을 수행하는 DAO 클래스
 */
public class AttachmentDAO {

    /**
     * 첨부파일 정보를 데이터베이스에 저장
     * @param attachment 저장할 첨부파일 객체
     * @return 저장된 첨부파일의 ID, 실패 시 -1
     */
    public int saveAttachment(Attachment attachment) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedId = -1;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO attachments (ref_id, ref_type, file_name, file_path, file_type, upload_date) "
                    + "VALUES (?, ?, ?, ?, ?, NOW())";
            
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, attachment.getRefId());
            pstmt.setString(2, attachment.getRefType());
            pstmt.setString(3, attachment.getFileName());
            pstmt.setString(4, attachment.getFilePath());
            pstmt.setString(5, attachment.getFileType());
            
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
    
    /**
     * 특정 참조 ID와 타입에 연결된 모든 첨부파일 조회
     * @param refId 참조 ID (과제 ID, 제출물 ID 등)
     * @param refType 참조 타입 (assignment, submission 등)
     * @return 첨부파일 목록
     */
    public List<Attachment> getAttachmentsByRef(int refId, String refType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Attachment> attachments = new ArrayList<>();
        
        try {
            conn = DBUtil.getConnection();
            ensureAttachmentsTableExists(conn);
            
            // 현재는 assignment_id만 지원합니다
            if (!"assignment".equals(refType)) {
                return attachments;
            }
            
            String sql = "SELECT id, assignment_id, original_file_name, saved_file_name, file_path, content_type, upload_date " +
                         "FROM attachments WHERE assignment_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, refId);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Attachment attachment = new Attachment();
                attachment.setId(rs.getInt("id"));
                attachment.setRefId(rs.getInt("assignment_id"));
                attachment.setRefType("assignment"); // 고정 값
                attachment.setFileName(rs.getString("original_file_name"));
                attachment.setSavedFileName(rs.getString("saved_file_name"));
                attachment.setFilePath(rs.getString("file_path"));
                attachment.setFileType(rs.getString("content_type"));
                attachment.setUploadDate(rs.getTimestamp("upload_date").toString());
                
                attachments.add(attachment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(rs, pstmt, conn);
        }
        
        return attachments;
    }
    
    /**
     * 첨부파일 ID로 단일 첨부파일 조회
     * @param id 첨부파일 ID
     * @return 첨부파일 객체, 없으면 null
     */
    public Attachment getAttachmentById(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Attachment attachment = null;
        
        try {
            conn = DBUtil.getConnection();
            ensureAttachmentsTableExists(conn);
            
            String sql = "SELECT id, assignment_id, original_file_name, saved_file_name, file_path, content_type, upload_date " +
                         "FROM attachments WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                attachment = new Attachment();
                attachment.setId(rs.getInt("id"));
                attachment.setRefId(rs.getInt("assignment_id"));
                attachment.setRefType("assignment"); // 고정 값
                attachment.setFileName(rs.getString("original_file_name"));
                attachment.setSavedFileName(rs.getString("saved_file_name"));
                attachment.setFilePath(rs.getString("file_path"));
                attachment.setFileType(rs.getString("content_type"));
                attachment.setUploadDate(rs.getTimestamp("upload_date").toString());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(rs, pstmt, conn);
        }
        
        return attachment;
    }
    
    /**
     * 첨부파일 삭제
     * @param id 삭제할 첨부파일 ID
     * @return 삭제 성공 여부
     */
    public boolean deleteAttachment(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "DELETE FROM attachments WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            int affectedRows = pstmt.executeUpdate();
            success = (affectedRows > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(null, pstmt, conn);
        }
        
        return success;
    }
    
    /**
     * 특정 참조에 연결된 모든 첨부파일 삭제
     * @param refId 참조 ID
     * @param refType 참조 타입
     * @return 삭제 성공 여부
     */
    public boolean deleteAttachmentsByRef(int refId, String refType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        
        try {
            conn = DBUtil.getConnection();
            String sql = "DELETE FROM attachments WHERE ref_id = ? AND ref_type = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, refId);
            pstmt.setString(2, refType);
            
            pstmt.executeUpdate();
            success = true;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(null, pstmt, conn);
        }
        
        return success;
    }
    
    /**
     * 지정된 과제 ID에 해당하는 모든 첨부파일 목록을 가져옵니다.
     * 
     * @param assignmentId 첨부파일을 가져올 과제 ID
     * @return 첨부파일 정보가 담긴 Map 목록
     */
    public List<Map<String, Object>> getAttachmentsByAssignmentId(int assignmentId) {
        List<Map<String, Object>> attachments = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            ensureAttachmentsTableExists(conn);
            
            String sql = "SELECT id, assignment_id, original_file_name, saved_file_name, file_path, content_type, upload_date " +
                         "FROM attachments WHERE assignment_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> attachment = new HashMap<>();
                attachment.put("id", rs.getInt("id"));
                attachment.put("assignmentId", rs.getInt("assignment_id"));
                attachment.put("originalFileName", rs.getString("original_file_name"));
                attachment.put("savedFileName", rs.getString("saved_file_name"));
                
                // 파일 경로 표준화
                String filePath = rs.getString("file_path");
                if (filePath != null) {
                    // 슬래시로 경로 구분자 표준화
                    filePath = filePath.replace('\\', '/');
                    // 경로가 uploads/로 시작하는지 확인하고 아니면 추가
                    if (!filePath.startsWith("uploads/")) {
                        filePath = "uploads/" + filePath;
                    }
                }
                
                attachment.put("filePath", filePath);
                attachment.put("path", filePath); // 하위 호환성 유지
                attachment.put("contentType", rs.getString("content_type"));
                attachment.put("uploadDate", rs.getTimestamp("upload_date"));
                
                attachments.add(attachment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(rs, pstmt, conn);
        }
        
        return attachments;
    }
    
    /**
     * 첨부파일 ID로 첨부파일 정보 조회 (Map 형태로 반환)
     * @param id 첨부파일 ID
     * @return 첨부파일 정보
     */
    public Map<String, Object> getAttachmentAsMap(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Map<String, Object> attachment = null;
        
        try {
            conn = DBUtil.getConnection();
            ensureAttachmentsTableExists(conn);
            
            String sql = "SELECT * FROM attachments WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                attachment = new HashMap<>();
                attachment.put("id", rs.getInt("id"));
                attachment.put("assignmentId", rs.getInt("assignment_id"));
                attachment.put("originalFileName", rs.getString("original_file_name"));
                attachment.put("savedFileName", rs.getString("saved_file_name"));
                
                // 파일 경로 표준화
                String filePath = rs.getString("file_path");
                if (filePath != null) {
                    // 슬래시로 경로 구분자 표준화
                    filePath = filePath.replace('\\', '/');
                    // 경로가 uploads/로 시작하는지 확인하고 아니면 추가
                    if (!filePath.startsWith("uploads/")) {
                        filePath = "uploads/" + filePath;
                    }
                }
                
                attachment.put("filePath", filePath);
                attachment.put("path", filePath); // 하위 호환성 유지
                attachment.put("contentType", rs.getString("content_type"));
                attachment.put("uploadDate", rs.getTimestamp("upload_date"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(rs, pstmt, conn);
        }
        
        return attachment;
    }
    
    /**
     * 첨부파일 추가
     * @param assignmentId 과제 ID
     * @param originalFileName 원본 파일명
     * @param savedFileName 저장된 파일명
     * @param filePath 파일 경로
     * @param contentType MIME 타입
     * @return 성공 여부
     */
    public boolean addAttachment(int assignmentId, String originalFileName, String savedFileName, String filePath, String contentType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = DBUtil.getConnection();
            ensureAttachmentsTableExists(conn);
            
            String sql = "INSERT INTO attachments (assignment_id, original_file_name, saved_file_name, file_path, content_type) " +
                         "VALUES (?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            pstmt.setString(2, originalFileName);
            pstmt.setString(3, savedFileName);
            pstmt.setString(4, filePath);
            pstmt.setString(5, contentType);
            
            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(null, pstmt, conn);
        }
        
        return result;
    }

    /**
     * attachments 테이블이 존재하는지 확인하고, 존재하지 않으면 생성합니다.
     * @param conn 데이터베이스 연결
     * @throws SQLException SQL 예외
     */
    private void ensureAttachmentsTableExists(Connection conn) throws SQLException {
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            stmt = conn.createStatement();
            
            // 테이블 존재 여부 확인
            DatabaseMetaData meta = conn.getMetaData();
            rs = meta.getTables(null, null, "attachments", new String[] {"TABLE"});
            
            if (!rs.next()) {
                // 테이블 생성
                String createTableSQL = """
                    CREATE TABLE IF NOT EXISTS attachments (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        assignment_id INT NOT NULL,
                        original_file_name VARCHAR(255) NOT NULL,
                        saved_file_name VARCHAR(255) NOT NULL,
                        file_path VARCHAR(255) NOT NULL,
                        content_type VARCHAR(100),
                        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
                    )
                """;
                
                stmt.execute(createTableSQL);
            }
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
        }
    }
} 