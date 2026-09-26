# Ancient Greece Arabic lesson website

A responsive, single-page Arabic lesson experience with an embedded Godot Web game and an interactive question review.

## Run locally

Python 3 is the only requirement:

```powershell
python server.py
```

Then open <http://127.0.0.1:8000>. Do not open `index.html` directly with a `file://` URL; browsers block the WebAssembly and presentation requests in that mode.

`server.py` sets COOP/COEP and correct WebAssembly/PCK content types. The current export has Godot threads disabled, but the isolation headers also support a future threaded export.

## Godot game

The rebuilt Arabic web export is in `games/ancient-greece/`. The game appears above the presentation viewer and is embedded in a lazy-loaded iframe, so the browser downloads it only after the learner chooses **ابدأ اللعبة**.

This build includes the required colored textures, a visible third-person player, browser-tuned lighting, and the lesson's runtime assets. Its PCK is about 46 MB. A bundled Noto Sans Arabic font and Arabic theme are applied to menus, dialogue, HUD controls, and 3D labels.

Editable Godot source and the `Web Optimized` export preset are in `godot-source/`. The generated `.godot` cache and temporary `godot-build/` output are ignored by Git.

To rebuild or replace the game:

1. Open `godot-source/project.godot` in Godot 4.7.2 with Web export templates installed.
2. Export the `Web Optimized` preset with the basename `ancient-greece-rebuilt`.
3. Copy every generated `ancient-greece-rebuilt.*` runtime file into `games/ancient-greece/`.
4. Keep all generated files together and preserve their relative paths.
5. Run `python server.py` and test loading, Arabic text, controls, audio, and fullscreen.

## Question review and PowerPoint

The website reads questions from `content/presentation/questions.json`. The same source generates the downloadable Arabic PowerPoint:

```powershell
python tools/build_questions_pptx.py
```

The generated file is `content/presentation/ancient-greece-questions.pptx`.

## Deployment

Deploy the repository root to a static server that:

- serves `.wasm` as `application/wasm` and `.pck` as `application/octet-stream`;
- can send COOP/COEP headers if a future game export enables threads.

Do not rename the PCK, WASM, or JavaScript independently of the generated HTML configuration.

## Project layout

```text
index.html
css/styles.css
js/app.js
assets/parthenon-reference.png
content/presentation/
games/ancient-greece/
godot-source/
server.py
tests/
```
