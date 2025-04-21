// src/com/assignment/servlet/SubmissionProcessServlet.java

package com.assignment.servlet;

import com.assignment.dao.SubmissionDAO;
import com.assignment.model.Submission;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/submissionProcess")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB 제한
public class SubmissionProcessServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String userType = (String) session.getAttribute("userType");
        if (userType == null || !userType.equals("student")) {
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("userId");
        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        String content = request.getParameter("content");

        // 파일 업로드
        String filePath = FileUtil.uploadFile(request, "file", "submissions");
        String fileName = filePath != null ? filePath.substring(filePath.lastIndexOf("/") + 1) : null;

        // DAO 처리
        SubmissionDAO submissionDAO = new SubmissionDAO();
        boolean isSubmitted = submissionDAO.submitOrUpdate(assignmentId, studentId, content, fileName, filePath);

        if (isSubmitted) {
            response.sendRedirect("assignment_list.jsp?courseId=" + request.getParameter("courseId") + "&success=submit");
        } else {
            response.sendRedirect("submission_form.jsp?id=" + assignmentId + "&error=1");
        }
    }
}
