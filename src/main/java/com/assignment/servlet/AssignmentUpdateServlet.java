package com.assignment.servlet;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.model.Assignment;
import com.assignment.model.Course;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/assignmentUpdate")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
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

        // 파일 업로드 처리
        String fileName = assignment.getFileName();
        String filePath = assignment.getFilePath();

        String newPath = FileUtil.uploadFile(request, "file", "assignments");
        if (newPath != null) {
            filePath = newPath;
            fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
        }

        assignment.setTitle(title);
        assignment.setDescription(description);
        assignment.setDueDate(dueDate);
        assignment.setFileName(fileName);
        assignment.setFilePath(filePath);

        boolean updated = assignmentDAO.updateAssignment(assignment);

        if (updated) {
            response.sendRedirect("assignment_management.jsp?courseId=" + courseId + "&success=update");
        } else {
            response.sendRedirect("assignment_form.jsp?id=" + assignmentId + "&error=1");
        }
    }
}
