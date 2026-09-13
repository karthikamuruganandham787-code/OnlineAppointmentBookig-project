package com.project3.controller;

import com.project3.dao.AppointmentDAO;
import com.project3.model.Appointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * GET /confirmation?id=NN -> renders confirmation.jsp with the booked appointment's details.
 */
@WebServlet("/confirmation")
public class ConfirmationServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseIntOrDefault(request.getParameter("id"), -1);

        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        Appointment appointment = appointmentDAO.getAppointmentById(id);

        if (appointment == null) {
            request.setAttribute("errorMessage", "We couldn't find that appointment.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        request.setAttribute("appointment", appointment);
        request.getRequestDispatcher("/confirmation.jsp").forward(request, response);
    }

    private int parseIntOrDefault(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
