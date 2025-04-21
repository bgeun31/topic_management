package com.assignment.dao;

import java.sql.*;
import java.util.*;
import com.assignment.model.Notification;
import com.assignment.util.DBUtil;

public class NotificationDAO {

    public List<Notification> getNotificationsByUser(int userId, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Notification> notifications = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT * FROM sskm0116db.notifications WHERE user_id = ? ORDER BY created_date DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                Notification notification = new Notification();
                notification.setId(rs.getInt("id"));
                notification.setUserId(rs.getInt("user_id"));
                notification.setMessage(rs.getString("message"));
                notification.setCreatedDate(rs.getString("created_date"));
                notification.setRead(rs.getBoolean("is_read"));
                notification.setLink(rs.getString("link"));
                notifications.add(notification);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return notifications;
    }

    public int getUnreadCount(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM sskm0116db.notifications WHERE user_id = ? AND is_read = false";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return count;
    }

    public boolean addNotification(Notification notification) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO sskm0116db.notifications (user_id, message, created_date, is_read, link) " +
                         "VALUES (?, ?, NOW(), false, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, notification.getUserId());
            pstmt.setString(2, notification.getMessage());
            pstmt.setString(3, notification.getLink());

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public boolean markAsRead(int notificationId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE sskm0116db.notifications SET is_read = true WHERE id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, notificationId);
            pstmt.setInt(2, userId);

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public boolean markAllAsRead(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE sskm0116db.notifications SET is_read = true WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public void notifyNewAssignment(int courseId, int assignmentId, String assignmentTitle) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String sql = "SELECT student_id FROM sskm0116db.enrollments WHERE course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                int studentId = rs.getInt("student_id");

                Notification notification = new Notification();
                notification.setUserId(studentId);
                notification.setMessage("새로운 과제가 등록되었습니다: " + assignmentTitle);
                notification.setLink("assignment_view.jsp?id=" + assignmentId);

                addNotification(notification);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public void notifyAssignmentUpdated(int courseId, int assignmentId, String assignmentTitle) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String sql = "SELECT student_id FROM sskm0116db.enrollments WHERE course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                int studentId = rs.getInt("student_id");

                Notification notification = new Notification();
                notification.setUserId(studentId);
                notification.setMessage("과제가 수정되었습니다: " + assignmentTitle);
                notification.setLink("assignment_view.jsp?id=" + assignmentId);

                addNotification(notification);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public void notifySubmission(int assignmentId, int studentId, String studentName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String sql = "SELECT c.professor_id, a.title FROM sskm0116db.assignments a " +
                         "JOIN sskm0116db.courses c ON a.course_id = c.id " +
                         "WHERE a.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                int professorId = rs.getInt("professor_id");
                String assignmentTitle = rs.getString("title");

                Notification notification = new Notification();
                notification.setUserId(professorId);
                notification.setMessage(studentName + " 학생이 '" + assignmentTitle + "' 과제를 제출했습니다.");
                notification.setLink("submission_view.jsp?id=" + assignmentId + "&studentId=" + studentId);

                addNotification(notification);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public void notifyGraded(int submissionId, int studentId, String assignmentTitle) {
        Notification notification = new Notification();
        notification.setUserId(studentId);
        notification.setMessage("'" + assignmentTitle + "' 과제가 채점되었습니다.");
        notification.setLink("assignment_view.jsp?id=" + submissionId);

        addNotification(notification);
    }
}
