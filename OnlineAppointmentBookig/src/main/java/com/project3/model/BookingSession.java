package com.project3.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Server-side booking wizard state stored in the HTTP session.
 * Step 1 = service, 2 = doctor, 3 = date/time, 4 = patient, 5 = review.
 */
public class BookingSession implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String SESSION_KEY = "booking";

    private int currentStep = 1;
    private Integer selectedServiceId;
    private Service selectedService;
    private Integer selectedDoctorId;
    private Doctor selectedDoctor;
    private String selectedDate;
    private String selectedTime;
    private String selectedSlotEnd;
    private String patientName;
    private String email;
    private String phone;
    private String reason;
    private String notes;
    private transient List<Doctor> matchingDoctors = new ArrayList<Doctor>();
    private transient List<TimeSlot> slots = new ArrayList<TimeSlot>();
    private transient List<String> availableDates = new ArrayList<String>();

    public int getCurrentStep() {
        return currentStep;
    }

    public void setCurrentStep(int currentStep) {
        this.currentStep = currentStep;
    }

    public Integer getSelectedServiceId() {
        return selectedServiceId;
    }

    public void setSelectedServiceId(Integer selectedServiceId) {
        this.selectedServiceId = selectedServiceId;
    }

    public Service getSelectedService() {
        return selectedService;
    }

    public void setSelectedService(Service selectedService) {
        this.selectedService = selectedService;
        this.selectedServiceId = selectedService == null ? null : Integer.valueOf(selectedService.getId());
    }

    public Integer getSelectedDoctorId() {
        return selectedDoctorId;
    }

    public void setSelectedDoctorId(Integer selectedDoctorId) {
        this.selectedDoctorId = selectedDoctorId;
    }

    public Doctor getSelectedDoctor() {
        return selectedDoctor;
    }

    public void setSelectedDoctor(Doctor selectedDoctor) {
        this.selectedDoctor = selectedDoctor;
        this.selectedDoctorId = selectedDoctor == null ? null : Integer.valueOf(selectedDoctor.getId());
    }

    public String getSelectedDate() {
        return selectedDate;
    }

    public void setSelectedDate(String selectedDate) {
        this.selectedDate = selectedDate;
    }

    public String getSelectedTime() {
        return selectedTime;
    }

    public void setSelectedTime(String selectedTime) {
        this.selectedTime = selectedTime;
    }

    public String getSelectedSlotEnd() {
        return selectedSlotEnd;
    }

    public void setSelectedSlotEnd(String selectedSlotEnd) {
        this.selectedSlotEnd = selectedSlotEnd;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public List<Doctor> getMatchingDoctors() {
        if (matchingDoctors == null) {
            matchingDoctors = new ArrayList<Doctor>();
        }
        return matchingDoctors;
    }

    public void setMatchingDoctors(List<Doctor> matchingDoctors) {
        this.matchingDoctors = matchingDoctors;
    }

    public List<TimeSlot> getSlots() {
        if (slots == null) {
            slots = new ArrayList<TimeSlot>();
        }
        return slots;
    }

    public void setSlots(List<TimeSlot> slots) {
        this.slots = slots;
    }

    public List<String> getAvailableDates() {
        if (availableDates == null) {
            availableDates = new ArrayList<String>();
        }
        return availableDates;
    }

    public void setAvailableDates(List<String> availableDates) {
        this.availableDates = availableDates;
    }

    public void clearDoctorAndLater() {
        selectedDoctor = null;
        selectedDoctorId = null;
        clearDateAndLater();
    }

    public void clearDateAndLater() {
        selectedDate = null;
        selectedTime = null;
        selectedSlotEnd = null;
        clearPatientAndLater();
    }

    public void clearPatientAndLater() {
        patientName = null;
        email = null;
        phone = null;
        reason = null;
        notes = null;
    }
}
