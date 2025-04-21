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
                // 파일 시스템 테스트 - 간단한 테스트 파일 생성
                boolean testFileCreated = FileUtil.saveTestFile("Assignment ID: " + assignmentId + "\nTitle: " + title);
                System.out.println("테스트 파일 생성 결과: " + (testFileCreated ? "성공" : "실패"));
                
                // 첨부파일 처리
                Collection<Part> fileParts = FileUtil.getFileParts(request, "files");
                
                // 파일 파트 정보 출력
                System.out.println("====== 파일 업로드 디버그 정보 ======");
                System.out.println("요청 Content-Type: " + request.getContentType());
                System.out.println("파일 파트 개수: " + (fileParts != null ? fileParts.size() : 0));
                
                if (fileParts != null && !fileParts.isEmpty()) {
                    // 파일 파트 상세 정보 출력
                    int fileIndex = 0;
                    for (Part part : fileParts) {
                        fileIndex++;
                        System.out.println("파일 #" + fileIndex + " 정보:");
                        System.out.println("- 이름: " + part.getName());
                        System.out.println("- 크기: " + part.getSize() + " bytes");
                        System.out.println("- 제출된 파일명: " + part.getSubmittedFileName());
                        System.out.println("- Content-Type: " + part.getContentType());
                        System.out.println("- Headers: ");
                        for (String headerName : part.getHeaderNames()) {
                            System.out.println("  " + headerName + ": " + part.getHeader(headerName));
                        }
                    }
                    
                    // 첨부파일 디렉토리 설정 - 상대 경로로 지정하여 일관성 유지
                    String folderPath = "assignments/" + assignmentId;
                    
                    // 파일 업로드 및 정보 저장
                    List<Map<String, String>> uploadedFiles = FileUtil.uploadMultipleFiles(fileParts, folderPath);
                    
                    System.out.println("업로드된 파일 수: " + uploadedFiles.size());
                    
                    if (!uploadedFiles.isEmpty()) {
                        AttachmentDAO attachmentDAO = new AttachmentDAO();
                        
                        for (Map<String, String> fileInfo : uploadedFiles) {
                            // 디버깅 로그
                            System.out.println("첨부파일 정보: " + fileInfo);
                            
                            // 첨부파일 정보 데이터베이스에 저장
                            boolean success = attachmentDAO.addAttachment(
                                assignmentId,
                                fileInfo.get("originalFileName"),
                                fileInfo.get("savedFileName"),
                                fileInfo.get("filePath"),  // filePath는 이미 상대 경로로 저장됨
                                fileInfo.get("contentType")
                            );
                            
                            System.out.println("첨부파일 저장 " + (success ? "성공" : "실패") + ": " + fileInfo.get("originalFileName"));
                        }
                    } else {
                        System.out.println("업로드된 파일이 없습니다 - uploadMultipleFiles 결과가 비어있음");
                    }
                } else {
                    System.out.println("파일 파트가 없거나 비어 있습니다");
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