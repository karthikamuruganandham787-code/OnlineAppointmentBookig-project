package com.project3.dao;

import com.project3.model.Appointment;
import com.project3.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data access layer for appointments.
 *
 * bookAppointment() is the critical, transaction-safe method that
 * guarantees a doctor can never be double-booked for the same
 * date + time, even under concurrent requests:
 *
 *   1. Start a transaction (autoCommit = false).
 *   2. Lock and re-check the target schedule slot (SELECT ... FOR UPDATE).
 *   3. If unavailable -> rollback and return a "slot taken" result.
 *   4. If available    -> insert the appointment row (protected further
 *                         by a UNIQUE(doctor_id, appointment_date, appointment_time)
 *                         constraint at the database level) and flip the
 *                         schedule slot to BOOKED.
 *   5. Commit. Any SQLException (including a unique-constraint violation
 *      from a race that slipped through) triggers a rollback.
 */
public class AppointmentDAO {

    public enum BookingResult {
        SUCCESS,
        SLOT_UNAVAILABLE,
        ERROR
    }

    public static class BookingOutcome {
        public final BookingResult result;
        public final int appointmentId;

        public BookingOutcome(BookingResult result, int appointmentId) {
            this.result = result;
            this.appointmentId = appointmentId;
        }
    }

    private final ScheduleDAO scheduleDAO = new ScheduleDAO();

    public BookingOutcome bookAppointment(Appointment appt) {
        String insertSql = "INSERT INTO appointments " +
                "(patient_name, email, phone, doctor_id, service_id, appointment_date, " +
                " appointment_time, reason, notes, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED')";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: lock + verify the slot is still available
            boolean available = scheduleDAO.isSlotAvailableForUpdate(
                    conn, appt.getDoctorId(), appt.getAppointmentDate(), appt.getAppointmentTime());

            if (!available) {
                conn.rollback();
                return new BookingOutcome(BookingResult.SLOT_UNAVAILABLE, -1);
            }

            // Step 2: insert the appointment
            int newId;
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, appt.getPatientName());
                ps.setString(2, appt.getEmail());
                ps.setString(3, appt.getPhone());
                ps.setInt(4, appt.getDoctorId());
                ps.setInt(5, appt.getServiceId());
                ps.setDate(6, Date.valueOf(appt.getAppointmentDate()));
                ps.setTime(7, Time.valueOf(appt.getAppointmentTime() + ":00"));
                ps.setString(8, appt.getReason());
                ps.setString(9, appt.getNotes());

                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        newId = keys.getInt(1);
                    } else {
                        throw new SQLException("Failed to retrieve generated appointment ID.");
                    }
                }
            }

            // Step 3: flip the schedule slot to BOOKED (same transaction)
            scheduleDAO.markSlotBooked(conn, appt.getDoctorId(), appt.getAppointmentDate(), appt.getAppointmentTime());

            conn.commit();
            return new BookingOutcome(BookingResult.SUCCESS, newId);

        } catch (SQLIntegrityConstraintViolationException dup) {
            // Backstop: the UNIQUE(doctor_id, appointment_date, appointment_time)
            // constraint caught a race condition that slipped past the row lock.
            rollbackQuietly(conn);
            return new BookingOutcome(BookingResult.SLOT_UNAVAILABLE, -1);
        } catch (SQLException e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return new BookingOutcome(BookingResult.ERROR, -1);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    public Appointment getAppointmentById(int appointmentId) {
        String sql = "SELECT a.*, d.name AS doctor_name, d.specialty AS specialty, " +
                     "s.service_name AS service_name, s.fee AS fee, s.duration_mins AS duration_mins " +
                     "FROM appointments a " +
                     "JOIN doctors d ON a.doctor_id = d.id " +
                     "JOIN services s ON a.service_id = s.id " +
                     "WHERE a.appointment_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowWithJoin(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Appointment> getAppointmentsByEmail(String email) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, d.name AS doctor_name, d.specialty AS specialty, " +
                     "s.service_name AS service_name, s.fee AS fee, s.duration_mins AS duration_mins " +
                     "FROM appointments a " +
                     "JOIN doctors d ON a.doctor_id = d.id " +
                     "JOIN services s ON a.service_id = s.id " +
                     "WHERE a.email = ? ORDER BY a.appointment_date DESC, a.appointment_time DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowWithJoin(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private Appointment mapRowWithJoin(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setAppointmentId(rs.getInt("appointment_id"));
        a.setPatientName(rs.getString("patient_name"));
        a.setEmail(rs.getString("email"));
        a.setPhone(rs.getString("phone"));
        a.setDoctorId(rs.getInt("doctor_id"));
        a.setServiceId(rs.getInt("service_id"));
        a.setAppointmentDate(rs.getDate("appointment_date").toString());
        a.setAppointmentTime(rs.getTime("appointment_time").toString().substring(0, 5));
        a.setReason(rs.getString("reason"));
        a.setNotes(rs.getString("notes"));
        a.setStatus(rs.getString("status"));
        a.setCreatedAt(String.valueOf(rs.getTimestamp("created_at")));
        a.setDoctorName(rs.getString("doctor_name"));
        a.setSpecialty(rs.getString("specialty"));
        a.setServiceName(rs.getString("service_name"));
        a.setFee(rs.getDouble("fee"));
        a.setDurationMins(rs.getInt("duration_mins"));
        return a;
    }
}
