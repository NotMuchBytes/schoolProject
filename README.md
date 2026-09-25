# Ancient Greece Arabic lesson website

A responsive, single-page Arabic lesson experience with an image-based presentation viewer and an embedded Godot Web game.

## Run locally

Python 3 is the only requirement:

```powershell
python server.py
```

Then open <http://127.0.0.1:8000>. Do not open `index.html` directly with a `file://` URL; browsers block the WebAssembly and presentation requests in that mode.

`server.py` sets COOP/COEP and correct WebAssembly/PCK content types. The current export has Godot threads disabled, but the isolation headers also support a future threaded export.

## Godot game

The optimized web export is in `games/ancient-greece/`. Its entry page is embedded in a lazy-loaded iframe, so the browser downloads the game only after the learner chooses **ابدأ اللعبة**.

The rebuild uses Godot's Compatibility renderer, a 67% adaptive 3D render scale, reduced shadow/post-processing costs, and an asset-filtered export. The PCK is now about 35 MB instead of about 455 MB, while the complete runtime is about 75 MB. A bundled Noto Sans Arabic font is applied to menus, dialogue, HUD controls, and 3D labels.

Editable Godot source and the `Web Optimized` export preset are in `godot-source/`. The generated `.godot` cache and temporary `godot-build/` output are ignored by Git.

To rebuild or replace the game:

1. Open `godot-source/project.godot` in Godot 4.7.2 with Web export templates installed.
2. Export the `Web Optimized` preset with the basename `ancient-greece`.
3. Copy the generated runtime files into `games/ancient-greece/` and copy the generated HTML to `index.html` there.
4. Keep all generated files together and preserve their relative paths.
5. Run `python server.py` and test loading, Arabic text, controls, audio, and fullscreen.

## Presentation / PPTX workflow

Raw PPTX files are not embedded because browsers cannot render them consistently. The presentation viewer reads `content/presentation/manifest.json` and displays web-compatible slide images from `content/presentation/slides/`.

When the PowerPoint is ready:

1. Export every slide from PowerPoint as PNG or JPG.
2. Put the images in `content/presentation/slides/`.
3. Replace the placeholder entries in `content/presentation/manifest.json` with the filenames in slide order.

See `content/presentation/README.md` for an example manifest. The viewer includes previous/next buttons, slide numbering, arrow-key navigation, responsive scaling, and fullscreen.

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
