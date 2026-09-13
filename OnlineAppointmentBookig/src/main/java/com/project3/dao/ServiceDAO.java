package com.project3.dao;

import com.project3.model.Service;
import com.project3.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data access layer for the services table.
 */
public class ServiceDAO {

    public List<Service> getAllServices() {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM services WHERE status = 'ACTIVE' ORDER BY service_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                services.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
    }

    public Service getServiceById(int id) {
        String sql = "SELECT * FROM services WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Returns the services offered by a specific doctor.
     */
    public List<Service> getServicesByDoctor(int doctorId) {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT s.* FROM services s " +
                     "JOIN doctor_services ds ON s.id = ds.service_id " +
                     "WHERE ds.doctor_id = ? AND s.status = 'ACTIVE' ORDER BY s.service_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
    }

    private Service mapRow(ResultSet rs) throws SQLException {
        Service s = new Service();
        s.setId(rs.getInt("id"));
        s.setServiceName(rs.getString("service_name"));
        s.setDescription(rs.getString("description"));
        s.setDurationMins(rs.getInt("duration_mins"));
        s.setFee(rs.getDouble("fee"));
        s.setIcon(rs.getString("icon"));
        s.setStatus(rs.getString("status"));
        return s;
    }
}
