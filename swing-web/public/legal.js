/* ─────────────────────────────────────────────
   Swing, Legal page chrome (nav + footer + JS)
   Uses document.write for inline injection.
   ───────────────────────────────────────────── */

(function () {
  const BRAND_SVG = `<svg class="brand-svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" aria-label="Swing">
  <!-- Motion arc: a stylized S formed by the bat's swing path -->
  <path d="M 78 16 C 56 16, 44 30, 44 44 C 44 54, 52 60, 64 62 C 76 64, 84 68, 84 78 C 84 90, 70 96, 50 96"
        fill="none" stroke="currentColor" stroke-width="14" stroke-linecap="round"/>
  <!-- Sports ball at point of impact (top-left of S) -->
  <circle cx="22" cy="22" r="10" fill="#FF3D5A"/>
  <!-- Ball seam -->
  <path d="M 14 22 Q 22 17 30 22" fill="none" stroke="#0A0B0A" stroke-width="1.2" stroke-linecap="round" opacity=".55"/>
  <path d="M 14 22 Q 22 27 30 22" fill="none" stroke="#0A0B0A" stroke-width="1.2" stroke-linecap="round" opacity=".55"/>
</svg>`;

  // Inject scroll bar at top of body
  document.addEventListener('DOMContentLoaded', () => {
    // Theme persistence
    const root = document.documentElement;
    const saved = localStorage.getItem('swing-theme');
    if (saved) root.setAttribute('data-theme', saved);
    const themeBtn = document.getElementById('themeBtn');
    if (themeBtn) {
      themeBtn.addEventListener('click', () => {
        const cur = root.getAttribute('data-theme');
        const next = cur === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        localStorage.setItem('swing-theme', next);
      });
    }

    // Scroll progress
    const scrollBar = document.getElementById('scrollBar');
    if (scrollBar) {
      const update = () => {
        const h = document.documentElement;
        const max = h.scrollHeight - h.clientHeight;
        const pct = max > 0 ? (h.scrollTop / max) * 100 : 0;
        scrollBar.style.width = pct + '%';
      };
      window.addEventListener('scroll', update, { passive: true });
      update();
    }

    // TOC active state on scroll
    const sections = document.querySelectorAll('.legal-content section[id]');
    const tocLinks = document.querySelectorAll('.toc a');
    if (sections.length && tocLinks.length) {
      const io = new IntersectionObserver((entries) => {
        entries.forEach(e => {
          if (e.isIntersecting) {
            const id = e.target.id;
            tocLinks.forEach(a => {
              a.classList.toggle('active', a.getAttribute('href') === '#' + id);
            });
          }
        });
      }, { rootMargin: '-30% 0px -60% 0px', threshold: 0 });
      sections.forEach(s => io.observe(s));
    }
  });

  // Expose brand svg for templates
  window.SwingBrandSvg = BRAND_SVG;
})();
