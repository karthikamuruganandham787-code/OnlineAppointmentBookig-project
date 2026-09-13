<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book an Appointment - MediBook</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<c:set var="activePage" value="booking" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<section class="section">
    <div class="container">
        <div class="section-header">
            <span class="eyebrow">Book Appointment</span>
            <h2 class="section-title">Schedule Your Visit</h2>
            <p class="section-subtitle">Follow the steps below to book your appointment in minutes.</p>
        </div>

        <div class="stepper" id="stepper">
            <div class="stepper-progress" id="stepperProgress"></div>
            <div class="step current" data-step="1">
                <div class="step-circle">1</div>
                <div class="step-label">Service</div>
            </div>
            <div class="step" data-step="2">
                <div class="step-circle">2</div>
                <div class="step-label">Doctor</div>
            </div>
            <div class="step" data-step="3">
                <div class="step-circle">3</div>
                <div class="step-label">Date &amp; Time</div>
            </div>
            <div class="step" data-step="4">
                <div class="step-circle">4</div>
                <div class="step-label">Patient Details</div>
            </div>
            <div class="step" data-step="5">
                <div class="step-circle">5</div>
                <div class="step-label">Review</div>
            </div>
        </div>

        <div class="booking-layout">
            <div>
                <!-- STEP 1: SERVICE -->
                <div class="booking-panel step-panel" data-panel="1">
                    <h3 class="panel-title">Select a Service</h3>
                    <p class="panel-sub">Choose the type of consultation you need.</p>
                    <div class="select-grid-service" id="serviceList">
                        <div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>
                        <div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>
                    </div>
                    <div class="step-actions">
                        <span></span>
                        <button type="button" class="btn btn-primary" id="toStep2">Continue</button>
                    </div>
                </div>

                <!-- STEP 2: DOCTOR -->
                <div class="booking-panel step-panel hidden" data-panel="2">
                    <h3 class="panel-title">Select a Doctor</h3>
                    <p class="panel-sub" id="doctorPanelSub">Select a specialist for your chosen service.</p>
                    <div class="select-grid-doctor" id="doctorList">
                        <div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>
                        <div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>
                    </div>
                    <div class="step-actions">
                        <button type="button" class="btn btn-ghost" data-back="1">Back</button>
                        <button type="button" class="btn btn-primary" id="toStep3">Continue</button>
                    </div>
                </div>

                <!-- STEP 3: DATE & TIME -->
                <div class="booking-panel step-panel hidden" data-panel="3">
                    <h3 class="panel-title">Pick a Date &amp; Time</h3>
                    <p class="panel-sub">Available slots are shown in green. Slots update in real time.</p>

                    <div class="calendar" id="calendar">
                        <div class="calendar-header">
                            <button type="button" class="calendar-nav-btn" id="prevMonth">&#8592;</button>
                            <h4 id="calendarMonthLabel">Month Year</h4>
                            <button type="button" class="calendar-nav-btn" id="nextMonth">&#8594;</button>
                        </div>
                        <div class="calendar-weekdays">
                            <span>Su</span><span>Mo</span><span>Tu</span><span>We</span><span>Th</span><span>Fr</span><span>Sa</span>
                        </div>
                        <div class="calendar-days" id="calendarDays"></div>
                    </div>

                    <div id="slotsSection" class="hidden">
                        <h4 style="margin: var(--space-5) 0 4px; font-size:15px;">Available Time Slots</h4>
                        <p style="margin:0; font-size:13px; color:var(--text-secondary);" id="selectedDateLabel"></p>
                        <div class="slot-grid" id="slotGrid"></div>
                    </div>

                    <div id="noSlotsEmpty" class="empty-state hidden">
                        <div class="empty-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                        <h3>No available slots</h3>
                        <p>Please choose another date.</p>
                    </div>

                    <div class="step-actions">
                        <button type="button" class="btn btn-ghost" data-back="2">Back</button>
                        <button type="button" class="btn btn-primary" id="toStep4">Continue</button>
                    </div>
                </div>

                <!-- STEP 4: PATIENT DETAILS -->
                <div class="booking-panel step-panel hidden" data-panel="4">
                    <h3 class="panel-title">Patient Details</h3>
                    <p class="panel-sub">Please provide your contact information.</p>

                    <form id="patientForm" novalidate>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="patientName">Full Name *</label>
                                <input type="text" id="patientName" class="form-control" placeholder="e.g. Karthika M" required>
                                <div class="field-error" data-error-for="patientName">Please enter your full name.</div>
                            </div>
                            <div class="form-group">
                                <label for="phone">Phone *</label>
                                <input type="tel" id="phone" class="form-control" placeholder="10-digit mobile number" required>
                                <div class="field-error" data-error-for="phone">Please enter a valid 10-digit phone number.</div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="email">Email *</label>
                            <input type="email" id="email" class="form-control" placeholder="you@example.com" required>
                            <div class="field-error" data-error-for="email">Please enter a valid email address.</div>
                        </div>
                        <div class="form-group">
                            <label for="reason">Reason for Visit</label>
                            <input type="text" id="reason" class="form-control" placeholder="e.g. Routine checkup, follow-up, chest pain...">
                        </div>
                        <div class="form-group">
                            <label for="notes">Additional Notes</label>
                            <textarea id="notes" class="form-control" rows="3" placeholder="Anything else the doctor should know?"></textarea>
                        </div>
                    </form>

                    <div class="step-actions">
                        <button type="button" class="btn btn-ghost" data-back="3">Back</button>
                        <button type="button" class="btn btn-primary" id="toStep5">Continue</button>
                    </div>
                </div>

                <!-- STEP 5: REVIEW -->
                <div class="booking-panel step-panel hidden" data-panel="5">
                    <h3 class="panel-title">Review Your Appointment</h3>
                    <p class="panel-sub">Please confirm the details below before booking.</p>

                    <div class="review-box">
                        <div class="review-header">Appointment Summary</div>
                        <div class="review-body" id="reviewBody"></div>
                    </div>

                    <div class="step-actions">
                        <button type="button" class="btn btn-ghost" data-back="4">Edit Details</button>
                        <button type="button" class="btn btn-primary" id="confirmBookingBtn">Confirm Appointment</button>
                    </div>
                </div>
            </div>

            <!-- STICKY SUMMARY -->
            <div class="summary-card">
                <h4>Booking Summary</h4>
                <div id="summaryContent">
                    <p class="summary-placeholder">Your selections will appear here as you go.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

<!-- Confirm modal -->
<div class="modal-backdrop" id="confirmModalBackdrop">
    <div class="modal-box">
        <h3 class="modal-title">Confirm your appointment?</h3>
        <p class="modal-message">This will finalize your booking.</p>
        <div class="modal-actions">
            <button type="button" class="btn btn-ghost modal-cancel-btn">Cancel</button>
            <button type="button" class="btn btn-primary modal-confirm-btn">Confirm Appointment</button>
        </div>
    </div>
</div>

<script>
    window.MEDIBOOK_PRESELECT = {
        doctorId: "${param.doctorId}",
        serviceId: "${param.serviceId}"
    };
    window.MEDIBOOK_CONTEXT_PATH = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/js/booking.js"></script>
</body>
</html>
