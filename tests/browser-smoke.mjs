import { spawn } from "node:child_process";
import fs from "node:fs/promises";
import net from "node:net";
import os from "node:os";
import path from "node:path";

const EDGE = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";
const SITE = "http://127.0.0.1:8000";

const delay = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

async function freePort() {
  const server = net.createServer();
  await new Promise((resolve, reject) => server.listen(0, "127.0.0.1", resolve).once("error", reject));
  const { port } = server.address();
  await new Promise((resolve) => server.close(resolve));
  return port;
}

async function pollJson(url, timeout = 15000) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url);
      if (response.ok) return response.json();
    } catch {}
    await delay(150);
  }
  throw new Error(`Timed out waiting for ${url}`);
}

const port = await freePort();
const profile = await fs.mkdtemp(path.join(os.tmpdir(), "ancient-greece-browser-test-"));
const browser = spawn(
  EDGE,
  [
    "--headless=new",
    "--no-first-run",
    "--disable-sync",
    "--disable-background-mode",
    "--enable-unsafe-swiftshader",
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profile}`,
    "about:blank",
  ],
  { stdio: "ignore", windowsHide: true }
);

let socket;
try {
  await pollJson(`http://127.0.0.1:${port}/json/version`);
  const targetResponse = await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(SITE)}`, {
    method: "PUT",
  });
  const target = await targetResponse.json();
  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    socket.addEventListener("open", resolve, { once: true });
    socket.addEventListener("error", reject, { once: true });
  });

  let commandId = 0;
  const pending = new Map();
  const errors = [];

  socket.addEventListener("message", ({ data }) => {
    const message = JSON.parse(data);
    if (message.id && pending.has(message.id)) {
      const { resolve, reject } = pending.get(message.id);
      pending.delete(message.id);
      return message.error ? reject(new Error(message.error.message)) : resolve(message.result);
    }
    if (message.method === "Runtime.exceptionThrown") {
      errors.push(
        message.params.exceptionDetails.exception?.description ||
        message.params.exceptionDetails.text
      );
    }
    if (message.method === "Log.entryAdded" && message.params.entry.level === "error") {
      errors.push(`${message.params.entry.source}: ${message.params.entry.text}`);
    }
  });

  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++commandId;
    pending.set(id, { resolve, reject });
    socket.send(JSON.stringify({ id, method, params }));
  });

  const evaluate = async (expression) => {
    const result = await send("Runtime.evaluate", {
      expression,
      awaitPromise: true,
      returnByValue: true,
    });
    if (result.exceptionDetails) throw new Error(result.exceptionDetails.text);
    return result.result.value;
  };

  const waitFor = async (expression, timeout = 15000) => {
    const deadline = Date.now() + timeout;
    while (Date.now() < deadline) {
      if (await evaluate(expression)) return true;
      await delay(200);
    }
    return false;
  };

  const clickElement = async (selector) => {
    await evaluate(`document.querySelector(${JSON.stringify(selector)})?.scrollIntoView({ block: 'center' })`);
    await delay(150);
    const point = await evaluate(`(() => {
      const rect = document.querySelector(${JSON.stringify(selector)})?.getBoundingClientRect();
      return rect ? { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 } : null;
    })()`);
    if (!point) throw new Error(`Cannot click missing element: ${selector}`);
    await send("Input.dispatchMouseEvent", { type: "mousePressed", x: point.x, y: point.y, button: "left", clickCount: 1 });
    await send("Input.dispatchMouseEvent", { type: "mouseReleased", x: point.x, y: point.y, button: "left", clickCount: 1 });
  };

  await Promise.all([
    send("Page.enable"),
    send("Runtime.enable"),
    send("Log.enable"),
  ]);

  await send("Emulation.setDeviceMetricsOverride", {
    width: 1440,
    height: 900,
    deviceScaleFactor: 1,
    mobile: false,
  });
  await send("Page.navigate", { url: SITE });
  await waitFor("document.readyState === 'complete'");
  await waitFor("document.querySelector('#slideImage')?.classList.contains('loaded')");

  const desktop = await evaluate(`(() => ({
    direction: document.documentElement.dir,
    language: document.documentElement.lang,
    slideCounter: document.querySelector('#slideCounter')?.textContent.trim(),
    slideLoaded: document.querySelector('#slideImage')?.naturalWidth > 0,
    gameIsLazy: !document.querySelector('#gameFrame')?.getAttribute('src'),
    noHorizontalOverflow: document.documentElement.scrollWidth <= document.documentElement.clientWidth,
    heroTitle: document.querySelector('#hero-title')?.innerText.replace(/\\n/g, ' '),
    teamNames: document.querySelector('.team-names')?.textContent.trim(),
    rootBackground: getComputedStyle(document.documentElement).backgroundColor,
    rootOverscroll: getComputedStyle(document.documentElement).overscrollBehaviorY,
    bodyOverscroll: getComputedStyle(document.body).overscrollBehaviorY,
  }))()`);

  await evaluate("document.querySelector('#nextSlide').click()");
  await waitFor("document.querySelector('#slideCounter')?.textContent.trim() === '2 / 3'");
  await waitFor("document.querySelector('#slideImage')?.classList.contains('loaded') && document.querySelector('#slideImage')?.naturalWidth > 0");
  const controls = await evaluate(`(() => ({
    afterNext: document.querySelector('#slideCounter')?.textContent.trim(),
    imageLoaded: document.querySelector('#slideImage')?.naturalWidth > 0,
    previousEnabled: !document.querySelector('#previousSlide')?.disabled,
  }))()`);

  const fullscreenApi = await evaluate("document.fullscreenEnabled && typeof HTMLElement.prototype.requestFullscreen === 'function'");

  await send("Emulation.setDeviceMetricsOverride", {
    width: 390,
    height: 844,
    deviceScaleFactor: 1,
    mobile: true,
  });
  await delay(300);
  const mobile = await evaluate(`(() => ({
    width: document.documentElement.clientWidth,
    noHorizontalOverflow: document.documentElement.scrollWidth <= document.documentElement.clientWidth,
    heroVisible: document.querySelector('#hero-title')?.getBoundingClientRect().width > 0,
    gameAspectRatio: getComputedStyle(document.querySelector('#gameViewport')).aspectRatio,
  }))()`);

  await send("Emulation.setDeviceMetricsOverride", {
    width: 1280,
    height: 720,
    deviceScaleFactor: 1,
    mobile: false,
  });
  await evaluate("document.querySelector('#startGame').click()");
  const gameEntryLoaded = await waitFor(
    "document.querySelector('#gameFrame')?.contentDocument?.querySelector('#canvas') !== null",
    20000
  );
  await waitFor(
    `(() => {
      const doc = document.querySelector('#gameFrame')?.contentDocument;
      return doc && (!doc.querySelector('#status') || doc.querySelector('#status-notice')?.textContent.trim().length > 0);
    })()`,
    120000
  );
  const game = await evaluate(`(() => {
    const frame = document.querySelector('#gameFrame');
    const doc = frame?.contentDocument;
    return {
      entryLoaded: ${gameEntryLoaded},
      statusText: document.querySelector('#gameStatus')?.textContent.trim(),
      canvasPresent: Boolean(doc?.querySelector('#canvas')),
      engineReady: Boolean(doc && !doc.querySelector('#status')),
      engineFailure: doc?.querySelector('#status-notice')?.textContent.trim() || '',
      frameFocused: document.activeElement === frame,
    };
  })()`);
  await clickElement("#gameFrame");
  const pointerLock = await waitFor(
    "Boolean(document.querySelector('#gameFrame')?.contentDocument?.pointerLockElement)",
    3000
  );
  await send("Input.dispatchKeyEvent", { type: "keyDown", key: "w", code: "KeyW", windowsVirtualKeyCode: 87 });
  await send("Input.dispatchKeyEvent", { type: "keyUp", key: "w", code: "KeyW", windowsVirtualKeyCode: 87 });
  game.pointerLockAfterClick = pointerLock;
  game.keyboardInputDispatched = true;

  const fullscreen = await evaluate(`({
    apiAvailable: ${fullscreenApi},
    presentationControl: Boolean(document.querySelector('#presentationFullscreen')),
    gameControl: Boolean(document.querySelector('#gameFullscreen')),
  })`);
  const expectedHeadlessWarnings = errors.filter((error) => error.includes("Pointer Lock"));
  const unexpectedConsoleErrors = errors.filter((error) => !error.includes("Pointer Lock"));
  const result = { desktop, controls, mobile, game, fullscreen, expectedHeadlessWarnings, unexpectedConsoleErrors };
  console.log(JSON.stringify(result, null, 2));

  const passed =
    desktop.direction === "rtl" &&
    desktop.language === "ar" &&
    desktop.slideCounter === "1 / 3" &&
    desktop.slideLoaded &&
    desktop.gameIsLazy &&
    desktop.noHorizontalOverflow &&
    desktop.teamNames.startsWith("عمر") &&
    desktop.rootBackground === "rgb(8, 15, 31)" &&
    desktop.rootOverscroll === "none" &&
    desktop.bodyOverscroll === "none" &&
    controls.afterNext === "2 / 3" &&
    controls.imageLoaded &&
    controls.previousEnabled &&
    mobile.noHorizontalOverflow &&
    mobile.heroVisible &&
    game.entryLoaded &&
    game.canvasPresent &&
    game.engineReady &&
    !game.engineFailure &&
    game.keyboardInputDispatched &&
    fullscreen.apiAvailable &&
    fullscreen.presentationControl &&
    fullscreen.gameControl &&
    unexpectedConsoleErrors.length === 0;

  if (!passed) process.exitCode = 1;
} finally {
  if (socket?.readyState === WebSocket.OPEN) socket.close();
  browser.kill();
  const expectedPrefix = path.join(os.tmpdir(), "ancient-greece-browser-test-");
  if (profile.startsWith(expectedPrefix)) {
    await delay(250);
    await fs.rm(profile, { recursive: true, force: true, maxRetries: 4, retryDelay: 150 });
  }
}
