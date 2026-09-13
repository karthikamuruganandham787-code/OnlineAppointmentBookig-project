package com.project3.controller;

import com.google.gson.Gson;
import com.project3.dao.AppointmentDAO;
import com.project3.dao.AppointmentDAO.BookingOutcome;
import com.project3.dao.AppointmentDAO.BookingResult;
import com.project3.dao.DoctorDAO;
import com.project3.dao.ScheduleDAO;
import com.project3.dao.ServiceDAO;
import com.project3.model.Appointment;
import com.project3.model.TimeSlot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Central controller for the multi-step booking journey
 * (Doctor -> Service -> Date -> Time -> Patient Details -> Review -> Confirm).
 *
 * GET  /booking                                             -> renders the booking page (book.jsp)
 * GET  /booking?action=dates&doctorId=NN&format=json         -> JSON: available dates for a doctor
 * GET  /booking?action=slots&doctorId=NN&date=YYYY-MM-DD&format=json -> JSON: time slots for that date
 * POST /booking                                              -> validates + persists the appointment
 */
@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final Gson gson = new Gson();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[\\w.+-]+@[\\w-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[0-9]{10}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String format = request.getParameter("format");

        if ("json".equalsIgnoreCase(format)) {
            handleJson(request, response, action);
            return;
        }

        request.setAttribute("doctors", doctorDAO.getAllDoctors());
        request.setAttribute("services", serviceDAO.getAllServices());
        request.getRequestDispatcher("/book.jsp").forward(request, response);
    }

    private void handleJson(HttpServletRequest request, HttpServletResponse response, String action)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            int doctorId = parseIntOrDefault(request.getParameter("doctorId"), -1);

            if ("dates".equalsIgnoreCase(action)) {
                List<String> dates = scheduleDAO.getAvailableDatesForDoctor(doctorId);
                out.print(gson.toJson(dates));

            } else if ("slots".equalsIgnoreCase(action)) {
                String date = request.getParameter("date");
                List<TimeSlot> slots = scheduleDAO.getSlotsForDoctorAndDate(doctorId, date);
                out.print(gson.toJson(slots));

            } else {
                out.print("[]");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();

        // ---- Gather & sanitize input ----
        String patientName = trim(request.getParameter("patientName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String reason = trim(request.getParameter("reason"));
        String notes = trim(request.getParameter("notes"));
        String doctorIdStr = request.getParameter("doctorId");
        String serviceIdStr = request.getParameter("serviceId");
        String date = trim(request.getParameter("date"));
        String time = trim(request.getParameter("time"));

        // ---- Server-side validation (never rely on JS alone) ----
        Map<String, String> errors = new HashMap<>();

        int doctorId = parseIntOrDefault(doctorIdStr, -1);
        int serviceId = parseIntOrDefault(serviceIdStr, -1);

        if (patientName == null || patientName.length() < 2) {
            errors.put("patientName", "Please enter your full name.");
        }
        if (email == null || !EMAIL_PATTERN.matcher(email).matches()) {
            errors.put("email", "Please enter a valid email address.");
        }
        if (phone == null || !PHONE_PATTERN.matcher(phone).matches()) {
            errors.put("phone", "Please enter a valid 10-digit phone number.");
        }
        if (doctorId <= 0 || doctorDAO.getDoctorById(doctorId) == null) {
            errors.put("doctor", "Please select a valid doctor.");
        }
        if (serviceId <= 0 || serviceDAO.getServiceById(serviceId) == null) {
            errors.put("service", "Please select a valid service.");
        } else if (doctorId > 0 && errors.get("doctor") == null) {
            // Validate that this doctor actually offers the selected service
            boolean serviceOffered = serviceDAO.getServicesByDoctor(doctorId)
                    .stream().anyMatch(s -> s.getId() == serviceId);
            if (!serviceOffered) {
                errors.put("service", "The selected service is not offered by this doctor.");
            }
        }
        if (date == null || date.isEmpty()) {
            errors.put("date", "Please select a date.");
        } else {
            try {
                LocalDate parsed = LocalDate.parse(date);
                if (parsed.isBefore(LocalDate.now())) {
                    errors.put("date", "Please select a valid future date.");
                }
            } catch (Exception e) {
                errors.put("date", "Invalid date format.");
            }
        }
        if (time == null || time.isEmpty()) {
            errors.put("time", "Please select a time slot.");
        }

        if (!errors.isEmpty()) {
            result.put("success", false);
            result.put("errors", errors);
            response.getWriter().print(gson.toJson(result));
            return;
        }

        // ---- Build appointment & attempt transaction-safe booking ----
        Appointment appt = new Appointment();
        appt.setPatientName(patientName);
        appt.setEmail(email);
        appt.setPhone(phone);
        appt.setDoctorId(doctorId);
        appt.setServiceId(serviceId);
        appt.setAppointmentDate(date);
        appt.setAppointmentTime(time);
        appt.setReason(reason);
        appt.setNotes(notes);

        BookingOutcome outcome = appointmentDAO.bookAppointment(appt);

        if (outcome.result == BookingResult.SUCCESS) {
            result.put("success", true);
            result.put("appointmentId", outcome.appointmentId);
        } else if (outcome.result == BookingResult.SLOT_UNAVAILABLE) {
            result.put("success", false);
            result.put("message", "This time slot is no longer available. Please select another time.");
            result.put("slotTaken", true);
        } else {
            result.put("success", false);
            result.put("message", "We couldn't complete your booking right now. Please try again.");
        }

        response.getWriter().print(gson.toJson(result));
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private int parseIntOrDefault(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
