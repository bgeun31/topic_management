<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    // 로그인 확인 및 교수 권한 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("professor")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int professorId = (Integer) session.getAttribute("userId");
    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getCoursesByProfessor(professorId);
    
    // 성공 메시지 확인
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>과목 관리 - 과제 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1><i class="fas fa-graduation-cap"></i> 과제 관리 시스템</h1>
            <nav>
                <ul>
                    <li><a href="index.jsp"><i class="fas fa-home"></i> 홈</a></li>
                    <li><a href="course_management.jsp" class="active"><i class="fas fa-book"></i> 과목 관리</a></li>
                    <li><a href="assignment_management.jsp"><i class="fas fa-tasks"></i> 과제 관리</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="content-header">
                <h2><i class="fas fa-book"></i> 과목 관리</h2>
                <a href="course_form.jsp" class="btn"><i class="fas fa-plus"></i> 새 과목 개설</a>
            </section>
            
            <% if (success != null) { %>
            <div class="success-message">
                <% if (success.equals("add")) { %>
                    <i class="fas fa-check-circle"></i> 과목이 성공적으로 개설되었습니다.
                <% } else if (success.equals("update")) { %>
                    <i class="fas fa-check-circle"></i> 과목 정보가 성공적으로 수정되었습니다.
                <% } else if (success.equals("delete")) { %>
                    <i class="fas fa-check-circle"></i> 과목이 성공적으로 삭제되었습니다.
                <% } %>
            </div>
            <% } %>
            
            <section class="course-list">
                <h3><i class="fas fa-list"></i> 내 개설 과목</h3>
                <% if (courses.isEmpty()) { %>
                <p class="empty-list">개설한 과목이 없습니다.</p>
                <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>과목명</th>
                                <th>과목 코드</th>
                                <th>학기</th>
                                <th>개설일</th>
                                <th>수강생 수</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Course course : courses) { %>
                            <tr>
                                <td><%= course.getCourseName() %></td>
                                <td><%= course.getCourseCode() %></td>
                                <td><%= course.getSemester() %></td>
                                <td><%= course.getCreatedDate() %></td>
                                <td><span class="badge"><%= course.getStudentCount() %></span></td>
                                <td class="actions">
                                    <a href="course_detail.jsp?id=<%= course.getId() %>" class="btn-small" title="상세보기"><i class="fas fa-eye"></i></a>
                                    <a href="course_form.jsp?id=<%= course.getId() %>" class="btn-small" title="수정"><i class="fas fa-edit"></i></a>
                                    <a href="course_delete.jsp?id=<%= course.getId() %>" class="btn-small btn-danger" title="삭제" onclick="return confirm('정말 삭제하시겠습니까?');"><i class="fas fa-trash-alt"></i></a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
