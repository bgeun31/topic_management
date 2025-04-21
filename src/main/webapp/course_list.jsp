<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    // 로그인 확인 및 학생 권한 확인
    if (session.getAttribute("userType") == null || !session.getAttribute("userType").equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int studentId = (Integer) session.getAttribute("userId");
    
    // 수강 중인 과목 목록 가져오기
    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    List<Course> enrolledCourses = enrollmentDAO.getEnrolledCourses(studentId);
    
    // 수강 가능한 과목 목록 가져오기
    CourseDAO courseDAO = new CourseDAO();
    List<Course> availableCourses = courseDAO.getAvailableCourses(studentId);
    
    // 알림 메시지 가져오기
    String alertMessage = (String) session.getAttribute("alertMessage");
    String alertType = (String) session.getAttribute("alertType");
    
    // 메시지를 표시했으면 세션에서 제거
    if (alertMessage != null) {
        session.removeAttribute("alertMessage");
        session.removeAttribute("alertType");
    }
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", "수강 과목 - 과제 관리 시스템");
%>
<%@ include file="header.jsp" %>

<style>
/* 인라인 스타일로 링크 밑줄 제거 확실히 적용 */
.data-table a, .data-table a:hover, .data-table a:visited, .data-table a:active {
    text-decoration: none !important;
    border-bottom: none !important;
    text-underline-offset: -999px !important;
    text-decoration-thickness: 0 !important;
}

.btn, .btn-small {
    display: inline-block;
    text-decoration: none !important;
    border: 1px solid #ddd;
    padding: 5px 10px;
    border-radius: 4px;
    background-color: #f8f9fa;
    margin-right: 5px;
    color: #333;
}

.btn-primary {
    background-color: var(--primary-color);
    border-color: var(--primary-dark);
    color: white;
}

.btn-danger {
    background-color: var(--danger-color);
    border-color: #c82333;
    color: white;
}

/* 알림 메시지 스타일 */
.alert {
    padding: 15px;
    margin-bottom: 20px;
    border: 1px solid transparent;
    border-radius: 4px;
}

.alert-success {
    background-color: #dff0d8;
    border-color: #d6e9c6;
    color: #3c763d;
}

.alert-danger {
    background-color: #f2dede;
    border-color: #ebccd1;
    color: #a94442;
}
</style>

<main>
    <section class="content-header">
        <h2><i class="fas fa-list"></i> 수강 과목</h2>
    </section>
    
    <% if (alertMessage != null) { %>
    <section class="alert <%= alertType.equals("success") ? "alert-success" : "alert-danger" %>">
        <p><i class="fas <%= alertType.equals("success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i> <%= alertMessage %></p>
    </section>
    <% } %>
    
    <section class="enrolled-courses">
        <h3><i class="fas fa-book"></i> 내 수강 과목</h3>
        <% if (enrolledCourses.isEmpty()) { %>
        <p>수강 중인 과목이 없습니다.</p>
        <% } else { %>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>과목명</th>
                        <th>교수</th>
                        <th>학기</th>
                        <th>수강 신청일</th>
                        <th>액션</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Course course : enrolledCourses) { %>
                    <tr>
                        <td><%= course.getCourseName() %></td>
                        <td><%= course.getProfessorName() %></td>
                        <td><%= course.getSemester() %></td>
                        <td><%= course.getEnrollmentDate() %></td>
                        <td class="actions">
                            <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세</a>
                            <a href="assignment_list.jsp?courseId=<%= course.getId() %>" class="btn-small">과제</a>
                            <a href="unenroll.jsp?id=<%= course.getId() %>&csrfToken=<%= csrfToken %>" class="btn-small">수강 취소</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
    
    <section class="available-courses">
        <h3><i class="fas fa-plus-circle"></i> 수강 가능한 과목</h3>
        <% if (availableCourses.isEmpty()) { %>
        <p>현재 수강 가능한 과목이 없습니다.</p>
        <% } else { %>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>과목명</th>
                        <th>교수</th>
                        <th>학기</th>
                        <th>개설일</th>
                        <th>액션</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Course course : availableCourses) { %>
                    <tr>
                        <td><%= course.getCourseName() %></td>
                        <td><%= course.getProfessorName() %></td>
                        <td><%= course.getSemester() %></td>
                        <td><%= course.getCreatedDate() %></td>
                        <td class="actions">
                            <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small">상세</a>
                            <a href="enroll.jsp?id=<%= course.getId() %>" class="btn-small">수강 신청</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>

<%@ include file="footer.jsp" %>
