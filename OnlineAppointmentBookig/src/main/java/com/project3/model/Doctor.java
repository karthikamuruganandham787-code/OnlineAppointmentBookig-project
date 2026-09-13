package com.project3.model;

/**
 * Represents a doctor available for appointment booking.
 */
public class Doctor {

    private int id;
    private String name;
    private String specialty;
    private Integer specialtyId;
    private String qualification;
    private int experienceYears;
    private double rating;
    private String bio;
    private String profileImage;
    private String availabilityStatus;

    public Doctor() {
    }

    public Doctor(int id, String name, String specialty, String qualification,
                  int experienceYears, double rating, String bio,
                  String profileImage, String availabilityStatus) {
        this.id = id;
        this.name = name;
        this.specialty = specialty;
        this.qualification = qualification;
        this.experienceYears = experienceYears;
        this.rating = rating;
        this.bio = bio;
        this.profileImage = profileImage;
        this.availabilityStatus = availabilityStatus;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSpecialty() {
        return specialty;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public Integer getSpecialtyId() {
        return specialtyId;
    }

    public void setSpecialtyId(Integer specialtyId) {
        this.specialtyId = specialtyId;
    }

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    public String getAvailabilityStatus() {
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }
}
