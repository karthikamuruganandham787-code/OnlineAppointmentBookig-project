package com.project3.model;

/**
 * Represents the mapping between a doctor and a service they provide.
 */
public class DoctorService {

    private int id;
    private int doctorId;
    private int serviceId;

    public DoctorService() {
    }

    public DoctorService(int id, int doctorId, int serviceId) {
        this.id = id;
        this.doctorId = doctorId;
        this.serviceId = serviceId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }
}
