# Acceptance tests — report actual results, not assumed success

## Baseline / preservation
[ ] Existing project version and paths inspected; no engine migration or replacement project.
[ ] Old chapter, approved maps, art, subtitles, IDs and old voice mapping remain.
[ ] Backup/change list recorded before edits; no destructive deletion of external audio.

## Entire recorded-voice folder absent
[ ] Editor loads and a fresh import can finish with the voice folder absent.
[ ] No mandatory `.tscn` / `.tres` / preload reference still requires a removed voice file.
[ ] All Lesson 1 conversations, map cutscenes and ending can finish without a voice stream.
[ ] All Lesson 2 conversations/activities can finish without a voice stream.
[ ] Player remains subtitle-only and is not reported as an audio error.
[ ] Voice-disabled mode does not spam missing-file logs or use substitute speech.
[ ] Continue/Skip/Pause/Resume/restart/scene changes never leave player control or camera locked.
[ ] No waiting for audio finished on stopped, missing, or never-started streams.
[ ] Music, effects and world ambience still work independently where their files exist.
[ ] Closing an ambient exchange releases its cooldown/slot even with no audio.

## Source coverage (mark where each is exposed)
[ ] Politics: monarchy, Athens/democracy, Sparta/military, despotic rule and influence of political thought.
[ ] Agriculture: three crops, causes, mills/presses, livestock.
[ ] Industry: all Figure 4 causes including Phoenician competition; source product examples.
[ ] Trade: internal vs external and all causes.
[ ] Society: settlement sequence, exact four-class ordering, attributed citizenship and women's rights text.
[ ] Religion: beliefs about nature, images/statues/temples, Zeus/Apollo/Athena source roles.
[ ] Theatre: connection to rituals/agriculture, tragedy/comedy, four named elements.
[ ] Philosophy/history: Plato, Aristotle and relationships/works, Herodotus including source treatment of myths.
[ ] Architecture: all Figure 6 city characteristics implemented/shown; marble/bronze and sculpture subjects.
[ ] Sports: source examples, participation/audience and Olympic attribution, no outside historical additions.
[ ] Jordan: 332 BCE, Ptolemy, Rabbath Ammon/300 BCE/later Philadelphia, all four source city pairs, Qasr al-Abd and inset, decline/Pompey transition.
[ ] Review mirrors pp.17 themes; outside-research activities not silently fabricated.
[ ] Every factual draft line resolves to a valid source fact/page; fictional tasks are tagged separately.

## Gameplay and presentation
[ ] Lesson 1 → Lesson 2 → complete → menu transition works.
[ ] Direct chapter selection works; replay resets correct chapter state.
[ ] Economy has at least one object/route interaction, not only dialogue.
[ ] Theatre has two distinguishable endings and inspectable theatre elements.
[ ] Sports activity can be completed with an accessible no-failure alternative.
[ ] Wrong matching answers have a hint/retry, no permanent progression lock.
[ ] Player always has a clear Arabic objective and navigable next destination.
[ ] All source topics remain reachable even if an optional cinematic is skipped.
[ ] NPCs face interlocutors, animate while subtitle dialogue is active, and resume behavior afterward.
[ ] Collisions on stairs, roads, walls and level edges are safe; fall respawn retained.
[ ] No visible void from gameplay, dialogue cameras or viewpoints.
[ ] Source religious beliefs are not turned into factual magic; social deprivation is not a reward mechanic.
[ ] Arabic shaping, RTL, wrapping and mixed numerals checked at 1280×720 and a larger window.
[ ] No new paid assets, web runtime dependencies or live TTS.
[ ] Actual added playtime measured or explicitly listed as not yet measured.

## Future voices (not generated in this task)
[ ] Stable new IDs and exact final runtime text exported separately for Lesson 2.
[ ] Old audio mapping preserved and changed old lines, if any, documented rather than silently overwritten.
[ ] Re-enabling voice later with one existing file uses that file; absent optional files retain subtitle fallback.
[ ] No file deletion or renumbering requested as a prerequisite for this expansion.

## Final response from Codex
State: implemented stages; source coverage file; voice disabled confirmation; actual commands/tests run; manual tests still needed; known asset/performance limitations. Do not equate syntax checks with a full human playthrough.
