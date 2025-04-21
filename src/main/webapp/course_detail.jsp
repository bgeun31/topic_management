<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%@ include file="header.jsp" %> 
<%
    // 로그인 확인
    if (session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 과목 ID 확인
    String courseId = request.getParameter("id");
    if (courseId == null || courseId.isEmpty()) {
        if (userType.equals("professor")) {
            response.sendRedirect("course_management.jsp");
        } else {
            response.sendRedirect("course_list.jsp");
        }
        return;
    }
    
    // 과목 정보 가져오기
    CourseDAO courseDAO = new CourseDAO();
    Course course = courseDAO.getCourseById(Integer.parseInt(courseId));
    
    if (course == null) {
        if (userType.equals("professor")) {
            response.sendRedirect("course_management.jsp");
        } else {
            response.sendRedirect("course_list.jsp");
        }
        return;
    }
    
    // 수강생 목록 가져오기 (교수인 경우)
    List<User> enrolledStudents = new ArrayList<>();
    if (userType.equals("professor")) {
        // 해당 과목이 현재 교수의 과목인지 확인
        if (course.getProfessorId() != (Integer) session.getAttribute("userId")) {
            response.sendRedirect("course_management.jsp");
            return;
        }
        
        EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
        enrolledStudents = enrollmentDAO.getEnrolledStudents(Integer.parseInt(courseId));
    }
    
    // 학생인 경우 수강 여부 확인
    boolean isEnrolled = false;
    if (userType.equals("student")) {
        int studentId = (Integer) session.getAttribute("userId");
        EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
        isEnrolled = enrollmentDAO.isEnrolled(studentId, Integer.parseInt(courseId));
    }
    
    // 과제 목록 가져오기
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    List<Assignment> assignments = assignmentDAO.getAssignmentsByCourse(Integer.parseInt(courseId));
    
    // 학생인 경우 각 과제에 대한 제출 상태 확인
    if (userType.equals("student")) {
        int studentId = (Integer) session.getAttribute("userId");
        SubmissionDAO submissionDAO = new SubmissionDAO();
        for (Assignment assignment : assignments) {
            Submission submission = submissionDAO.getSubmission(studentId, assignment.getId());
            if (submission != null) {
                assignment.setSubmitted(true);
                assignment.setSubmissionDate(submission.getSubmissionDate());
            } else {
                assignment.setSubmitted(false);
            }
        }
    }
    
    // 페이지 제목 설정
    request.setAttribute("pageTitle", course.getCourseName() + " - 과목 상세");
%>


<style>
/* 인라인 스타일로 링크 밑줄 제거 */
a, a:hover, a:visited, a:active, 
.btn, .btn-small, .btn-primary, .btn-danger,
.data-table a, .action-buttons a {
    text-decoration: none !important;
}
</style>

<main>
    <section class="content-header">
        <h2><i class="fas fa-book"></i> 과목 상세</h2>
        <% if (userType.equals("professor")) { %>
            <a href="course_management.jsp" class="btn"><i class="fas fa-arrow-left"></i> 과목 목록으로</a>
        <% } else { %>
            <a href="course_list.jsp" class="btn"><i class="fas fa-arrow-left"></i> 과목 목록으로</a>
        <% } %>
    </section>
    
    <section class="course-info">
        <h3><i class="fas fa-info-circle"></i> 과목 정보</h3>
        <div class="info-box">
            <p><i class="fas fa-book"></i> <strong>과목명:</strong> <%= course.getCourseName() %></p>
            <p><i class="fas fa-hashtag"></i> <strong>과목 코드:</strong> <%= course.getCourseCode() %></p>
            <p><i class="fas fa-calendar-alt"></i> <strong>학기:</strong> <%= course.getSemester() %></p>
            <p><i class="fas fa-user-tie"></i> <strong>교수:</strong> <%= course.getProfessorName() %></p>
            <p><i class="fas fa-calendar-plus"></i> <strong>개설일:</strong> <%= course.getCreatedDate() %></p>
            <p><i class="fas fa-align-left"></i> <strong>설명:</strong> <%= course.getDescription() %></p>
        </div>
        
        <% if (userType.equals("student") && !isEnrolled) { %>
            <div class="action-buttons">
                <a href="enroll.jsp?id=<%= course.getId() %>" class="btn btn-primary"><i class="fas fa-user-plus"></i> 수강 신청</a>
            </div>
        <% } %>
    </section>
    
    <% if (userType.equals("professor") || isEnrolled) { %>
        <section class="course-assignments">
            <h3><i class="fas fa-tasks"></i> 과제 목록</h3>
            <% if (assignments.isEmpty()) { %>
                <p>등록된 과제가 없습니다.</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>제목</th>
                                <th>등록일</th>
                                <th>마감일</th>
                                <% if (userType.equals("professor")) { %>
                                    <th>제출 현황</th>
                                <% } else { %>
                                    <th>상태</th>
                                <% } %>
                                <th>액션</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Assignment assignment : assignments) { %>
                                <tr>
                                    <td><%= assignment.getTitle() %></td>
                                    <td><%= assignment.getCreatedDate() %></td>
                                    <td><%= assignment.getDueDate() %></td>
                                    <% if (userType.equals("professor")) { %>
                                        <td><%= assignment.getSubmissionCount() %>/<%= assignment.getTotalStudents() %></td>
                                        <td class="actions">
                                            <a href="assignment_detail.jsp?id=<%= assignment.getId() %>" class="btn-small">상세</a>
                                            <a href="assignment_form.jsp?id=<%= assignment.getId() %>" class="btn-small">수정</a>
                                            <a href="assignment_delete.jsp?id=<%= assignment.getId() %>" class="btn-small">삭제</a>
                                        </td>
                                    <% } else { %>
                                        <td>
                                            <% if (assignment.isSubmitted()) { %>
                                                <span class="status-submitted"><i class="fas fa-check-circle"></i> 제출 완료 (<%= assignment.getSubmissionDate() %>)</span>
                                            <% } else { %>
                                                <span class="status-pending"><i class="fas fa-clock"></i> 미제출</span>
                                            <% } %>
                                        </td>
                                        <td class="actions">
                                            <a href="assignment_view.jsp?id=<%= assignment.getId() %>" class="btn-small">보기</a>
                                            <% if (!assignment.isSubmitted()) { %>
                                                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small">제출</a>
                                            <% } else { %>
                                                <a href="submission_form.jsp?id=<%= assignment.getId() %>" class="btn-small">재제출</a>
                                            <% } %>
                                        </td>
                                    <% } %>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
            
            <% if (userType.equals("professor")) { %>
                <div class="action-buttons">
                    <a href="assignment_form.jsp?courseId=<%= course.getId() %>" class="btn"><i class="fas fa-plus"></i> 새 과제 등록</a>
                </div>
            <% } %>
        </section>
    <% } %>
    
    <% if (userType.equals("professor")) { %>
        <section class="enrolled-students">
            <h3><i class="fas fa-users"></i> 수강생 목록</h3>
            <% if (enrolledStudents.isEmpty()) { %>
                <p>수강 중인 학생이 없습니다.</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>학번</th>
                                <th>이름</th>
                                <th>이메일</th>
                                <th>수강 신청일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User student : enrolledStudents) { %>
                                <tr>
                                    <td><%= student.getUsername() %></td>
                                    <td><%= student.getName() %></td>
                                    <td><%= student.getEmail() %></td>
                                    <td><%= student.getCreatedDate() %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>
    <% } %>
</main>

<%@ include file="footer.jsp" %>
