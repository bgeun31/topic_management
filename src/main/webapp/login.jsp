<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 과제 관리 시스템</title>
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
                    <li><a href="login.jsp" class="active"><i class="fas fa-sign-in-alt"></i> 로그인</a></li>
                    <li><a href="register.jsp"><i class="fas fa-user-plus"></i> 회원가입</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="form-container">
                <h2><i class="fas fa-sign-in-alt"></i> 로그인</h2>
                <% 
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i> 아이디 또는 비밀번호가 올바르지 않습니다.
                </div>
                <% } %>
                
                <% 
                    String registered = request.getParameter("registered");
                    if (registered != null) {
                %>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> 회원가입이 완료되었습니다. 로그인해주세요.
                </div>
                <% } %>
                
                <form action="loginProcess.jsp" method="post">
                    <div class="form-group">
                        <label for="username"><i class="fas fa-user"></i> 아이디:</label>
                        <input type="text" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="password"><i class="fas fa-lock"></i> 비밀번호:</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-users"></i> 사용자 유형:</label>
                        <div class="radio-group">
                            <input type="radio" id="professor" name="userType" value="professor">
                            <label for="professor">교수</label>
                            <input type="radio" id="student" name="userType" value="student" checked>
                            <label for="student">학생</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn"><i class="fas fa-sign-in-alt"></i> 로그인</button>
                    </div>
                </form>
                <p class="form-footer">
                    계정이 없으신가요? <a href="register.jsp">회원가입</a>
                </p>    
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
