/* ============================================================
   MEDIBOOK — BOOKING FLOW LOGIC
   ============================================================ */

(function () {
  'use strict';

  var CTX = window.MEDIBOOK_CONTEXT_PATH || '';
  var PRESELECT = window.MEDIBOOK_PRESELECT || {};

  var state = {
    currentStep: 1,
    doctors: [],
    services: [],
    selectedDoctor: null,
    selectedService: null,
    selectedDate: null,   // yyyy-mm-dd
    selectedTime: null,   // HH:mm
    selectedSlotEnd: null,
    availableDates: [],   // yyyy-mm-dd strings for current doctor
    calendarViewDate: new Date(),
    patient: { name: '', email: '', phone: '', reason: '', notes: '' }
  };

  var TOTAL_STEPS = 5;

  document.addEventListener('DOMContentLoaded', function () {
    loadServices();
    bindStepNav();
    bindCalendarNav();
    bindPatientForm();
    bindConfirmButton();
    updateStepper();
  });

  /* ---------------------------------------------------------
     DATA LOADING
     --------------------------------------------------------- */
  function loadServices() {
    fetch(CTX + '/services?format=json')
      .then(function (r) { return r.json(); })
      .then(function (services) {
        state.services = services || [];
        renderServiceList();
        if (PRESELECT.serviceId) {
          var pre = state.services.find(function (s) { return String(s.id) === String(PRESELECT.serviceId); });
          if (pre) selectService(pre, true);
        }
      })
      .catch(function () {
        document.getElementById('serviceList').innerHTML =
          '<p class="summary-placeholder">Could not load services. Please refresh.</p>';
      });
  }

  function loadDoctorsForService(serviceId, preselectDoctorId) {
    var container = document.getElementById('doctorList');
    container.innerHTML =
      '<div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>' +
      '<div class="skeleton-card" style="height:74px;"><div class="skeleton-block" style="height:100%;"></div></div>';

    fetch(CTX + '/doctors?action=byService&serviceId=' + serviceId + '&format=json')
      .then(function (r) { return r.json(); })
      .then(function (doctors) {
        state.doctors = doctors || [];
        renderDoctorList();
        if (preselectDoctorId) {
          var pre = state.doctors.find(function (d) { return String(d.id) === String(preselectDoctorId); });
          if (pre) selectDoctor(pre, true);
        }
      })
      .catch(function () {
        container.innerHTML =
          '<p class="summary-placeholder">Could not load doctors for this service. Please refresh.</p>';
      });
  }

  /* ---------------------------------------------------------
     STEP 1: SERVICE SELECTION
     --------------------------------------------------------- */
  function renderServiceList() {
    var container = document.getElementById('serviceList');
    if (!state.services.length) {
      container.innerHTML = '<div class="empty-state"><h3>No services available</h3><p>Please check back soon.</p></div>';
      return;
    }
    container.innerHTML = state.services.map(function (s) {
      return '' +
        '<div class="mini-service-card" data-id="' + s.id + '">' +
          '<div class="mini-avatar">&#9877;</div>' +
          '<div class="mini-info">' +
            '<h4>' + escapeHtml(s.serviceName) + '</h4>' +
            '<p>' + s.durationMins + ' min &middot; &#8377;' + s.fee + '</p>' +
          '</div>' +
        '</div>';
    }).join('');

    container.querySelectorAll('.mini-service-card').forEach(function (card) {
      card.addEventListener('click', function () {
        var id = card.getAttribute('data-id');
        var svc = state.services.find(function (s) { return String(s.id) === id; });
        selectService(svc);
      });
    });
  }

  function selectService(svc, silent) {
    state.selectedService = svc;
    state.selectedDoctor = null;
    state.selectedDate = null;
    state.selectedTime = null;

    document.querySelectorAll('#serviceList .mini-service-card').forEach(function (c) {
      c.classList.toggle('selected', String(svc.id) === c.getAttribute('data-id'));
    });
    if (!silent) window.MediBook.toast(svc.serviceName + ' selected', 'success');
    updateSummary();

    // Update Step 2 subtitle & load doctors offering this service from DB via DAO
    var doctorPanelSub = document.getElementById('doctorPanelSub');
    if (doctorPanelSub) {
      var specName = svc.serviceName.replace(' Consultation', '').replace(' Care', '').toLowerCase();
      doctorPanelSub.textContent = 'Choose a ' + specName + ' specialist';
    }
    loadDoctorsForService(svc.id, silent ? PRESELECT.doctorId : null);
  }

  /* ---------------------------------------------------------
     STEP 2: DOCTOR SELECTION
     --------------------------------------------------------- */
  function renderDoctorList() {
    var container = document.getElementById('doctorList');
    if (!state.doctors.length) {
      container.innerHTML = '<div class="empty-state"><h3>No specialists found for this service</h3><p>Please select another service.</p></div>';
      return;
    }
    container.innerHTML = state.doctors.map(function (d) {
      var initial = (d.name || '?').replace('Dr. ', '').charAt(0);
      var isSelected = state.selectedDoctor && String(state.selectedDoctor.id) === String(d.id);
      var feeStr = state.selectedService ? ' &#8377;' + state.selectedService.fee : '';
      return '' +
        '<div class="mini-doctor-card ' + (isSelected ? 'selected' : '') + '" data-id="' + d.id + '">' +
          '<div class="mini-avatar">' + initial + '</div>' +
          '<div class="mini-info">' +
            '<h4>' + escapeHtml(d.name) + '</h4>' +
            '<p class="mini-doc-spec">' + escapeHtml(d.specialty) + ' &middot; &#9733; ' + d.rating + '</p>' +
            '<p class="mini-doc-meta">Experience: ' + d.experienceYears + ' yrs' + (feeStr ? ' &middot; Fee:' + feeStr : '') + '</p>' +
            '<p class="mini-doc-status"><span class="badge-avail">' + escapeHtml(d.availabilityStatus || 'AVAILABLE') + '</span></p>' +
          '</div>' +
          '<button type="button" class="btn btn-sm ' + (isSelected ? 'btn-primary' : 'btn-ghost') + ' select-doc-btn">' +
            (isSelected ? 'Selected' : 'Select Doctor') +
          '</button>' +
        '</div>';
    }).join('');

    container.querySelectorAll('.mini-doctor-card').forEach(function (card) {
      card.addEventListener('click', function () {
        var id = card.getAttribute('data-id');
        var doc = state.doctors.find(function (d) { return String(d.id) === id; });
        selectDoctor(doc);
      });
    });
  }

  function selectDoctor(doc, silent) {
    state.selectedDoctor = doc;
    state.selectedDate = null;
    state.selectedTime = null;
    // Reset available dates and calendar view whenever a new doctor is selected
    state.availableDates = [];
    state.calendarViewDate = new Date();

    document.querySelectorAll('#doctorList .mini-doctor-card').forEach(function (c) {
      var isThis = String(doc.id) === c.getAttribute('data-id');
      c.classList.toggle('selected', isThis);
      var btn = c.querySelector('.select-doc-btn');
      if (btn) {
        btn.textContent = isThis ? 'Selected' : 'Select Doctor';
        btn.className = 'btn btn-sm ' + (isThis ? 'btn-primary' : 'btn-ghost') + ' select-doc-btn';
      }
    });

    if (!silent) window.MediBook.toast(doc.name + ' selected', 'success');
    updateSummary();
  }

  /* ---------------------------------------------------------
     STEP 3: CALENDAR + TIME SLOTS
     --------------------------------------------------------- */
  function enterDateTimeStep() {
    if (!state.selectedDoctor) return;

    // Reset and immediately render an empty calendar so the grid is visible
    // while the fetch is in flight (avoids a stale or blank calendar).
    state.availableDates = [];
    renderCalendar();

    var doctorId = state.selectedDoctor.id;
    fetch(CTX + '/booking?action=dates&doctorId=' + doctorId + '&format=json')
      .then(function (r) {
        if (!r.ok) {
          throw new Error('Dates API returned HTTP ' + r.status + ' for doctorId=' + doctorId);
        }
        return r.json();
      })
      .then(function (dates) {
        // Trim each date string to guard against accidental whitespace from the server
        state.availableDates = (dates || []).map(function (d) { return String(d).trim(); });
        renderCalendar();
      })
      .catch(function (err) {
        console.error('[MediBook] Failed to load available dates:', err);
        state.availableDates = [];
        renderCalendar();
      });
  }

  function renderCalendar() {
    var viewDate = state.calendarViewDate;
    var year = viewDate.getFullYear();
    var month = viewDate.getMonth();

    document.getElementById('calendarMonthLabel').textContent =
      viewDate.toLocaleString('default', { month: 'long' }) + ' ' + year;

    var firstDay = new Date(year, month, 1).getDay();
    var daysInMonth = new Date(year, month + 1, 0).getDate();
    var today = stripTime(new Date());

    var html = '';
    for (var i = 0; i < firstDay; i++) {
      html += '<div class="calendar-day empty"></div>';
    }

    for (var d = 1; d <= daysInMonth; d++) {
      var cellDate = new Date(year, month, d);
      var iso = toIsoDate(cellDate);
      var classes = ['calendar-day'];

      if (cellDate < today) {
        classes.push('disabled');
      } else if (state.availableDates.indexOf(iso) !== -1) {
        classes.push('available');
      } else {
        classes.push('unavailable');
      }

      if (isSameDay(cellDate, today)) classes.push('today');
      if (state.selectedDate === iso) classes.push('selected');

      html += '<div class="' + classes.join(' ') + '" data-date="' + iso + '">' + d + '</div>';
    }

    document.getElementById('calendarDays').innerHTML = html;

    document.querySelectorAll('.calendar-day.available').forEach(function (cell) {
      cell.addEventListener('click', function () {
        var iso = cell.getAttribute('data-date');
        selectDate(iso);
      });
    });
  }

  function selectDate(iso) {
    state.selectedDate = iso;
    state.selectedTime = null;
    renderCalendar();
    loadSlotsForDate(iso);
    updateSummary();
  }

  function loadSlotsForDate(iso) {
    var slotsSection = document.getElementById('slotsSection');
    var noSlotsEmpty = document.getElementById('noSlotsEmpty');
    var slotGrid = document.getElementById('slotGrid');
    var label = document.getElementById('selectedDateLabel');

    label.textContent = formatDisplayDate(iso);
    slotGrid.innerHTML = '<div class="spinner dark"></div>';
    slotsSection.classList.remove('hidden');
    noSlotsEmpty.classList.add('hidden');

    fetch(CTX + '/booking?action=slots&doctorId=' + state.selectedDoctor.id + '&date=' + iso + '&format=json')
      .then(function (r) { return r.json(); })
      .then(function (slots) {
        renderSlots(slots || []);
      });
  }

  function renderSlots(slots) {
    var slotGrid = document.getElementById('slotGrid');
    var slotsSection = document.getElementById('slotsSection');
    var noSlotsEmpty = document.getElementById('noSlotsEmpty');

    if (!slots.length) {
      slotsSection.classList.add('hidden');
      noSlotsEmpty.classList.remove('hidden');
      return;
    }

    slotGrid.innerHTML = slots.map(function (slot) {
      var statusClass = slot.status === 'AVAILABLE' ? 'available' :
                         slot.status === 'BOOKED' ? 'booked' : 'unavailable';
      return '<button type="button" class="slot-btn ' + statusClass + '" ' +
             'data-time="' + slot.slotTime + '" data-end="' + slot.slotEndTime + '" ' +
             (statusClass !== 'available' ? 'disabled' : '') + '>' +
             formatTime(slot.slotTime) + '</button>';
    }).join('');

    slotGrid.querySelectorAll('.slot-btn.available').forEach(function (btn) {
      btn.addEventListener('click', function () {
        slotGrid.querySelectorAll('.slot-btn').forEach(function (b) { b.classList.remove('selected'); });
        btn.classList.add('selected');
        state.selectedTime = btn.getAttribute('data-time');
        state.selectedSlotEnd = btn.getAttribute('data-end');
        window.MediBook.toast('Time slot selected', 'success');
        updateSummary();
      });
    });
  }

  function bindCalendarNav() {
    document.getElementById('prevMonth').addEventListener('click', function () {
      state.calendarViewDate.setMonth(state.calendarViewDate.getMonth() - 1);
      renderCalendar();
    });
    document.getElementById('nextMonth').addEventListener('click', function () {
      state.calendarViewDate.setMonth(state.calendarViewDate.getMonth() + 1);
      renderCalendar();
    });
  }

  /* ---------------------------------------------------------
     STEP 4: PATIENT DETAILS
     --------------------------------------------------------- */
  function bindPatientForm() {
    ['patientName', 'email', 'phone', 'reason', 'notes'].forEach(function (id) {
      var el = document.getElementById(id);
      el.addEventListener('input', function () {
        clearFieldError(id);
      });
    });
  }

  function validatePatientForm() {
    var name = document.getElementById('patientName').value.trim();
    var email = document.getElementById('email').value.trim();
    var phone = document.getElementById('phone').value.trim();
    var valid = true;

    if (name.length < 2) { showFieldError('patientName'); valid = false; }
    if (!/^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/.test(email)) { showFieldError('email'); valid = false; }
    if (!/^[0-9]{10}$/.test(phone)) { showFieldError('phone'); valid = false; }

    if (valid) {
      state.patient.name = name;
      state.patient.email = email;
      state.patient.phone = phone;
      state.patient.reason = document.getElementById('reason').value.trim();
      state.patient.notes = document.getElementById('notes').value.trim();
    }
    return valid;
  }

  function showFieldError(id) {
    document.getElementById(id).classList.add('error');
    var err = document.querySelector('[data-error-for="' + id + '"]');
    if (err) err.classList.add('show');
  }

  function clearFieldError(id) {
    document.getElementById(id).classList.remove('error');
    var err = document.querySelector('[data-error-for="' + id + '"]');
    if (err) err.classList.remove('show');
  }

  /* ---------------------------------------------------------
     STEP 5: REVIEW
     --------------------------------------------------------- */
  function renderReview() {
    var d = state.selectedDoctor, s = state.selectedService;
    var html = '' +
      reviewRow('Service', s ? s.serviceName : '-') +
      reviewRow('Doctor', d ? d.name : '-') +
      reviewRow('Specialty', d ? d.specialty : '-') +
      reviewRow('Date', formatDisplayDate(state.selectedDate)) +
      reviewRow('Time', formatTime(state.selectedTime) + (state.selectedSlotEnd ? ' - ' + formatTime(state.selectedSlotEnd) : '')) +
      reviewRow('Patient', state.patient.name) +
      reviewRow('Email', state.patient.email) +
      reviewRow('Phone', state.patient.phone) +
      (s ? reviewRow('Fee', '&#8377;' + s.fee) : '');
    document.getElementById('reviewBody').innerHTML = html;
  }

  function reviewRow(label, value) {
    return '<div class="review-item"><span class="label">' + label + '</span><span class="value">' + value + '</span></div>';
  }

  /* ---------------------------------------------------------
     STICKY SUMMARY
     --------------------------------------------------------- */
  function updateSummary() {
    var container = document.getElementById('summaryContent');
    var d = state.selectedDoctor, s = state.selectedService;

    if (!d && !s && !state.selectedDate) {
      container.innerHTML = '<p class="summary-placeholder">Your selections will appear here as you go.</p>';
      return;
    }

    var html = '';
    if (s) html += summaryRow('Service', s.serviceName);
    
    if (d) {
      html += summaryRow('Doctor', d.name);
      html += summaryRow('Specialty', d.specialty);
    } else if (state.currentStep > 1) {
      html += summaryRow('Doctor', 'Not selected');
    }
    
    if (state.selectedDate) html += summaryRow('Date', formatDisplayDate(state.selectedDate));
    if (state.selectedTime) html += summaryRow('Time', formatTime(state.selectedTime));
    if (s) html += summaryRow('Duration', s.durationMins + ' mins');

    container.innerHTML = html;

    if (s) {
      container.innerHTML += '<div class="summary-total"><span>Total Fee</span><span>&#8377;' + s.fee + '</span></div>';
    }
  }

  function summaryRow(label, value) {
    return '<div class="summary-row"><span class="summary-label">' + label + '</span><span class="summary-value">' + value + '</span></div>';
  }

  /* ---------------------------------------------------------
     STEPPER NAVIGATION
     --------------------------------------------------------- */
  function bindStepNav() {
    document.getElementById('toStep2').addEventListener('click', function () {
      if (!state.selectedService) { window.MediBook.toast('Please select a service', 'warning'); return; }
      goToStep(2);
    });
    document.getElementById('toStep3').addEventListener('click', function () {
      if (!state.selectedDoctor) { window.MediBook.toast('Please select a doctor', 'warning'); return; }
      goToStep(3);
      enterDateTimeStep();
    });
    document.getElementById('toStep4').addEventListener('click', function () {
      if (!state.selectedDate) { window.MediBook.toast('Please select a date', 'warning'); return; }
      if (!state.selectedTime) { window.MediBook.toast('Please select a time slot', 'warning'); return; }
      goToStep(4);
    });
    document.getElementById('toStep5').addEventListener('click', function () {
      if (!validatePatientForm()) return;
      renderReview();
      goToStep(5);
    });

    document.querySelectorAll('[data-back]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var targetStep = parseInt(btn.getAttribute('data-back'), 10);
        goToStep(targetStep);
        // Re-enter the date/time step when navigating back to step 3 so the
        // calendar is always up-to-date for the currently selected doctor.
        if (targetStep === 3 && state.selectedDoctor) {
          enterDateTimeStep();
        }
      });
    });
  }

  function goToStep(step) {
    state.currentStep = step;
    document.querySelectorAll('.step-panel').forEach(function (panel) {
      panel.classList.toggle('hidden', parseInt(panel.getAttribute('data-panel'), 10) !== step);
    });
    updateStepper();
    updateSummary();
    window.scrollTo({ top: document.getElementById('stepper').offsetTop - 100, behavior: 'smooth' });
  }

  function updateStepper() {
    var steps = document.querySelectorAll('.step');
    steps.forEach(function (stepEl) {
      var n = parseInt(stepEl.getAttribute('data-step'), 10);
      stepEl.classList.toggle('completed', n < state.currentStep);
      stepEl.classList.toggle('current', n === state.currentStep);
    });
    var progressPct = ((state.currentStep - 1) / (TOTAL_STEPS - 1)) * 90;
    document.getElementById('stepperProgress').style.width = progressPct + '%';
  }

  /* ---------------------------------------------------------
     FINAL SUBMISSION
     --------------------------------------------------------- */
  function bindConfirmButton() {
    document.getElementById('confirmBookingBtn').addEventListener('click', function () {
      window.MediBook.confirmModal({
        title: 'Confirm your appointment?',
        message: 'You are about to book with ' + (state.selectedDoctor ? state.selectedDoctor.name : '') + ' on ' + formatDisplayDate(state.selectedDate) + ' at ' + formatTime(state.selectedTime) + '.',
        confirmText: 'Confirm Appointment',
        onConfirm: submitBooking
      });
    });
  }

  function submitBooking() {
    var btn = document.getElementById('confirmBookingBtn');
    var originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner"></span> Booking...';

    var body = new URLSearchParams();
    body.append('patientName', state.patient.name);
    body.append('email', state.patient.email);
    body.append('phone', state.patient.phone);
    body.append('reason', state.patient.reason);
    body.append('notes', state.patient.notes);
    body.append('doctorId', state.selectedDoctor.id);
    body.append('serviceId', state.selectedService.id);
    body.append('date', state.selectedDate);
    body.append('time', state.selectedTime);

    fetch(CTX + '/booking', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString()
    })
      .then(function (r) { return r.json(); })
      .then(function (result) {
        if (result.success) {
          window.MediBook.toast('Appointment confirmed', 'success');
          window.location.href = CTX + '/confirmation?id=' + result.appointmentId;
        } else if (result.slotTaken) {
          window.MediBook.toast(result.message || 'This time slot is no longer available. Please select another time.', 'error');
          btn.disabled = false;
          btn.innerHTML = originalText;
          goToStep(3);
          if (state.selectedDate) loadSlotsForDate(state.selectedDate);
        } else {
          window.MediBook.toast(result.message || 'Booking failed', 'error');
          btn.disabled = false;
          btn.innerHTML = originalText;
        }
      })
      .catch(function () {
        window.MediBook.toast('Booking failed. Please try again.', 'error');
        btn.disabled = false;
        btn.innerHTML = originalText;
      });
  }

  /* ---------------------------------------------------------
     UTILITIES
     --------------------------------------------------------- */
  function stripTime(d) {
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }

  function isSameDay(a, b) {
    return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
  }

  function toIsoDate(d) {
    var m = ('0' + (d.getMonth() + 1)).slice(-2);
    var day = ('0' + d.getDate()).slice(-2);
    return d.getFullYear() + '-' + m + '-' + day;
  }

  function formatDisplayDate(iso) {
    if (!iso) return '-';
    var parts = iso.split('-');
    var d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  function formatTime(hhmm) {
    if (!hhmm) return '-';
    var parts = hhmm.split(':');
    var h = parseInt(parts[0], 10);
    var m = parts[1];
    var suffix = h >= 12 ? 'PM' : 'AM';
    var h12 = h % 12 === 0 ? 12 : h % 12;
    return h12 + ':' + m + ' ' + suffix;
  }

  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
})();
