package com.project3.controller;

import com.google.gson.Gson;
import com.project3.dao.DoctorDAO;
import com.project3.dao.ServiceDAO;
import com.project3.model.Doctor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Handles doctor discovery:
 *  - GET /doctors                -> renders doctors.jsp with full/searched list
 *  - GET /doctors?action=search  -> renders doctors.jsp filtered by keyword
 *  - GET /doctors?action=byService&serviceId=NN&format=json -> JSON list for AJAX (booking flow)
 *  - GET /doctors?action=detail&id=NN&format=json -> JSON single doctor (for booking summary)
 */
@WebServlet("/doctors")
public class DoctorServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String format = request.getParameter("format");

        if ("json".equalsIgnoreCase(format)) {
            handleJson(request, response, action);
            return;
        }

        List<Doctor> doctors;
        String keyword = request.getParameter("q");

        if ("search".equalsIgnoreCase(action) && keyword != null && !keyword.trim().isEmpty()) {
            doctors = doctorDAO.searchDoctors(keyword.trim());
            request.setAttribute("searchKeyword", keyword.trim());
        } else {
            doctors = doctorDAO.getAllDoctors();
        }

        request.setAttribute("doctors", doctors);
        request.getRequestDispatcher("/doctors.jsp").forward(request, response);
    }

    private void handleJson(HttpServletRequest request, HttpServletResponse response, String action)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            if ("byService".equalsIgnoreCase(action)) {
                int serviceId = parseIntOrDefault(request.getParameter("serviceId"), -1);
                List<Doctor> doctors = serviceId > 0
                        ? doctorDAO.getDoctorsByService(serviceId)
                        : doctorDAO.getAllDoctors();
                out.print(gson.toJson(doctors));

            } else if ("detail".equalsIgnoreCase(action)) {
                int id = parseIntOrDefault(request.getParameter("id"), -1);
                Doctor doctor = doctorDAO.getDoctorById(id);
                out.print(gson.toJson(doctor));

            } else {
                out.print(gson.toJson(doctorDAO.getAllDoctors()));
            }
        }
    }

    private int parseIntOrDefault(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
