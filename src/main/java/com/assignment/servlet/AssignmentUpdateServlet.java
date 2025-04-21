package com.assignment.servlet;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.AttachmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.model.Assignment;
import com.assignment.model.Course;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@WebServlet("/assignmentUpdate")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class AssignmentUpdateServlet extends HttpServlet {
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

        int professorId = (Integer) session.getAttribute("userId");

        int assignmentId = Integer.parseInt(request.getParameter("id"));
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dueDate = request.getParameter("dueDate");
        String removeFile = request.getParameter("removeFile");

        CourseDAO courseDAO = new CourseDAO();
        Course course = courseDAO.getCourseById(courseId);
        if (course == null || course.getProfessorId() != professorId) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }

        AssignmentDAO assignmentDAO = new AssignmentDAO();
        Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
        if (assignment == null) {
            response.sendRedirect("assignment_management.jsp");
            return;
        }

        // 기존 파일 삭제 처리
        if (removeFile != null && removeFile.equals("true")) {
            if (assignment.getFileName() != null && !assignment.getFileName().isEmpty()) {
                FileUtil.deleteFile(request, assignment.getFilePath());
                assignment.setFileName(null);
                assignment.setFilePath(null);
            }
        }

        // 기본 필드 업데이트
        assignment.setTitle(title);
        assignment.setDescription(description);
        assignment.setDueDate(dueDate);

        // 새 첨부 파일 처리
        try {
            Collection<Part> parts = request.getParts();
            Collection<Part> fileParts = new ArrayList<>();
            
            // files 필드만 필터링
            for (Part part : parts) {
                if (part.getName().equals("files") && part.getSize() > 0 && 
                    part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    fileParts.add(part);
                }
            }
            
            if (!fileParts.isEmpty()) {
                // 첨부파일 저장
                List<Map<String, String>> uploadedFiles = FileUtil.uploadMultipleFiles(fileParts, "uploads/assignments");
                
                if (uploadedFiles != null && !uploadedFiles.isEmpty()) {
                    // 파일이 업로드된 경우 첨부파일 DB에 저장
                    AttachmentDAO attachmentDAO = new AttachmentDAO();
                    
                    System.out.println("업로드된 파일 정보: " + uploadedFiles.size() + "개");
                    
                    for (Map<String, String> fileInfo : uploadedFiles) {
                        // 업로드된 파일 정보 디버깅
                        System.out.println("파일 정보: " + fileInfo);
                        
                        String originalFileName = fileInfo.get("originalFileName");
                        String savedFileName = fileInfo.get("savedFileName");
                        String filePath = fileInfo.get("filePath");
                        String contentType = fileInfo.get("contentType");
                        
                        System.out.println("파일 첨부 추가: " + originalFileName + " -> " + filePath + " (" + contentType + ")");
                        
                        boolean added = attachmentDAO.addAttachment(
                            assignmentId,
                            originalFileName, 
                            savedFileName,
                            filePath,
                            contentType
                        );
                        
                        System.out.println("첨부파일 추가 결과: " + (added ? "성공" : "실패"));
                    }
                } else {
                    System.out.println("파일 업로드 결과가 비어있거나 null입니다.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 파일 업로드 실패해도 기본 정보는 저장
        }

        boolean updated = assignmentDAO.updateAssignment(assignment);

        if (updated) {
            response.sendRedirect("assignment_detail.jsp?id=" + assignmentId);
        } else {
            response.sendRedirect("assignment_edit.jsp?id=" + assignmentId + "&error=1");
        }
    }
}
