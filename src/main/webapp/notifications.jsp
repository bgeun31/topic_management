<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="com.assignment.dao.*" %>
<%
    // 로그인 확인
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    
    // 알림 목록 가져오기
    NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> notifications = notificationDAO.getNotificationsByUser(userId, 50);
    
    // 모든 알림을 읽음으로 표시
    notificationDAO.markAllAsRead(userId);
%>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>알림 - 과제 관리 시스템</title>
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
                    <% if (userType.equals("professor")) { %>
                    <li><a href="course_management.jsp"><i class="fas fa-book"></i> 과목 관리</a></li>
                    <li><a href="assignment_management.jsp"><i class="fas fa-tasks"></i> 과제 관리</a></li>
                    <% } else { %>
                    <li><a href="course_list.jsp"><i class="fas fa-book"></i> 수강 과목</a></li>
                    <li><a href="assignment_list.jsp"><i class="fas fa-tasks"></i> 과제 목록</a></li>
                    <% } %>
                    <li><a href="notifications.jsp" class="active"><i class="fas fa-bell"></i> 알림</a></li>
                    <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 로그아웃</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="content-header">
                <h2><i class="fas fa-bell"></i> 알림</h2>
            </section>
            
            <section class="notifications-list">
                <% if (notifications.isEmpty()) { %>
                <p class="empty-list">알림이 없습니다.</p>
                <% } else { %>
                <ul class="notification-items">
                    <% for (Notification notification : notifications) { %>
                    <li class="notification-item <%= notification.isRead() ? "read" : "unread" %>">
                        <div class="notification-content">
                            <p><%= notification.getMessage() %></p>
                            <span class="notification-date"><i class="fas fa-clock"></i> <%= notification.getCreatedDate() %></span>
                        </div>
                        <div class="notification-actions">
                            <a href="<%= notification.getLink() %>" class="btn-small">보기</a>
                        </div>
                    </li>
                    <% } %>
                </ul>
                <% } %>
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
