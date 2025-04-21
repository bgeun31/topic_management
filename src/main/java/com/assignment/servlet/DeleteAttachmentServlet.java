package com.assignment.servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.AttachmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.model.Assignment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deleteAttachment")
public class DeleteAttachmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        
        // 교수가 아니면 권한 없음
        if (userType == null || !userType.equals("professor")) {
            sendErrorResponse(response, "권한이 없습니다.");
            return;
        }
        
        Integer professorId = (Integer) session.getAttribute("userId");
        if (professorId == null) {
            sendErrorResponse(response, "로그인이 필요합니다.");
            return;
        }
        
        // 첨부파일 ID 가져오기
        int attachmentId;
        try {
            attachmentId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            sendErrorResponse(response, "유효하지 않은 첨부파일 ID입니다.");
            return;
        }
        
        // 첨부파일 정보 가져오기
        AttachmentDAO attachmentDAO = new AttachmentDAO();
        Map<String, Object> attachment = attachmentDAO.getAttachmentAsMap(attachmentId);
        
        if (attachment == null) {
            sendErrorResponse(response, "첨부파일을 찾을 수 없습니다.");
            return;
        }
        
        // 과제 ID로 권한 확인
        Integer assignmentId = (Integer) attachment.get("assignmentId");
        if (assignmentId == null) {
            sendErrorResponse(response, "첨부파일 정보가 올바르지 않습니다.");
            return;
        }
        
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
        
        if (assignment == null) {
            sendErrorResponse(response, "연결된 과제를 찾을 수 없습니다.");
            return;
        }
        
        // 교수 권한 확인
        CourseDAO courseDAO = new CourseDAO();
        if (!courseDAO.isProfessorOfCourse(professorId, assignment.getCourseId())) {
            sendErrorResponse(response, "이 과제에 대한 권한이 없습니다.");
            return;
        }
        
        // 첨부파일 삭제
        try {
            // 물리적 파일 삭제
            String filePath = (String) attachment.get("filePath");
            String realPath = getServletContext().getRealPath("/");
            File file = new File(realPath + File.separator + filePath);
            
            if (file.exists()) {
                file.delete();
            }
            
            // DB에서 첨부파일 정보 삭제
            boolean result = attachmentDAO.deleteAttachment(attachmentId);
            
            if (result) {
                sendSuccessResponse(response);
            } else {
                sendErrorResponse(response, "첨부파일 삭제 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(response, "첨부파일 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    private void sendSuccessResponse(HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true}");
        out.flush();
    }
    
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"" + message + "\"}");
        out.flush();
    }
} 