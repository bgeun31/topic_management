package com.assignment.dao;

import java.sql.*;
import java.util.*;
import com.assignment.model.Course;
import com.assignment.util.DBUtil;

public class CourseDAO {

    public List<Course> getCoursesByProfessor(int professorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql =
                "SELECT c.*, " +
                "  (SELECT COUNT(*) FROM sskm0116db.enrollments e WHERE e.course_id = c.id) AS student_count " +
                "FROM sskm0116db.courses c " +
                "WHERE c.professor_id = ? " +
                "ORDER BY c.created_date DESC";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, professorId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = new Course();
                course.setId(rs.getInt("id"));
                course.setCourseName(rs.getString("course_name"));
                course.setCourseCode(rs.getString("course_code"));
                course.setSemester(rs.getString("semester"));
                course.setDescription(rs.getString("description"));
                course.setProfessorId(rs.getInt("professor_id"));
                course.setCreatedDate(rs.getString("created_date"));
                course.setStudentCount(rs.getInt("student_count"));
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return courses;
    }

    public Course getCourseById(int courseId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Course course = null;

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT c.*, u.name AS professor_name FROM sskm0116db.courses c " +
                         "JOIN sskm0116db.users u ON c.professor_id = u.id WHERE c.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                course = new Course();
                course.setId(rs.getInt("id"));
                course.setCourseName(rs.getString("course_name"));
                course.setCourseCode(rs.getString("course_code"));
                course.setSemester(rs.getString("semester"));
                course.setDescription(rs.getString("description"));
                course.setProfessorId(rs.getInt("professor_id"));
                course.setProfessorName(rs.getString("professor_name"));
                course.setCreatedDate(rs.getString("created_date"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return course;
    }

    public boolean addCourse(Course course) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO sskm0116db.courses (course_name, course_code, semester, description, professor_id, created_date) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getCourseName());
            pstmt.setString(2, course.getCourseCode());
            pstmt.setString(3, course.getSemester());
            pstmt.setString(4, course.getDescription());
            pstmt.setInt(5, course.getProfessorId());
            pstmt.setString(6, course.getCreatedDate());

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public boolean updateCourse(Course course) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "UPDATE sskm0116db.courses SET course_name = ?, course_code = ?, semester = ?, description = ? " +
                         "WHERE id = ? AND professor_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getCourseName());
            pstmt.setString(2, course.getCourseCode());
            pstmt.setString(3, course.getSemester());
            pstmt.setString(4, course.getDescription());
            pstmt.setInt(5, course.getId());
            pstmt.setInt(6, course.getProfessorId());

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public boolean deleteCourse(int courseId, int professorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            conn = DBUtil.getConnection();
            String sql = "DELETE FROM sskm0116db.courses WHERE id = ? AND professor_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            pstmt.setInt(2, professorId);

            int count = pstmt.executeUpdate();
            result = count > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(null, pstmt, conn);
        }

        return result;
    }

    public List<Course> getRecentCourses(int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT c.*, u.name AS professor_name FROM sskm0116db.courses c " +
                         "JOIN sskm0116db.users u ON c.professor_id = u.id " +
                         "ORDER BY c.created_date DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);

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
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return courses;
    }

    public List<Course> getAvailableCourses(int studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT c.*, u.name AS professor_name FROM sskm0116db.courses c " +
                         "JOIN sskm0116db.users u ON c.professor_id = u.id " +
                         "WHERE c.id NOT IN (SELECT course_id FROM sskm0116db.enrollments WHERE student_id = ?) " +
                         "ORDER BY c.created_date DESC";
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
                courses.add(course);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }

        return courses;
    }
}
