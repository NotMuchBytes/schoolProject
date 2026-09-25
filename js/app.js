"use strict";

const qs = (selector, scope = document) => scope.querySelector(selector);
const qsa = (selector, scope = document) => [...scope.querySelectorAll(selector)];

const siteHeader = qs(".site-header");
const navLinks = qsa(".nav-links a");
const revealItems = qsa(".reveal");

const updateHeader = () => {
  siteHeader.classList.toggle("scrolled", window.scrollY > 16);
};

updateHeader();
window.addEventListener("scroll", updateHeader, { passive: true });

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.12 }
);

revealItems.forEach((item) => revealObserver.observe(item));

const sectionObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      navLinks.forEach((link) => {
        const target = link.getAttribute("href").slice(1);
        link.classList.toggle("active", target === entry.target.id);
      });
    });
  },
  { rootMargin: "-35% 0px -55%", threshold: 0 }
);

qsa("main section[id]").forEach((section) => sectionObserver.observe(section));

// Presentation viewer. Replace content/presentation/manifest.json and its image files.
const presentation = {
  viewer: qs("#presentationViewer"),
  image: qs("#slideImage"),
  loader: qs("#slideLoader"),
  counter: qs("#slideCounter"),
  previous: qs("#previousSlide"),
  next: qs("#nextSlide"),
  fullscreen: qs("#presentationFullscreen"),
  slides: [],
  index: 0,
};

function renderSlide(index) {
  if (!presentation.slides.length) return;
  presentation.index = Math.min(Math.max(index, 0), presentation.slides.length - 1);
  const slide = presentation.slides[presentation.index];
  presentation.image.classList.remove("loaded");
  presentation.image.alt = slide.alt || `الشريحة ${presentation.index + 1}`;
  presentation.image.src = `content/presentation/${slide.src}`;
  presentation.counter.textContent = `${presentation.index + 1} / ${presentation.slides.length}`;
  presentation.previous.disabled = presentation.index === 0;
  presentation.next.disabled = presentation.index === presentation.slides.length - 1;
}

presentation.image.addEventListener("load", () => {
  presentation.loader.hidden = true;
  presentation.viewer.querySelector(".slide-stage").setAttribute("aria-busy", "false");
  presentation.image.classList.add("loaded");
});

presentation.image.addEventListener("error", () => {
  presentation.loader.innerHTML = "تعذّر تحميل ملف الشريحة. راجع manifest.json";
});

fetch("content/presentation/manifest.json")
  .then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  })
  .then((manifest) => {
    presentation.slides = Array.isArray(manifest.slides) ? manifest.slides : [];
    if (!presentation.slides.length) throw new Error("No slides configured");
    renderSlide(0);
  })
  .catch(() => {
    presentation.loader.textContent = "أضف صور الشرائح وحدّث ملف manifest.json لعرض الدرس.";
    presentation.counter.textContent = "0 / 0";
    presentation.previous.disabled = true;
    presentation.next.disabled = true;
  });

presentation.previous.addEventListener("click", () => renderSlide(presentation.index - 1));
presentation.next.addEventListener("click", () => renderSlide(presentation.index + 1));

presentation.viewer.addEventListener("keydown", (event) => {
  if (event.key === "ArrowLeft") renderSlide(presentation.index + 1);
  if (event.key === "ArrowRight") renderSlide(presentation.index - 1);
});

async function requestFullscreen(element) {
  const method = element.requestFullscreen || element.webkitRequestFullscreen;
  if (!method) return;
  try {
    await method.call(element);
  } catch {
    // Fullscreen can be denied by browser policy (for example in headless mode).
  }
}

presentation.fullscreen.addEventListener("click", () => requestFullscreen(presentation.viewer));

// Godot game loader. Delaying iframe creation avoids downloading the game export on page load.
const game = {
  viewport: qs("#gameViewport"),
  frame: qs("#gameFrame"),
  cover: qs("#gameCover"),
  loading: qs("#gameLoading"),
  error: qs("#gameError"),
  start: qs("#startGame"),
  retry: qs("#retryGame"),
  fullscreen: qs("#gameFullscreen"),
  status: qs("#gameStatus"),
  statusDot: qs("#gameStatusDot"),
  started: false,
  timeout: null,
};

function setGameStatus(text, state = "ready") {
  game.status.textContent = text;
  game.statusDot.className = state === "ready" ? "" : state;
}

function launchGame() {
  window.clearTimeout(game.timeout);
  game.started = true;
  game.cover.hidden = true;
  game.error.hidden = true;
  game.loading.hidden = false;
  setGameStatus("جارٍ التحميل", "loading");
  game.frame.src = `${game.frame.dataset.src}?v=${Date.now()}`;

  game.timeout = window.setTimeout(() => {
    if (!game.loading.hidden) {
      game.loading.querySelector("span").textContent = "ما زال ملف اللعبة الكبير قيد التحميل…";
    }
  }, 12000);
}

game.start.addEventListener("click", launchGame);
game.retry.addEventListener("click", launchGame);

game.frame.addEventListener("load", () => {
  if (!game.started) return;
  window.clearTimeout(game.timeout);
  game.loading.hidden = true;
  setGameStatus("اللعبة تعمل", "ready");
  game.frame.focus();
});

game.frame.addEventListener("error", () => {
  window.clearTimeout(game.timeout);
  game.loading.hidden = true;
  game.error.hidden = false;
  setGameStatus("خطأ في التحميل", "error");
});

game.fullscreen.addEventListener("click", () => {
  requestFullscreen(game.viewport);
  if (game.started) game.frame.focus();
});
