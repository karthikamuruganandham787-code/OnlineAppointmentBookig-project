<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MediBook - Online Appointment Booking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="home" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="hero">
    <div class="container hero-grid">
        <div>
            <span class="hero-eyebrow">&#10003; Trusted by 12,000+ patients</span>
            <h1>Book the Right Care,<br>At the <span class="highlight">Right Time.</span></h1>
            <p class="lead">Find verified doctors, check real-time availability, and confirm your appointment in under two minutes — no phone calls, no waiting rooms.</p>
            <div class="hero-ctas">
                <a href="${pageContext.request.contextPath}/booking" class="btn btn-primary">Book an Appointment</a>
                <a href="${pageContext.request.contextPath}/doctors" class="btn btn-secondary">Explore Doctors</a>
            </div>
        </div>
        <div class="hero-visual">
            <svg class="hero-center-icon" width="120" height="120" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01"/></svg>
            <div class="hero-floating-card card-1">
                <span class="hero-icon-badge success">&#10003;</span>
                <div>
                    <div class="hero-card-title">Appointment Confirmed</div>
                    <div class="hero-card-sub">Dr. Ramesh Kumar &middot; 10:15 AM</div>
                </div>
            </div>
            <div class="hero-floating-card card-2">
                <span class="hero-icon-badge primary">&#128197;</span>
                <div>
                    <div class="hero-card-title">Real-Time Slots</div>
                    <div class="hero-card-sub">Updated instantly</div>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="section" style="padding-top: 0;">
    <div class="container">
        <div class="trust-grid">
            <div class="trust-item">
                <div class="trust-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12l2 2 4-4"/><circle cx="12" cy="12" r="10"/></svg></div>
                <h3>Verified Doctors</h3>
                <p>Every doctor is credential-checked and rated by real patients.</p>
            </div>
            <div class="trust-item">
                <div class="trust-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                <h3>Easy Scheduling</h3>
                <p>Pick a doctor, service, date and time in a few simple taps.</p>
            </div>
            <div class="trust-item">
                <div class="trust-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                <h3>Real-Time Availability</h3>
                <p>See live open slots — never worry about double-booking.</p>
            </div>
            <div class="trust-item">
                <div class="trust-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <h3>Secure Booking</h3>
                <p>Your details are protected with industry-standard safeguards.</p>
            </div>
        </div>
    </div>
</section>

<section class="section" style="padding-top:0;">
    <div class="container">
        <div class="section-header">
            <span class="eyebrow">Our Doctors</span>
            <h2 class="section-title">Meet Our Specialists</h2>
            <p class="section-subtitle">Choose from a range of experienced, highly-rated doctors across specialties.</p>
        </div>

        <c:choose>
            <c:when test="${empty featuredDoctors}">
                <div class="empty-state">
                    <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 4-6 8-6s8 2 8 6"/></svg></div>
                    <h3>No doctors available</h3>
                    <p>Please check back soon.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="doctor-grid">
                    <c:forEach var="doc" items="${featuredDoctors}" varStatus="loop" end="2">
                        <div class="doctor-card">
                            <div class="doctor-photo-wrap">
                                <div class="doctor-avatar">
                                    <c:out value="${fn:substring(doc.name, 4, 5)}" default="D" />
                                </div>
                                <span class="availability-pill">Available Today</span>
                            </div>
                            <div class="doctor-body">
                                <h3 class="doctor-name">${doc.name}</h3>
                                <p class="doctor-specialty">${doc.specialty}</p>
                                <div class="doctor-meta">
                                    <span>${doc.qualification}</span>
                                    <span>&middot; ${doc.experienceYears} yrs exp.</span>
                                </div>
                                <div class="doctor-meta">
                                    <span class="doctor-rating">&#9733; ${doc.rating}</span>
                                </div>
                                <p class="doctor-bio">${doc.bio}</p>
                                <div class="doctor-actions">
                                    <a href="${pageContext.request.contextPath}/booking?doctorId=${doc.id}" class="btn btn-primary btn-sm btn-block">Book Appointment</a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="text-center mt-6">
                    <a href="${pageContext.request.contextPath}/doctors" class="btn btn-secondary">View All Doctors</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<section class="section" style="background: var(--surface); padding-top: var(--space-8);">
    <div class="container">
        <div class="section-header">
            <span class="eyebrow">Our Services</span>
            <h2 class="section-title">Services We Offer</h2>
            <p class="section-subtitle">From routine checkups to specialist consultations.</p>
        </div>
        <div class="service-grid">
            <c:forEach var="svc" items="${services}" end="2">
                <div class="service-card">
                    <div class="service-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"/></svg></div>
                    <h3>${svc.serviceName}</h3>
                    <p class="desc">${svc.description}</p>
                    <div class="service-footer">
                        <span class="service-duration">${svc.durationMins} mins</span>
                        <span class="service-fee">&#8377;${svc.fee}</span>
                    </div>
                </div>
            </c:forEach>
        </div>
        <div class="text-center mt-6">
            <a href="${pageContext.request.contextPath}/services" class="btn btn-secondary">View All Services</a>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
