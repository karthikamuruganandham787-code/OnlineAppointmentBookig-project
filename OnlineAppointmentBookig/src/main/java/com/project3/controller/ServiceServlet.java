package com.project3.controller;

import com.google.gson.Gson;
import com.project3.dao.ServiceDAO;
import com.project3.model.Service;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Handles service selection:
 *  - GET /services                          -> renders services.jsp
 *  - GET /services?format=json              -> JSON list of all active services
 *  - GET /services?action=byDoctor&doctorId=NN&format=json -> services offered by a doctor
 */
@WebServlet("/services")
public class ServiceServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String format = request.getParameter("format");
        String action = request.getParameter("action");

        if ("json".equalsIgnoreCase(format)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try (PrintWriter out = response.getWriter()) {
                List<Service> services;
                if ("byDoctor".equalsIgnoreCase(action)) {
                    int doctorId = parseIntOrDefault(request.getParameter("doctorId"), -1);
                    services = doctorId > 0
                            ? serviceDAO.getServicesByDoctor(doctorId)
                            : serviceDAO.getAllServices();
                } else {
                    services = serviceDAO.getAllServices();
                }
                out.print(gson.toJson(services));
            }
            return;
        }

        request.setAttribute("services", serviceDAO.getAllServices());
        request.getRequestDispatcher("/services.jsp").forward(request, response);
    }

    private int parseIntOrDefault(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
