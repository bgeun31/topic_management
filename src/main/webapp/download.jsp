<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.assignment.dao.*" %>
<%@ page import="com.assignment.model.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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
            System.out.println("과제 파일 다운로드: ID=" + id + ", 파일명=" + fileName + ", 경로=" + filePath);
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
                System.out.println("제출 파일 다운로드: ID=" + id + ", 파일명=" + fileName + ", 경로=" + filePath);
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
            // 모든 첨부파일 정보 출력 (디버깅용)
            System.out.println("첨부파일 상세 정보:");
            for (Map.Entry<String, Object> entry : attachment.entrySet()) {
                System.out.println(entry.getKey() + " = " + entry.getValue());
            }
            
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
                    
                    // 먼저 filePath 필드 확인
                    filePath = (String) attachment.get("filePath");
                    
                    if (filePath == null || filePath.isEmpty()) {
                        System.out.println("경로가 null입니다. savedFileName 필드를 사용해 경로를 구성합니다.");
                        String savedFileName = (String) attachment.get("savedFileName");
                        if (savedFileName != null && !savedFileName.isEmpty()) {
                            filePath = "uploads/assignments/" + savedFileName;
                            System.out.println("구성된 경로: " + filePath);
                        } else {
                            System.out.println("savedFileName도 null입니다. 첨부파일을 찾을 수 없습니다.");
                            response.sendRedirect("index.jsp?error=path");
                            return;
                        }
                    }
                    
                    // 디버깅용 로그
                    System.out.println("첨부파일 다운로드: ID=" + id + ", 파일명=" + fileName + ", 경로=" + filePath);
                } else {
                    response.sendRedirect("index.jsp?error=permission");
                    return;
                }
            }
        }
    }

    if (fileName == null || fileName.trim().isEmpty()) {
        System.out.println("파일명이 null입니다.");
        response.sendRedirect("index.jsp?error=filename");
        return;
    }

    // 경로 정규화
    if (filePath != null) {
        filePath = filePath.replace('\\', '/');
        if (!filePath.startsWith("uploads/") && !filePath.startsWith("/uploads/")) {
            filePath = "uploads/" + filePath;
        }
    }

    File file = null;
    String applicationPath = request.getServletContext().getRealPath("/");
    String userHome = System.getProperty("user.home");
    String tempDir = System.getProperty("java.io.tmpdir");
    
    // 디버깅을 위한 경로 정보 출력
    System.out.println("Application Path: " + applicationPath);
    System.out.println("User Home: " + userHome);
    System.out.println("Temp Dir: " + tempDir);
    System.out.println("File Path from DB: " + filePath);
    
    // 파일 찾기를 위한 모든 가능한 경로
    List<String> pathsToTry = new ArrayList<>();
    
    // 1. 애플리케이션 경로 + 파일 경로
    pathsToTry.add(applicationPath + filePath);
    
    // 2. 사용자 홈 디렉토리 + 파일 경로
    pathsToTry.add(userHome + File.separator + filePath);
    
    // 3. 임시 디렉토리 + 파일 경로
    pathsToTry.add(tempDir + File.separator + filePath);
    
    // 4. 파일명만으로 시도 (웹앱 디렉토리 내)
    String fileName2 = new File(filePath).getName();
    pathsToTry.add(applicationPath + "uploads" + File.separator + type + "s" + File.separator + fileName2);
    
    // 경로 정규화 (OS에 맞게)
    for (int i = 0; i < pathsToTry.size(); i++) {
        String path = pathsToTry.get(i);
        pathsToTry.set(i, path.replace('/', File.separatorChar));
    }
    
    System.out.println("=== 시도할 경로 목록 ===");
    for (String path : pathsToTry) {
        System.out.println(path);
    }
    
    // 각 경로에서 파일 찾기
    for (String path : pathsToTry) {
        file = new File(path);
        if (file.exists() && file.isFile()) {
            System.out.println("파일을 찾았습니다: " + path);
            break;
        }
    }

    if (file == null || !file.exists() || !file.isFile()) {
        System.out.println("모든 경로에서 파일을 찾을 수 없습니다.");
        response.sendRedirect("index.jsp?error=filenotfound");
        return;
    }

    // 파일 다운로드 처리
    try {
        // 파일 컨텐츠 타입 설정
        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);

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

        try (FileInputStream fileInputStream = new FileInputStream(file);
             OutputStream outputStream = response.getOutputStream()) {
            
            byte[] buffer = new byte[8192]; // 버퍼 크기 
            int bytesRead = -1;

            while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            
            // 디버깅용 로그
            System.out.println("파일 다운로드 완료: " + fileName);
        } catch (Exception e) {
            System.out.println("파일 다운로드 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            %>
            <script>
                alert("파일 다운로드 중 오류가 발생했습니다: <%= e.getMessage() %>");
                history.back();
            </script>
            <%
        }
    } catch (Exception e) {
        %>
        <script>
            alert("파일 정보가 올바르지 않습니다. 관리자에게 문의하세요.");
            history.back();
        </script>
        <%
    }
%>
