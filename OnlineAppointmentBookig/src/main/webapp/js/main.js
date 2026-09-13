/* ============================================================
   MEDIBOOK — SHARED UI BEHAVIOR
   ============================================================ */

(function () {
  'use strict';

  // ---- Sticky header shadow on scroll ----
  var header = document.getElementById('siteHeader');
  if (header) {
    window.addEventListener('scroll', function () {
      if (window.scrollY > 8) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }
    });
  }

  // ---- Mobile hamburger menu ----
  var hamburger = document.getElementById('hamburgerBtn');
  var mobileNav = document.getElementById('mobileNav');
  if (hamburger && mobileNav) {
    hamburger.addEventListener('click', function () {
      mobileNav.classList.toggle('open');
    });
    mobileNav.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        mobileNav.classList.remove('open');
      });
    });
  }

  // ---- Toast notifications ----
  // Usage: MediBook.toast('Doctor selected', 'success' | 'warning' | 'error' | 'info')
  window.MediBook = window.MediBook || {};

  window.MediBook.toast = function (message, type) {
    type = type || 'info';
    var container = document.getElementById('toast-container');
    if (!container) return;

    var icons = {
      success: '&#10003;',
      warning: '&#9888;',
      error: '&#10007;',
      info: '&#8226;'
    };

    var toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.innerHTML = '<span>' + (icons[type] || icons.info) + '</span><span>' + message + '</span>';
    container.appendChild(toast);

    requestAnimationFrame(function () {
      toast.classList.add('show');
    });

    setTimeout(function () {
      toast.classList.remove('show');
      setTimeout(function () {
        toast.remove();
      }, 350);
    }, 3200);
  };

  // ---- Generic modal helper ----
  // Usage: MediBook.confirmModal({title, message, confirmText, onConfirm})
  window.MediBook.confirmModal = function (options) {
    var backdrop = document.getElementById('confirmModalBackdrop');
    if (!backdrop) return;

    backdrop.querySelector('.modal-title').textContent = options.title || 'Are you sure?';
    backdrop.querySelector('.modal-message').textContent = options.message || '';
    var confirmBtn = backdrop.querySelector('.modal-confirm-btn');
    confirmBtn.textContent = options.confirmText || 'Confirm';

    function close() {
      backdrop.classList.remove('open');
      document.removeEventListener('keydown', onEsc);
    }

    function onEsc(e) {
      if (e.key === 'Escape') close();
    }

    var newConfirmBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
    newConfirmBtn.addEventListener('click', function () {
      close();
      if (typeof options.onConfirm === 'function') options.onConfirm();
    });

    backdrop.querySelectorAll('.modal-cancel-btn, .modal-close-btn').forEach(function (btn) {
      btn.onclick = close;
    });

    document.addEventListener('keydown', onEsc);
    backdrop.classList.add('open');
  };
})();
