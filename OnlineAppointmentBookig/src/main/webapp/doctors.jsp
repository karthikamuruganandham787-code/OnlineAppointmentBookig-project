<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find a Doctor - MediBook</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="doctors" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="section">
    <div class="container">
        <div class="section-header">
            <span class="eyebrow">Doctor Directory</span>
            <h2 class="section-title">Find Your Doctor</h2>
            <p class="section-subtitle">Search by name or specialty to find the right specialist for you.</p>
        </div>

        <form action="${pageContext.request.contextPath}/doctors" method="get">
            <input type="hidden" name="action" value="search">
            <div class="search-bar">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" name="q" placeholder="Search by doctor name or specialty..." value="${searchKeyword}">
                <button type="submit" class="btn btn-primary btn-sm">Search</button>
            </div>
        </form>

        <c:choose>
            <c:when test="${empty doctors}">
                <div class="empty-state">
                    <div class="empty-icon">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    </div>
                    <h3>No doctors found</h3>
                    <p>Try a different name or specialty.</p>
                    <a href="${pageContext.request.contextPath}/doctors" class="btn btn-secondary btn-sm">Clear Search</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="doctor-grid">
                    <c:forEach var="doc" items="${doctors}">
                        <div class="doctor-card">
                            <div class="doctor-photo-wrap">
                                <div class="doctor-avatar">${fn:substring(doc.name, 4, 5)}</div>
                                <span class="availability-pill">${doc.availabilityStatus == 'AVAILABLE' ? 'Available Today' : 'Booked'}</span>
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
            </c:otherwise>
        </c:choose>
    </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
