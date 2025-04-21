package com.assignment.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBUtil {

    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String DB_NAME = "";
    private static final String DB_URL =
        "jdbc:mysql://localhost:3306/" + DB_NAME + "?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";
    private static final String ROOT_URL =
        "jdbc:mysql://localhost:3306/?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";

    private static final String USER = "root";
    private static final String PASS = "";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(JDBC_DRIVER);
            return DriverManager.getConnection(DB_URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC 드라이버를 찾을 수 없습니다.", e);
        }
    }

    public static void close(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void initializeDatabase() {
        try (
            // 1. DB 없는 상태에서 root 연결
            Connection rootConn = DriverManager.getConnection(ROOT_URL, USER, PASS);
            Statement rootStmt = rootConn.createStatement()
        ) {
            System.out.println("🔄 InitServlet 실행 중 - DB 초기화 시도 중...");

            // 2. DB 생성
            rootStmt.execute("CREATE DATABASE IF NOT EXISTS " + DB_NAME + " CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci");

            // 3. 생성한 DB로 접속
            try (
                Connection conn = DriverManager.getConnection(DB_URL, USER, PASS);
                Statement stmt = conn.createStatement()
            ) {
                // 4. 테이블 생성
                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.users (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        username VARCHAR(50) NOT NULL UNIQUE,
                        password VARCHAR(100) NOT NULL,
                        name VARCHAR(100) NOT NULL,
                        email VARCHAR(100) NOT NULL,
                        user_type ENUM('professor', 'student') NOT NULL,
                        created_date DATETIME NOT NULL
                    )
                """);

                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.courses (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        course_name VARCHAR(100) NOT NULL,
                        course_code VARCHAR(20) NOT NULL,
                        semester VARCHAR(20) NOT NULL,
                        description TEXT,
                        professor_id INT NOT NULL,
                        created_date DATE NOT NULL,
                        FOREIGN KEY (professor_id) REFERENCES users(id) ON DELETE CASCADE
                    )
                """);

                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.enrollments (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        student_id INT NOT NULL,
                        course_id INT NOT NULL,
                        enrollment_date DATETIME NOT NULL,
                        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
                        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
                        UNIQUE KEY (student_id, course_id)
                    )
                """);

                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.assignments (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        course_id INT NOT NULL,
                        title VARCHAR(200) NOT NULL,
                        description TEXT NOT NULL,
                        created_date DATETIME NOT NULL,
                        due_date DATE NOT NULL,
                        file_name VARCHAR(255),
                        file_path VARCHAR(255),
                        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
                    )
                """);

                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.submissions (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        assignment_id INT NOT NULL,
                        student_id INT NOT NULL,
                        content TEXT NOT NULL,
                        submission_date DATETIME NOT NULL,
                        file_name VARCHAR(255),
                        file_path VARCHAR(255),
                        grade VARCHAR(10),
                        feedback TEXT,
                        FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
                        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
                        UNIQUE KEY (assignment_id, student_id)
                    )
                """);

                stmt.execute("""
                    CREATE TABLE IF NOT EXISTS sskm0116db.notifications (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        user_id INT NOT NULL,
                        message TEXT NOT NULL,
                        created_date DATETIME NOT NULL,
                        is_read BOOLEAN NOT NULL DEFAULT false,
                        link VARCHAR(255),
                        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                    )
                """);

                System.out.println("✅ 데이터베이스 및 테이블 초기화 완료");
            }

        } catch (SQLException e) {
            System.out.println("❌ DB 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
