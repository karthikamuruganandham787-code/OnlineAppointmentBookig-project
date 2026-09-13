package com.project3.dao;

import com.project3.model.TimeSlot;
import com.project3.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data access layer for doctor_schedule (time-slot availability).
 *
 * This DAO is central to double-booking prevention: slot status is
 * read and updated using transaction-safe, locking reads so that two
 * concurrent booking attempts for the same doctor/date/time cannot
 * both succeed.
 */
public class ScheduleDAO {

    /**
     * Returns all schedule slots for a doctor on a given date, ordered by time.
     */
    public List<TimeSlot> getSlotsForDoctorAndDate(int doctorId, String date) {
        List<TimeSlot> slots = new ArrayList<>();
        String sql = "SELECT * FROM doctor_schedule WHERE doctor_id = ? AND schedule_date = ? ORDER BY slot_time ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    slots.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return slots;
    }

    /**
     * Returns the distinct dates (within the schedule horizon) for which a doctor
     * has at least one AVAILABLE slot. Used to drive the calendar's "available date" state.
     */
    public List<String> getAvailableDatesForDoctor(int doctorId) {
        List<String> dates = new ArrayList<>();
        String sql = "SELECT DISTINCT schedule_date FROM doctor_schedule " +
                     "WHERE doctor_id = ? AND status = 'AVAILABLE' AND schedule_date >= CURDATE() " +
                     "ORDER BY schedule_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dates.add(rs.getDate("schedule_date").toString());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dates;
    }

    /**
     * Checks (within an active transaction/connection) whether a specific
     * doctor/date/time slot is currently AVAILABLE. Uses SELECT ... FOR UPDATE
     * to lock the row and prevent a race condition with a concurrent booking.
     *
     * Must be called with a connection that has autoCommit(false) already set
     * by the caller (see AppointmentDAO.bookAppointment).
     */
    public boolean isSlotAvailableForUpdate(Connection conn, int doctorId, String date, String time) throws SQLException {
        String sql = "SELECT status FROM doctor_schedule " +
                     "WHERE doctor_id = ? AND schedule_date = ? AND slot_time = ? FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            ps.setTime(3, Time.valueOf(time + ":00"));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "AVAILABLE".equalsIgnoreCase(rs.getString("status"));
                }
            }
        }
        // If no explicit schedule row exists, treat as not available (must be pre-generated).
        return false;
    }

    /**
     * Marks a slot as BOOKED. Must be executed on the same connection/transaction
     * as the availability check and the appointment insert.
     */
    public void markSlotBooked(Connection conn, int doctorId, String date, String time) throws SQLException {
        String sql = "UPDATE doctor_schedule SET status = 'BOOKED' " +
                     "WHERE doctor_id = ? AND schedule_date = ? AND slot_time = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            ps.setTime(3, Time.valueOf(time + ":00"));
            ps.executeUpdate();
        }
    }

    /**
     * Releases a previously booked slot back to AVAILABLE (e.g. on cancellation).
     */
    public void releaseSlot(int doctorId, String date, String time) {
        String sql = "UPDATE doctor_schedule SET status = 'AVAILABLE' " +
                     "WHERE doctor_id = ? AND schedule_date = ? AND slot_time = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            ps.setTime(3, Time.valueOf(time + ":00"));
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private TimeSlot mapRow(ResultSet rs) throws SQLException {
        TimeSlot t = new TimeSlot();
        t.setId(rs.getInt("id"));
        t.setDoctorId(rs.getInt("doctor_id"));
        t.setScheduleDate(rs.getDate("schedule_date").toString());
        t.setSlotTime(rs.getTime("slot_time").toString().substring(0, 5));
        t.setSlotEndTime(rs.getTime("slot_end_time").toString().substring(0, 5));
        t.setStatus(rs.getString("status"));
        return t;
    }
}
