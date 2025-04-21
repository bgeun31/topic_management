package com.assignment.servlet;

import java.io.IOException;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.dao.NotificationDAO;
import com.assignment.dao.SubmissionDAO;
import com.assignment.model.Assignment;
import com.assignment.model.Course;
import com.assignment.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/gradeProcess")
public class GradeProcessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // UTF-8 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // 세션 확인
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        // 교수 권한 확인
        if (userType == null || !userType.equals("professor")) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // CSRF 토큰 검증
        String token = request.getParameter("csrfToken");
        String sessionToken = (String) session.getAttribute("csrfToken");
        
        if (sessionToken == null || token == null || !token.equals(sessionToken)) {
            response.sendRedirect("error.jsp?message=보안+토큰이+유효하지+않습니다");
            return;
        }
        
        try {
            // 파라미터 가져오기
            int submissionId = Integer.parseInt(request.getParameter("submissionId"));
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            int studentId = Integer.parseInt(request.getParameter("studentId"));
            String grade = request.getParameter("grade");
            String feedback = request.getParameter("feedback");
            
            // 과제 정보 가져오기
            AssignmentDAO assignmentDAO = new AssignmentDAO();
            Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
            
            if (assignment == null) {
                response.sendRedirect("assignment_management.jsp");
                return;
            }
            
            // 과목 정보 가져오기
            CourseDAO courseDAO = new CourseDAO();
            Course course = courseDAO.getCourseById(assignment.getCourseId());
            
            if (course == null) {
                response.sendRedirect("assignment_management.jsp");
                return;
            }
            
            // 교수 권한 확인
            int professorId = (Integer) session.getAttribute("userId");
            if (course.getProfessorId() != professorId) {
                response.sendRedirect("assignment_management.jsp");
                return;
            }
            
            // 성적 업데이트
            SubmissionDAO submissionDAO = new SubmissionDAO();
            boolean success = submissionDAO.gradeSubmission(submissionId, grade, feedback);
            
            if (success) {
                // 알림 생성
                NotificationDAO notificationDAO = new NotificationDAO();
                notificationDAO.notifyGraded(submissionId, studentId, assignment.getTitle());
                
                // 성공 시 과제 상세 페이지로 리다이렉트
                response.sendRedirect("assignment_detail.jsp?id=" + assignmentId + "&success=grade");
            } else {
                response.sendRedirect("error.jsp?message=성적+등록에+실패했습니다");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("error.jsp?message=잘못된+요청+파라미터");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=서버+오류가+발생했습니다");
        }
    }
} 