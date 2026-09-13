<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Services - MediBook</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="services" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="section">
    <div class="container">
        <div class="section-header">
            <span class="eyebrow">What We Offer</span>
            <h2 class="section-title">Our Services</h2>
            <p class="section-subtitle">Choose a service to see doctors who provide it and book instantly.</p>
        </div>

        <c:choose>
            <c:when test="${empty services}">
                <div class="empty-state">
                    <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"/></svg></div>
                    <h3>No services available</h3>
                    <p>Please check back soon.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="service-grid">
                    <c:forEach var="svc" items="${services}">
                        <div class="service-card">
                            <div class="service-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"/></svg></div>
                            <h3>${svc.serviceName}</h3>
                            <p class="desc">${svc.description}</p>
                            <div class="service-footer">
                                <span class="service-duration">${svc.durationMins} mins</span>
                                <span class="service-fee">&#8377;${svc.fee}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/booking?serviceId=${svc.id}" class="btn btn-primary btn-sm btn-block mt-4">Book This Service</a>
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
