<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.UserDAO" %>
<%@ page import="com.assignment.model.User" %>
<%@ page import="java.io.PrintWriter" %>

<%
request.setCharacterEncoding("UTF-8");
response.setContentType("text/html; charset=UTF-8");

String username = request.getParameter("username");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String name = request.getParameter("name");
String email = request.getParameter("email");
String userType = request.getParameter("userType");

try {
    // 비밀번호 확인
    if (!password.equals(confirmPassword)) {
        response.sendRedirect("register.jsp?error=password");
        return;
    }

    UserDAO userDAO = new UserDAO();

    // 아이디 중복 확인
    if (userDAO.isUserExists(username)) {
        response.sendRedirect("register.jsp?error=duplicate");
        return;
    }

    // 사용자 객체 생성
    User user = new User();
    user.setUsername(username);
    user.setPassword(password);
    user.setName(name);
    user.setEmail(email);
    user.setUserType(userType);

    // 회원가입 처리
    boolean result = userDAO.register(user);

    if (result) {
        response.sendRedirect("login.jsp?registered=1");
    } else {
%>
        <h2>회원가입 처리 실패: 데이터베이스에 저장되지 않았습니다.</h2>
<%
    }

} catch (Exception e) {
%>
    <h2>회원가입 처리 중 예외 발생</h2>
    <pre><%= e.toString() %></pre>
<%
}
%>
