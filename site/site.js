(function () {
  var doc = document;
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var header = doc.querySelector('.header');
  if (header) {
    var stuck = function () {
      header.classList.toggle('header--stuck', window.scrollY > 12);
    };
    stuck();
    window.addEventListener('scroll', stuck, { passive: true });
  }

  var revealables = doc.querySelectorAll('.reveal');
  if (reduce || !('IntersectionObserver' in window)) {
    revealables.forEach(function (el) {
      el.classList.add('in');
    });
  } else {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('in');
            io.unobserve(entry.target);
          }
        });
      },
      { rootMargin: '0px 0px -8% 0px', threshold: 0.08 }
    );
    revealables.forEach(function (el) {
      io.observe(el);
    });
  }

  var faq = doc.querySelector('.faq');
  if (faq) {
    faq.addEventListener('toggle', function (event) {
      var open = event.target;
      if (!open.matches('details') || !open.open) {
        return;
      }
      faq.querySelectorAll('details[open]').forEach(function (other) {
        if (other !== open) {
          other.open = false;
        }
      });
    }, true);
  }

  var gallery = doc.querySelector('.gallery');
  if (gallery) {
    gallery.addEventListener('keydown', function (event) {
      if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') {
        return;
      }
      var rtl = getComputedStyle(doc.documentElement).direction === 'rtl';
      var forward = event.key === 'ArrowRight' !== rtl;
      var step = gallery.clientWidth * 0.6;
      gallery.scrollBy({
        left: (forward ? 1 : -1) * step,
        behavior: reduce ? 'auto' : 'smooth'
      });
      event.preventDefault();
    });
  }
})();
