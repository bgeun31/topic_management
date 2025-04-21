package com.assignment.servlet;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.AttachmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.dao.NotificationDAO;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@WebServlet("/assignmentAdd")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize = 10 * 1024 * 1024,       // 10MB
    maxRequestSize = 50 * 1024 * 1024     // 50MB
)
public class AssignmentAddServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");

        if (userType == null || !userType.equals("professor")) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer professorIdObj = (Integer) session.getAttribute("userId");
        if (professorIdObj == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int professorId = professorIdObj;

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String dueDate = request.getParameter("dueDate");

            CourseDAO courseDAO = new CourseDAO();
            if (!courseDAO.isProfessorOfCourse(professorId, courseId)) {
                response.sendRedirect("course_list.jsp?error=unauthorized");
                return;
            }

            // 과제 기본 정보 저장
            AssignmentDAO assignmentDAO = new AssignmentDAO();
            int assignmentId = assignmentDAO.addAssignmentAndGetId(courseId, title, description, dueDate, null, null);

            if (assignmentId > 0) {
                // 첨부파일 디렉토리 설정
                String uploadPath = getServletContext().getRealPath("/uploads/assignments/" + assignmentId);
                
                // 첨부파일 처리
                Collection<Part> fileParts = FileUtil.getFileParts(request, "files");
                if (fileParts != null && !fileParts.isEmpty()) {
                    List<Map<String, String>> uploadedFiles = FileUtil.uploadMultipleFiles(fileParts, uploadPath);
                    
                    if (!uploadedFiles.isEmpty()) {
                        AttachmentDAO attachmentDAO = new AttachmentDAO();
                        
                        for (Map<String, String> fileInfo : uploadedFiles) {
                            attachmentDAO.addAttachment(
                                assignmentId,
                                fileInfo.get("originalFileName"),
                                fileInfo.get("savedFileName"),
                                fileInfo.get("filePath"),
                                fileInfo.get("contentType")
                            );
                        }
                    }
                }
                
                // 수강생들에게 알림 전송
                NotificationDAO notificationDAO = new NotificationDAO();
                notificationDAO.notifyNewAssignment(courseId, assignmentId, title);
                
                // 성공 페이지로 리다이렉트
                response.sendRedirect("assignment_management.jsp?courseId=" + courseId + "&success=add");
            } else {
                response.sendRedirect("assignment_form.jsp?error=1");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("assignment_form.jsp?error=invalid");
        }
    }
}