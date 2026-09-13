package com.project3.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Centralized JDBC connection provider for MediBook.
 *
 * Database : onlineappointmentbooking
 * Host     : localhost
 * Port     : 3308  (MariaDB - NOT the default MySQL port 3306)
 * Driver   : org.mariadb.jdbc.Driver
 */
public final class DBConnection {

    private static final String DRIVER = "org.mariadb.jdbc.Driver";
    private static final String URL = "jdbc:mariadb://localhost:3308/onlineappointmentbooking";
    private static final String USER = "root";
    private static final String PASSWORD = "admin";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MariaDB JDBC Driver not found on classpath.", e);
        }
    }

    private DBConnection() {
        // utility class - prevent instantiation
    }

    /**
     * Opens a new connection to the onlineappointmentbooking MariaDB database.
     * Caller is responsible for closing the connection (try-with-resources recommended).
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
