import { spawn } from "node:child_process";
import fs from "node:fs/promises";
import net from "node:net";
import os from "node:os";
import path from "node:path";

const EDGE = "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";
const URL = process.env.GAME_URL || "http://127.0.0.1:8000/games/ancient-greece/index.html";
const SCREENSHOT = process.env.GAME_SCREENSHOT;
const START_GAME = process.env.GAME_START === "1";
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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
const profile = await fs.mkdtemp(path.join(os.tmpdir(), "godot-build-test-"));
const browser = spawn(EDGE, [
  "--headless=new", "--no-first-run", "--disable-sync", "--disable-background-mode",
  "--enable-unsafe-swiftshader", `--remote-debugging-port=${port}`,
  `--user-data-dir=${profile}`, "about:blank",
], { stdio: "ignore", windowsHide: true });

let socket;
try {
  await pollJson(`http://127.0.0.1:${port}/json/version`);
  const response = await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(URL)}`, { method: "PUT" });
  const target = await response.json();
  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    socket.addEventListener("open", resolve, { once: true });
    socket.addEventListener("error", reject, { once: true });
  });

  let id = 0;
  const pending = new Map();
  const errors = [];
  socket.addEventListener("message", ({ data }) => {
    const message = JSON.parse(data);
    if (message.id && pending.has(message.id)) {
      const callback = pending.get(message.id);
      pending.delete(message.id);
      return message.error ? callback.reject(new Error(message.error.message)) : callback.resolve(message.result);
    }
    if (message.method === "Runtime.exceptionThrown") {
      errors.push(message.params.exceptionDetails.exception?.description || message.params.exceptionDetails.text);
    }
    if (message.method === "Log.entryAdded" && message.params.entry.level === "error") {
      errors.push(message.params.entry.text);
    }
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const commandId = ++id;
    pending.set(commandId, { resolve, reject });
    socket.send(JSON.stringify({ id: commandId, method, params }));
  });
  const evaluate = async (expression) => {
    const result = await send("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true });
    return result.result.value;
  };

  await Promise.all([send("Page.enable"), send("Runtime.enable"), send("Log.enable")]);
  await send("Emulation.setDeviceMetricsOverride", { width: 1280, height: 720, deviceScaleFactor: 1, mobile: false });
  await send("Page.navigate", { url: URL });
  const deadline = Date.now() + 120000;
  let ready = false;
  while (Date.now() < deadline) {
    ready = await evaluate("Boolean(document.querySelector('#canvas')) && !document.querySelector('#status')");
    if (ready) break;
    await delay(250);
  }
  await delay(3000);
  if (START_GAME && ready) {
    await send("Input.dispatchKeyEvent", { type: "keyDown", key: "Enter", code: "Enter", windowsVirtualKeyCode: 13 });
    await send("Input.dispatchKeyEvent", { type: "keyUp", key: "Enter", code: "Enter", windowsVirtualKeyCode: 13 });
    await delay(12000);
  }
  const state = await evaluate(`({
    title: document.title,
    canvas: Boolean(document.querySelector('#canvas')),
    ready: !document.querySelector('#status'),
    failure: document.querySelector('#status-notice')?.textContent.trim() || ''
  })`);
  if (SCREENSHOT) {
    const capture = await send("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
    await fs.writeFile(SCREENSHOT, Buffer.from(capture.data, "base64"));
  }
  console.log(JSON.stringify({ url: URL, startedGame: START_GAME, ...state, errors }, null, 2));
  if (!ready || state.failure || errors.length) process.exitCode = 1;
} finally {
  if (socket?.readyState === WebSocket.OPEN) socket.close();
  browser.kill();
  await delay(250);
  await fs.rm(profile, { recursive: true, force: true, maxRetries: 4, retryDelay: 150 });
}
