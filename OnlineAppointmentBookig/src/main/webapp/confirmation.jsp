<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Confirmed - MediBook</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="confirmation" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="section">
    <div class="container confirmation-wrap">
        <div class="success-check">
            <svg width="46" height="46" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
            </svg>
        </div>
        <h1>Appointment Confirmed!</h1>
        <p>A confirmation has been recorded for your visit. Please arrive 10 minutes early.</p>

        <span class="appointment-id-badge">Appointment ID: #${appointment.appointmentId}</span>

        <div class="review-box" style="text-align:left;">
            <div class="review-header">Appointment Details</div>
            <div class="review-body">
                <div class="review-item"><span class="label">Doctor</span><span class="value">${appointment.doctorName}</span></div>
                <div class="review-item"><span class="label">Specialty</span><span class="value">${appointment.specialty}</span></div>
                <div class="review-item"><span class="label">Service</span><span class="value">${appointment.serviceName}</span></div>
                <div class="review-item"><span class="label">Date</span><span class="value">${appointment.appointmentDate}</span></div>
                <div class="review-item"><span class="label">Time</span><span class="value">${appointment.appointmentTime}</span></div>
                <div class="review-item"><span class="label">Patient</span><span class="value">${appointment.patientName}</span></div>
                <div class="review-item"><span class="label">Contact</span><span class="value">${appointment.phone}</span></div>
                <div class="review-item"><span class="label">Status</span><span class="value" style="color:var(--success);">${appointment.status}</span></div>
            </div>
        </div>

        <div class="confirmation-actions">
            <c:url var="myApptsUrl" value="/appointment">
                <c:param name="email" value="${appointment.email}"/>
            </c:url>
            <a href="${myApptsUrl}" class="btn btn-secondary">View Appointment</a>
            <a href="${pageContext.request.contextPath}/booking" class="btn btn-primary">Book Another Appointment</a>
            <a href="${pageContext.request.contextPath}/" class="btn btn-ghost">Back to Home</a>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
