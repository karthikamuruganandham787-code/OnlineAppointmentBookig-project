package com.project3.model;

/**
 * Represents a bookable medical service (e.g. General Consultation, Dental Care).
 */
public class Service {

    private int id;
    private String serviceName;
    private String description;
    private int durationMins;
    private double fee;
    private String icon;
    private String status;

    public Service() {
    }

    public Service(int id, String serviceName, String description, int durationMins,
                   double fee, String icon, String status) {
        this.id = id;
        this.serviceName = serviceName;
        this.description = description;
        this.durationMins = durationMins;
        this.fee = fee;
        this.icon = icon;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDurationMins() {
        return durationMins;
    }

    public void setDurationMins(int durationMins) {
        this.durationMins = durationMins;
    }

    public double getFee() {
        return fee;
    }

    public void setFee(double fee) {
        this.fee = fee;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
