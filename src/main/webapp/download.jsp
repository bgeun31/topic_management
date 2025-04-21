<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="java.util.Map" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String type = request.getParameter("type");
    int id = Integer.parseInt(request.getParameter("id"));

    String fileName = null;
    String filePath = null;

    if ("assignment".equals(type)) {
        AssignmentDAO assignmentDAO = new AssignmentDAO();
        Assignment assignment = assignmentDAO.getAssignmentById(id);
        if (assignment != null) {
            fileName = assignment.getFileName();
            filePath = assignment.getFilePath();
        }
    } else if ("submission".equals(type)) {
        SubmissionDAO submissionDAO = new SubmissionDAO();
        Submission submission = submissionDAO.getSubmissionById(id);
        if (submission != null) {
            boolean hasPermission = userType.equals("professor") || 
                                   (userType.equals("student") && submission.getStudentId() == (Integer) session.getAttribute("userId"));
            if (hasPermission) {
                fileName = submission.getFileName();
                filePath = submission.getFilePath();
            } else {
                response.sendRedirect("index.jsp");
                return;
            }
        }
    } else if ("attachment".equals(type)) {
        // 첨부파일 정보 가져오기
        AttachmentDAO attachmentDAO = new AttachmentDAO();
        Map<String, Object> attachment = attachmentDAO.getAttachmentAsMap(id);
        
        if (attachment != null) {
            // 과제 ID로 권한 확인
            int assignmentId = (Integer) attachment.get("assignmentId");
            AssignmentDAO assignmentDAO = new AssignmentDAO();
            Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
            
            if (assignment != null) {
                // 교수이거나 해당 과제가 속한 과목을 수강 중인 학생인지 확인
                boolean hasPermission = false;
                
                if (userType.equals("professor")) {
                    // 교수인 경우 해당 과제를 등록한 교수인지 확인
                    CourseDAO courseDAO = new CourseDAO();
                    Course course = courseDAO.getCourseById(assignment.getCourseId());
                    hasPermission = (course != null && course.getProfessorId() == (Integer) session.getAttribute("userId"));
                } else if (userType.equals("student")) {
                    // 학생인 경우 해당 과제가 속한 과목을 수강 중인지 확인
                    int studentId = (Integer) session.getAttribute("userId");
                    EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
                    hasPermission = enrollmentDAO.isEnrolled(studentId, assignment.getCourseId());
                }
                
                if (hasPermission) {
                    fileName = (String) attachment.get("originalFileName");
                    filePath = (String) attachment.get("filePath");
                } else {
                    response.sendRedirect("index.jsp?error=permission");
                    return;
                }
            }
        }
    }

    if (fileName != null && filePath != null) {
        String applicationPath = request.getServletContext().getRealPath("");
        String downloadPath = applicationPath + File.separator + filePath;

        File file = new File(downloadPath);

        if (file.exists()) {
            response.setContentType("application/octet-stream");

            // 파일 이름 인코딩 처리 (브라우저 호환용)
            String userAgent = request.getHeader("User-Agent");
            String encodedFileName = fileName;
            if (userAgent != null && userAgent.contains("MSIE")) {
                encodedFileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
            } else if (userAgent != null && userAgent.contains("Trident")) {  // IE 11
                encodedFileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
            } else if (userAgent != null && userAgent.contains("Edge")) {
                encodedFileName = URLEncoder.encode(fileName, "UTF-8");
            } else {
                encodedFileName = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
            }

            response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedFileName + "\"");

            FileInputStream fileInputStream = new FileInputStream(file);
            OutputStream outputStream = response.getOutputStream();

            byte[] buffer = new byte[4096];
            int bytesRead = -1;

            while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }

            fileInputStream.close();
            outputStream.close();
        } else {
            response.sendRedirect("index.jsp?error=file");
        }
    } else {
        response.sendRedirect("index.jsp?error=file");
    }
%>
