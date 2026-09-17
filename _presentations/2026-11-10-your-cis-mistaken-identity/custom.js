// KubeCon NA 2026 - Live Demo Presentation Enhancements
// Progressively integrates live ttyd terminal sessions (ports 7680-7684) into presentation slides.

(function () {
  'use strict';

  // Probe local port with short timeout to detect if ttyd is active
  async function checkPortOnline(port, timeoutMs = 600) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      await fetch(`http://127.0.0.1:${port}/`, {
        mode: 'no-cors',
        signal: controller.signal
      });
      clearTimeout(timer);
      return true;
    } catch (e) {
      clearTimeout(timer);
      return false;
    }
  }

  // Focus helper to release terminal focus back to slide deck
  function returnFocusToSlides() {
    const active = document.activeElement;
    if (active && active.tagName === 'IFRAME') {
      active.blur();
    }
    window.focus();
    if (document.body) {
      document.body.focus();
    }
  }

  // Initialize a demo container
  async function initContainer(container) {
    if (container.dataset.initialized === 'true') {
      return;
    }

    const port = container.dataset.port;
    if (!port) return;

    const fallback = container.querySelector('.demo-offline-fallback');
    const termFrame = container.querySelector('.demo-terminal-frame');
    if (!termFrame) return;

    const isOnline = await checkPortOnline(port);

    if (isOnline) {
      if (fallback) fallback.style.display = 'none';
      termFrame.style.display = 'flex';

      // Build toolbar and iframe
      termFrame.innerHTML = `
        <div class="demo-toolbar">
          <div class="demo-toolbar-left">
            <span class="demo-status-dot online"></span>
            <span class="demo-toolbar-title">LIVE WORKLOAD TERMINAL</span>
            <span class="demo-port-badge">127.0.0.1:${port}</span>
          </div>
          <div class="demo-toolbar-right">
            <button class="demo-btn demo-btn-unfocus" title="Return focus to presentation slides (Esc)">
              ⎋ Exit Focus [Esc]
            </button>
            <button class="demo-btn demo-btn-next" title="Advance to next slide">
              Next Slide ➔
            </button>
          </div>
        </div>
        <iframe
          src="http://127.0.0.1:${port}/"
          class="demo-iframe"
          tabindex="0"
          allow="clipboard-read; clipboard-write"
        ></iframe>
      `;

      const unfocusBtn = termFrame.querySelector('.demo-btn-unfocus');
      if (unfocusBtn) {
        unfocusBtn.addEventListener('click', (e) => {
          e.stopPropagation();
          returnFocusToSlides();
        });
      }

      const nextBtn = termFrame.querySelector('.demo-btn-next');
      if (nextBtn) {
        nextBtn.addEventListener('click', (e) => {
          e.stopPropagation();
          returnFocusToSlides();
          if (window.slideshow && typeof window.slideshow.gotoNextSlide === 'function') {
            window.slideshow.gotoNextSlide();
          }
        });
      }

      container.dataset.initialized = 'true';
    } else {
      // Offline fallback state
      if (fallback) fallback.style.display = 'block';
      termFrame.style.display = 'none';

      // Wire copy button in fallback if present
      const copyBtn = container.querySelector('.demo-copy-btn');
      const cmdText = container.querySelector('.demo-cmd-code');
      if (copyBtn && cmdText) {
        copyBtn.addEventListener('click', () => {
          navigator.clipboard.writeText(cmdText.innerText.trim());
          copyBtn.innerText = 'Copied!';
          setTimeout(() => { copyBtn.innerText = 'Copy'; }, 1500);
        });
      }

      // Wire retry button in fallback
      const retryBtn = container.querySelector('.demo-retry-btn');
      if (retryBtn) {
        retryBtn.addEventListener('click', async () => {
          retryBtn.innerText = 'Checking...';
          const retryOnline = await checkPortOnline(port, 1000);
          if (retryOnline) {
            initContainer(container);
          } else {
            retryBtn.innerText = 'Still Offline';
            setTimeout(() => { retryBtn.innerText = 'Retry'; }, 1500);
          }
        });
      }
    }
  }

  // Scan current slide for demo containers
  function checkCurrentSlide() {
    const visibleSlide = document.querySelector('.remark-visible');
    if (!visibleSlide) return;

    const containers = visibleSlide.querySelectorAll('.demo-slide-container');
    containers.forEach(container => {
      initContainer(container);
    });
  }

  // Global listener for Escape key to blur any focused iframe
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      returnFocusToSlides();
    }
  });

  // Clicking on slide background un-focuses any active iframe
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.demo-terminal-frame')) {
      returnFocusToSlides();
    }
  });

  // Attach hooks once DOM and slideshow are ready
  function setup() {
    if (window.slideshow) {
      window.slideshow.on('afterShowSlide', () => {
        setTimeout(checkCurrentSlide, 100);
      });
    }

    // Initial check
    setTimeout(checkCurrentSlide, 300);
    setTimeout(checkCurrentSlide, 1000);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setup);
  } else {
    setup();
  }
})();
