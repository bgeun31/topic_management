<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.dao.UserDAO" %>
<%@ page import="com.assignment.model.User" %>
<%@ page import="com.assignment.dao.CourseDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String userType = request.getParameter("userType");
    
    UserDAO userDAO = new UserDAO();
    
    User user = userDAO.login(username, password, userType);
    
    if (user != null) {
        session.setAttribute("userId", user.getId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("userType", userType);
        
        response.sendRedirect("index.jsp");
    } else {
        response.sendRedirect("login.jsp?error=1");
    }
%>
