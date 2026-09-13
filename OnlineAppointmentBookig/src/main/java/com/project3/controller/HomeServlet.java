package com.project3.controller;

import com.project3.dao.DoctorDAO;
import com.project3.dao.ServiceDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Handles the landing page: shows featured doctors and available services.
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<?> featuredDoctors = doctorDAO.getAllDoctors();
        List<?> services = serviceDAO.getAllServices();

        request.setAttribute("featuredDoctors", featuredDoctors);
        request.setAttribute("services", services);

        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
}
