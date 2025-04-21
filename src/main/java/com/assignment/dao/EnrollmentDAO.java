package com.assignment.dao;

import java.sql.*;
import java.util.*;
import com.assignment.model.Course;
import com.assignment.model.User;
import com.assignment.util.DBUtil;

public class EnrollmentDAO {

    public List<Course> getEnrolledCourses(int studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT c.*, u.name AS professor_name, e.enrollment_date " +
                         "FROM sskm0116db.enrollments e " +
                         "JOIN sskm0116db.courses c ON e.course_id = c.id " +
                         "JOIN sskm0116db.users u ON c.professor_id = u.id " +
                         "WHERE e.student_id = ? " +
                         "ORDER BY e.enrollment_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = new Course();
                course.setId(rs.getInt("id"));
                course.setCourseName(rs.getString("course_name"));
                course.setCourseCode(rs.getString("course_code"));
                course.setSemester(rs.getString("semester"));
                course.setDescription(rs.getString("description"));
                course.setProfessorId(rs.getInt("professor_id"));
                course.setProfessorName(rs.getString("professor_name"));
                course.setCreatedDate(rs.getString("created_date"));
                course.setEnrollmentDate(rs.getString("enrollment_date"));
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return courses;
    }

    public boolean enrollCourse(int studentId, int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO sskm0116db.enrollments (student_id, course_id, enrollment_date) " +
                         "VALUES (?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
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

    public boolean unenrollCourse(int studentId, int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "DELETE FROM sskm0116db.enrollments WHERE student_id = ? AND course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
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

    public boolean isEnrolled(int studentId, int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean enrolled = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM sskm0116db.enrollments WHERE student_id = ? AND course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, courseId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                enrolled = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return enrolled;
    }

    public List<User> getEnrolledStudents(int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<User> students = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT u.*, e.enrollment_date AS created_date FROM sskm0116db.enrollments e " +
                         "JOIN sskm0116db.users u ON e.student_id = u.id " +
                         "WHERE e.course_id = ? " +
                         "ORDER BY e.enrollment_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                User student = new User();
                student.setId(rs.getInt("id"));
                student.setUsername(rs.getString("username"));
                student.setName(rs.getString("name"));
                student.setEmail(rs.getString("email"));
                student.setUserType(rs.getString("user_type"));
                student.setCreatedDate(rs.getString("created_date"));
                students.add(student);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return students;
    }
}
