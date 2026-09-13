package com.project3.model;

/**
 * Represents a single bookable time slot for a doctor on a given date.
 * Status is one of: AVAILABLE, BOOKED, BLOCKED.
 */
public class TimeSlot {

    private int id;
    private int doctorId;
    private String scheduleDate; // yyyy-MM-dd
    private String slotTime;     // HH:mm
    private String slotEndTime;  // HH:mm
    private String status;
    private String displayLabel;

    public TimeSlot() {
    }

    public TimeSlot(int id, int doctorId, String scheduleDate, String slotTime,
                     String slotEndTime, String status) {
        this.id = id;
        this.doctorId = doctorId;
        this.scheduleDate = scheduleDate;
        this.slotTime = slotTime;
        this.slotEndTime = slotEndTime;
        this.status = status;
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

    public String getScheduleDate() {
        return scheduleDate;
    }

    public void setScheduleDate(String scheduleDate) {
        this.scheduleDate = scheduleDate;
    }

    public String getSlotTime() {
        return slotTime;
    }

    public void setSlotTime(String slotTime) {
        this.slotTime = slotTime;
    }

    public String getSlotEndTime() {
        return slotEndTime;
    }

    public void setSlotEndTime(String slotEndTime) {
        this.slotEndTime = slotEndTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDisplayLabel() {
        return displayLabel;
    }

    public void setDisplayLabel(String displayLabel) {
        this.displayLabel = displayLabel;
    }
}
