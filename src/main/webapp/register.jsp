<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - 과제 관리 시스템</title>
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
                    <li><a href="login.jsp"><i class="fas fa-sign-in-alt"></i> 로그인</a></li>
                    <li><a href="register.jsp" class="active"><i class="fas fa-user-plus"></i> 회원가입</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="form-container">
                <h2><i class="fas fa-user-plus"></i> 회원가입</h2>
                <% 
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                <div class="error-message">
                    <% if (error.equals("duplicate")) { %>
                        <i class="fas fa-exclamation-circle"></i> 이미 사용 중인 아이디입니다.
                    <% } else if (error.equals("password")) { %>
                        <i class="fas fa-exclamation-circle"></i> 비밀번호와 비밀번호 확인이 일치하지 않습니다.
                    <% } else { %>
                        <i class="fas fa-exclamation-circle"></i> 회원가입 중 오류가 발생했습니다.
                    <% } %>
                </div>
                <% } %>
                <form action="registerProcess.jsp" method="post">
                    <div class="form-group">
                        <label for="username"><i class="fas fa-user"></i> 아이디:</label>
                        <input type="text" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="password"><i class="fas fa-lock"></i> 비밀번호:</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword"><i class="fas fa-lock"></i> 비밀번호 확인:</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                    </div>
                    <div class="form-group">
                        <label for="name"><i class="fas fa-id-card"></i> 이름:</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="email"><i class="fas fa-envelope"></i> 이메일:</label>
                        <input type="email" id="email" name="email" required>
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
                        <button type="submit" class="btn"><i class="fas fa-user-plus"></i> 회원가입</button>
                    </div>
                </form>
                <p class="form-footer">
                    이미 계정이 있으신가요? <a href="login.jsp">로그인</a>
                </p>
            </section>
        </main>
        
        <footer>
            <p>&copy; 2025 과제 관리 시스템. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
