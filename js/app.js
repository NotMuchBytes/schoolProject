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

async function requestFullscreen(element) {
  const method = element.requestFullscreen || element.webkitRequestFullscreen;
  if (!method) return;
  try {
    await method.call(element);
  } catch {
    // Fullscreen can be denied by browser policy (for example in headless mode).
  }
}

// Data-driven lesson review, shared with the PowerPoint source.
const questions = {
  viewer: qs("#questionViewer"),
  topic: qs("#questionTopic"),
  counter: qs("#questionCounter"),
  progress: qs("#questionProgress"),
  progressFill: qs("#questionProgressFill"),
  number: qs("#questionNumber"),
  text: qs("#questionText"),
  answerPanel: qs("#answerPanel"),
  answerText: qs("#answerText"),
  answerToggle: qs("#answerToggle"),
  surveyPanel: qs("#surveyPanel"),
  surveyOptions: qs("#surveyOptions"),
  surveyResponse: qs("#surveyResponse"),
  previous: qs("#previousQuestion"),
  next: qs("#nextQuestion"),
  items: [],
  index: 0,
};

function renderQuestion() {
  const question = questions.items[questions.index];
  if (!question) return;

  const total = questions.items.length;
  const arabicNumber = (value) => new Intl.NumberFormat("ar-u-nu-arab").format(value);
  questions.topic.textContent = `المحور ${arabicNumber(question.group)} / ${question.groupTitle}`;
  questions.counter.textContent = `${arabicNumber(questions.index + 1)} / ${arabicNumber(total)}`;
  questions.progress.setAttribute("aria-valuemax", total);
  questions.progress.setAttribute("aria-valuenow", questions.index + 1);
  questions.progressFill.style.setProperty("--progress", `${((questions.index + 1) / total) * 100}%`);
  questions.number.textContent = `السؤال ${arabicNumber(questions.index + 1)}`;
  questions.text.textContent = question.question;
  questions.previous.disabled = questions.index === 0;
  questions.next.disabled = questions.index === total - 1;
  questions.answerPanel.hidden = true;
  questions.answerToggle.setAttribute("aria-expanded", "false");
  questions.answerToggle.disabled = false;
  questions.surveyOptions.replaceChildren();
  questions.surveyResponse.textContent = "";

  const isSurvey = question.type === "poll";
  questions.answerToggle.hidden = isSurvey;
  questions.answerToggle.textContent = "أظهر الإجابة";
  questions.surveyPanel.hidden = !isSurvey;

  if (isSurvey) {
    question.choices.forEach((choice) => {
      const option = document.createElement("button");
      option.type = "button";
      option.className = "control-button survey-choice";
      option.textContent = choice;
      option.setAttribute("aria-pressed", "false");
      option.addEventListener("click", () => {
        questions.surveyOptions.querySelectorAll("button").forEach((button) => {
          button.setAttribute("aria-pressed", String(button === option));
        });
        questions.surveyResponse.textContent = `اخترت: ${choice}`;
      });
      questions.surveyOptions.append(option);
    });
  } else {
    questions.answerText.textContent = question.answer;
  }
}

fetch("content/presentation/questions.json")
  .then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  })
  .then((data) => {
    questions.items = data.groups.flatMap((group, groupIndex) =>
      group.questions.map((question) => ({
        ...question,
        group: groupIndex + 1,
        groupTitle: group.title,
      }))
    );
    if (!questions.items.length) throw new Error("No questions configured");
    questions.viewer.setAttribute("aria-busy", "false");
    renderQuestion();
  })
  .catch(() => {
    questions.topic.textContent = "تعذّر تحميل الأسئلة. حاول تحديث الصفحة.";
    questions.viewer.setAttribute("aria-busy", "false");
  });

questions.answerToggle.addEventListener("click", () => {
  const isRevealed = questions.answerPanel.hidden;
  questions.answerPanel.hidden = !isRevealed;
  questions.answerToggle.setAttribute("aria-expanded", String(isRevealed));
  questions.answerToggle.textContent = isRevealed ? "أخفِ الإجابة" : "أظهر الإجابة";
});

questions.previous.addEventListener("click", () => {
  questions.index -= 1;
  renderQuestion();
});

questions.next.addEventListener("click", () => {
  questions.index += 1;
  renderQuestion();
});

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
  readyPoll: null,
  hardTimeout: null,
};

function setGameStatus(text, state = "ready") {
  game.status.textContent = text;
  game.statusDot.className = state === "ready" ? "" : state;
}

function clearGameTimers() {
  window.clearTimeout(game.timeout);
  window.clearTimeout(game.hardTimeout);
  window.clearInterval(game.readyPoll);
  game.timeout = null;
  game.hardTimeout = null;
  game.readyPoll = null;
}

function markGameReady() {
  clearGameTimers();
  game.loading.hidden = true;
  game.error.hidden = true;
  setGameStatus("اللعبة تعمل", "ready");
  game.frame.focus();
}

function markGameFailed(message = "تعذّر تشغيل اللعبة. حاول مرة أخرى.") {
  clearGameTimers();
  game.loading.hidden = true;
  game.error.hidden = false;
  const description = game.error.querySelector("p");
  if (description) description.textContent = message;
  setGameStatus("خطأ في التحميل", "error");
}

function inspectGameFrame() {
  if (!game.started) return;
  try {
    const documentInsideFrame = game.frame.contentDocument;
    if (!documentInsideFrame) return;
    const failure = documentInsideFrame.querySelector("#status-notice")?.textContent.trim();
    if (failure) {
      markGameFailed(failure);
      return;
    }
    if (documentInsideFrame.querySelector("#canvas") && !documentInsideFrame.querySelector("#status")) {
      markGameReady();
    }
  } catch {
    // The local game is same-origin. Keep waiting if the frame is between navigations.
  }
}

function launchGame() {
  clearGameTimers();
  game.started = true;
  game.cover.hidden = true;
  game.error.hidden = true;
  game.loading.hidden = false;
  game.loading.querySelector("span").textContent = "جارٍ تحميل ملفات اللعبة الأصلية…";
  setGameStatus("جارٍ التحميل", "loading");
  game.frame.src = `${game.frame.dataset.src}?v=${Date.now()}`;

  game.readyPoll = window.setInterval(inspectGameFrame, 250);

  game.timeout = window.setTimeout(() => {
    if (!game.loading.hidden) {
      game.loading.querySelector("span").textContent = "ما زالت ملفات اللعبة الكبيرة قيد التحميل…";
    }
  }, 12000);

  game.hardTimeout = window.setTimeout(() => {
    markGameFailed("استغرق تحميل اللعبة وقتًا طويلًا. اضغط إعادة المحاولة.");
  }, 120000);
}

game.start.addEventListener("click", launchGame);
game.retry.addEventListener("click", launchGame);

game.frame.addEventListener("load", () => {
  if (!game.started) return;
  game.loading.querySelector("span").textContent = "جارٍ تشغيل محرك اللعبة…";
  inspectGameFrame();
});

game.frame.addEventListener("error", () => {
  markGameFailed();
});

game.fullscreen.addEventListener("click", () => {
  requestFullscreen(game.viewport);
  if (game.started) game.frame.focus();
});
