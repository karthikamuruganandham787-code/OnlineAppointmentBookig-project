<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Appointments - MediBook</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="myAppointments" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="section">
    <div class="container" style="max-width: 760px;">
        <div class="section-header">
            <span class="eyebrow">My Appointments</span>
            <h2 class="section-title">Check Your Appointment Status</h2>
            <p class="section-subtitle">Enter the email you used while booking to view your appointments.</p>
        </div>

        <form action="${pageContext.request.contextPath}/appointment" method="get">
            <div class="search-bar">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 6L2 7"/></svg>
                <input type="email" name="email" placeholder="you@example.com" value="${searchedEmail}" required>
                <button type="submit" class="btn btn-primary btn-sm">Search</button>
            </div>
        </form>

        <c:if test="${not empty searchedEmail}">
            <c:choose>
                <c:when test="${empty appointments}">
                    <div class="empty-state">
                        <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                        <h3>No appointments found</h3>
                        <p>We couldn't find any appointments for this email address.</p>
                        <a href="${pageContext.request.contextPath}/booking" class="btn btn-secondary btn-sm">Book an Appointment</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="appt" items="${appointments}">
                        <div class="review-box mt-4">
                            <div class="review-header" style="display:flex; justify-content:space-between; align-items:center;">
                                <span>Appointment #${appt.appointmentId}</span>
                                <span style="font-size:12.5px; padding: 4px 10px; border-radius: var(--radius-full);
                                    background: ${appt.status == 'CONFIRMED' ? 'var(--success-light)' : appt.status == 'CANCELLED' ? 'var(--danger-light)' : 'var(--warning-light)'};
                                    color: ${appt.status == 'CONFIRMED' ? 'var(--success)' : appt.status == 'CANCELLED' ? 'var(--danger)' : 'var(--warning)'};">
                                    ${appt.status}
                                </span>
                            </div>
                            <div class="review-body">
                                <div class="review-item"><span class="label">Doctor</span><span class="value">${appt.doctorName} (${appt.specialty})</span></div>
                                <div class="review-item"><span class="label">Service</span><span class="value">${appt.serviceName}</span></div>
                                <div class="review-item"><span class="label">Date &amp; Time</span><span class="value">${appt.appointmentDate} at ${appt.appointmentTime}</span></div>
                                <div class="review-item"><span class="label">Patient</span><span class="value">${appt.patientName}</span></div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </c:if>
    </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
