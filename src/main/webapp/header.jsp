<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignment.util.SecurityUtil" %>
<%
    if (request.getAttribute("userType") == null && session.getAttribute("userType") != null) {
        request.setAttribute("userType", session.getAttribute("userType"));
        request.setAttribute("userName", session.getAttribute("userName"));
        request.setAttribute("userId", session.getAttribute("userId"));
    }

    String userType = (String) request.getAttribute("userType");
    String userName = (String) request.getAttribute("userName");

    String csrfToken = SecurityUtil.generateCSRFToken();
    session.setAttribute("csrfToken", csrfToken);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "과제 관리 시스템" %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
<div class="container">
    <header>
        <h1><i class="fas fa-graduation-cap"></i> 과제 관리 시스템</h1>
        <button class="menu-toggle"><i class="fas fa-bars"></i></button>
        <nav>
            <ul>
                <li><a href="index.jsp" <%= request.getRequestURI().endsWith("index.jsp") ? "class=\"active\"" : "" %>><i class="fas fa-home"></i> 홈</a></li>
                <% if (userType == null) { %>
                    <li><a href="login.jsp" <%= request.getRequestURI().endsWith("login.jsp") ? "class=\"active\"" : "" %>><i class="fas fa-sign-in-alt"></i> 로그인</a></li>
                    <li><a href="register.jsp" <%= request.getRequestURI().endsWith("register.jsp") ? "class=\"active\"" : "" %>><i class="fas fa-user-plus"></i> 회원가입</a></li>
                <% } else if (userType.equals("professor")) { %>
                    <li><a href="course_management.jsp" <%= request.getRequestURI().contains("course_") ? "class=\"active\"" : "" %>><i class="fas fa-book"></i> 과목 관리</a></li>
                    <li><a href="assignment_management.jsp" <%= request.getRequestURI().contains("assignment_") ? "class=\"active\"" : "" %>><i class="fas fa-tasks"></i> 과제 관리</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                <% } else if (userType.equals("student")) { %>
                    <li><a href="course_list.jsp" <%= request.getRequestURI().contains("course_") ? "class=\"active\"" : "" %>><i class="fas fa-list"></i> 수강 과목</a></li>
                    <li><a href="assignment_list.jsp" <%= request.getRequestURI().contains("assignment_") || request.getRequestURI().contains("submission_") ? "class=\"active\"" : "" %>><i class="fas fa-clipboard-list"></i> 과제 목록</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                <% } %>
            </ul>
        </nav>
        <%-- 사용자 정보 숨김 처리 완료 --%>
    </header>
