package com.assignment.servlet;

import com.assignment.dao.AssignmentDAO;
import com.assignment.dao.CourseDAO;
import com.assignment.dao.NotificationDAO;
import com.assignment.model.Assignment;
import com.assignment.model.Course;
import com.assignment.util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/assignmentAdd")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB 제한
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
            Course course = courseDAO.getCourseById(courseId);

            if (course == null || course.getProfessorId() != professorId) {
                response.sendRedirect("assignment_management.jsp");
                return;
            }

            String fileName = null;
            String filePath = null;

            filePath = FileUtil.uploadFile(request, "file", "assignments");
            if (filePath != null) {
                fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
            }

            Assignment assignment = new Assignment();
            assignment.setCourseId(courseId);
            assignment.setTitle(title);
            assignment.setDescription(description);
            assignment.setDueDate(dueDate);
            assignment.setFileName(fileName);
            assignment.setFilePath(filePath);

            AssignmentDAO assignmentDAO = new AssignmentDAO();
            boolean result = assignmentDAO.addAssignment(assignment);

            if (result) {
                int assignmentId = assignmentDAO.getLastInsertedId();
                NotificationDAO notificationDAO = new NotificationDAO();
                notificationDAO.notifyNewAssignment(courseId, assignmentId, title);
                response.sendRedirect("assignment_management.jsp?courseId=" + courseId + "&success=add");
            } else {
                response.sendRedirect("assignment_form.jsp?error=1");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("assignment_form.jsp?error=invalid");
        }
    }
}