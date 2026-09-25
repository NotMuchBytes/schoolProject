# History3DGame — Lesson 2 extension context

## User-approved direction
- Extend the existing Godot third-person history game with the second textbook lesson.
- Existing art quality, map presentation, characters, camera and working Lesson 1 are approved. Preserve them.
- Explain work to the user in English. All player-facing story, instructions, labels and subtitles are Arabic with RTL.
- Use existing/free assets and installed tools only. No paid plugins, cloud calls, accounts, TTS or replacement engine.
- The user moved the recorded voice folder out of the project. **Both lessons must work without any voice recordings.** Do not request it back now.
- The player remains unvoiced. NPCs and narrator are also subtitle-only during this phase. Keep non-voice music and sound effects if available.
- Do NOT delete old recordings, erase audio systems, or rewrite old dialogue just to support this extension.

## Read in this order
1. `01_TEXTBOOK_CONTEXT.md` — source facts and page references.
2. `02_GAMEPLAY_AND_IMPLEMENTATION.md` — complete route, content coverage and staged implementation.
3. `03_VOICE_AND_COMPATIBILITY.md` — absent-file-safe subtitle mode and legacy recording protection.
4. `lesson2_dialogue_draft.json` — stable new Arabic line IDs, source IDs and fictional framing.
5. `04_ACCEPTANCE_TESTS.md` — tests that define completion.
6. Inspect `sources/` page images for diagrams, names and dates.

## What this pack is / is not
This is a design and source-context pack, not an already-built Godot expansion. The assistant has not accessed or run the user's local game. Inspect the actual repository before changing code. Do not assume old assistant scene names, counts, or claimed test results reflect the current project.

`lesson2_dialogue_draft.json` is an interchange draft, not a promised drop-in Godot API. Adapt its schema to the current dialogue system without changing its stable line IDs. Copy any needed runtime data into the actual project data directories; this context folder is development-only.

The source extract contains printed pp. 12–17, preserving the original scans. Historical facts come only from those pages. New fictional characters, tasks and connective lines are explicitly adaptation material.

## Scope and pacing proposal
Keep Lesson 1 at its current pace. Add roughly 10–15 minutes of required Lesson 2 play; total is approximately 20–30 minutes if Lesson 1 still lasts 10–15. These are design targets, not measured playtime. Optional study cards can extend reading time. Do not force the entire expanded game into the old runtime by omitting textbook topics.

Build one compact, continuous city district by extending/reusing approved scenes, plus a compact Jordan heritage vignette or archive presentation. Do not build nine disconnected empty maps.

## Implementation priorities
P0: inspect/back up → remove mandatory voice-file dependencies → prove Lesson 1 works silent.
P1: add chapter routing and a working end-to-end Lesson 2 shell.
P2: implement the economy/theatre/athletics interactions and all lesson coverage at current visual quality.
P3: test source fidelity, no-voice progression, chapter transitions and regressions.

No promise of flawless results is implied. Report what was actually executed and what needs a human playtest.
