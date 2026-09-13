package com.project3.controller;

import com.project3.dao.AppointmentDAO;
import com.project3.model.Appointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * GET /appointment                 -> renders the "My Appointments" lookup page
 * GET /appointment?email=...       -> renders the page with matching appointments listed
 */
@WebServlet("/appointment")
public class AppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        if (email != null && !email.trim().isEmpty()) {
            List<Appointment> appointments = appointmentDAO.getAppointmentsByEmail(email.trim());
            request.setAttribute("appointments", appointments);
            request.setAttribute("searchedEmail", email.trim());
        }

        request.getRequestDispatcher("/my-appointments.jsp").forward(request, response);
    }
}
