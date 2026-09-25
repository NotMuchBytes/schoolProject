# Playable plan — الحياة العامة في الحضارة اليونانية

## Narrative frame
After the existing Lesson 1 epilogue, offer «متابعة إلى الدرس الثاني» and «العودة إلى القائمة». Keep the epilogue and its old subtitles intact; do not overwrite the approved campaign map.

Use the current record/tablet/storybook motif. The narrator explains that we are opening a new record about life across different periods. This is a thematic return, NOT a claim that all civic life starts after Alexander's death. Do not make the same ordinary messenger literally live across centuries. The player's role is an explorer of the record; no new time-travel system is needed.

Chapter title: «الحياة العامة في الحضارة اليونانية».
Task framing: help a fictional guide prepare «سجل الحياة العامة». Each meaningful activity adds a page/tab to the record, rather than a generic fetch quest. No mandatory knowledge quiz before entering the city.

## Build on the current world
Reuse approved buildings, terrain, crowd rigs, market, temple, UI and camera conventions. Expand a coherent city district with residential streets, civic square, a short route to agricultural/workshop/harbour areas, a theatre, library/exhibit space and exercise yard.

The source's Figure 6 explicitly motivates walls, an ordered street/building layout and a central public square with temple and theatre. Show these in the world. Put non-playable rooftops, streets and terrain beyond the main route; hide edges naturally. No visible void, floating platforms or isolated slabs.

Use existing project architecture. Suggested names below are concepts, not demands to replace existing classes. Add only the reusable activity support that current code actually lacks.

## Required route and estimated active-play time
| Stage | Place and action | Outcome / condition | Source coverage | Target |
|---|---|---|---|---|
|0|Record opening and chapter transition|Player receives control in the city; «ابدأ سجل الحياة العامة»|Framing only|20–30 s|
|1 Politics|Civic guide, four descriptive system cards: monarchy, Athens/democracy, Sparta/military, despotic rule|Compare/match descriptions; retry without punishment; «قارن أنظمة الحكم»|POL01–04|~60 s|
|2 Economy|Trace grain/olives/grapes from an agricultural display to workshop, local market and harbour|Inspect 3 crops, one industry example, classify local vs external destination; «تتبّع طريق المنتجات إلى السوق»|ECO01, AGR01–02, IND01–02, TRA01–02|2–3 min|
|3 Society|Scribe's household/civic courtyard exhibit|Arrange 4 class cards; open rights card; «تعرّف إلى المجتمع وحقوقه»|SOC01–04|~60–75 s|
|4 Religion|Temple exhibits with guide|Inspect belief/statue/temple connections; no worship task or magic; «استكشف المعبد»|REL01–02|~45–60 s|
|5 Theatre|Semi-circular theatre, staged rehearsal|Highlight 4 elements; watch one sad and one happy fictional ending; select labels; «ساعد في عرض المشهدين»|CUL01, THR01–03|~90–120 s|
|6 Ideas|Library/scroll exhibition staffed by fictional guide|Match Plato, Aristotle, Herodotus to source-supplied books/descriptions; «رتّب بطاقات المفكرين»|PHI01–02, HIS01; observe PHI03 source limit|~60–90 s|
|7 Architecture|Viewpoint and sculptor exhibit|Identify walls/square/ordered buildings in actual city; inspect marble/bronze; «تأمل بناء المدينة»|ARC01–03|~45–60 s|
|8 Sport|Training yard integrated into city|Run a short checkpoint course; offer an accessible walkthrough/skip equivalent; inspect sport list; «شارك في تدريب الجري»|SPT01–02|~60 s|
|9 Jordan + ending|Archive transition or small coherent heritage vignette|Read simple timeline; match modern/source city names; inspect Qasr al-Abd reference; finish record|JOR01–07|~90–120 s|

Time targets overlap with movement/dialogue. Measure actual playtest duration; avoid forced waits. The entire required extension targets about 10–15 minutes.

## Stage design details
### 1 — Politics
Use the four terms from the text, not a newly researched political taxonomy. The comparison task is a fictional educational exhibit, not a reenactment of a documented vote. Do not claim all residents could vote. Preserve source attribution for Athens's “first” framing in the study card.

### 2 — Economy as a connected task
Use direct interaction flags or a tiny one-item carry state, not an RPG inventory. A grain sack, olive jar and grape basket may be task props; the specific delivery job is fictional. Show mills/presses if available or via a clear exhibit. Display sheep/cattle information without requiring new animal AI.

At the workshop, expose all three industrial causes from Figure 4 and the source industry list. No weapons manufacturing mechanic or combat is needed. At the harbour, distinguish domestic and external trade. A schematic flow diagram is acceptable; do not invent precise shipping routes or geography not in the textbook.

### 3 — Society without harmful or unsupported role-play
The class pyramid is a document/exhibit, not NPC “value ranks.” Use the four source labels in order. The rights text stays in an attributed study panel: «بحسب الدرس…». Represent people respectfully; no buying/selling enslaved people, no humiliation quest, and no fabricated universal claims about rights across every Greek city/time.

### 4 — Religious history
Present Zeus/Apollo/Athena as beliefs described by the lesson. Do not add divine interventions, spells or required religious participation. Reuse an existing temple and neutral exhibit labels. Keep mythology explanations within source scope.

### 5 — Theatre that is actually playable
Reuse existing gestures and two actors. The user can activate a rehearsal cue, watch a short staged ending and identify the tone. The two little stories in the dialogue JSON are original illustrative fiction, NOT quotations from a historical play.

Make الجوقة، الأوركسترا، خشبة المسرح، الممثلون visible with brief labels/spotlights. Do not substitute a modern concert orchestra. A good static shot and gestures are sufficient when advanced acting animations are unavailable. No voice or lip-sync requirement.

### 6 — Thinkers without invented meetings
Plato, Aristotle and Herodotus are subjects of scroll/exhibit cards, not a group of living contemporaries in a single invented scene. Use the supplied relationships and works; do not create fake quotations. Socrates appears only in the source margin and has no supplied biography.

### 7 — Architecture and sculpture
Use the city itself as evidence. A viewpoint can highlight the wall, square, temple and theatre already visible. Sculpture display should mention marble/bronze and the subjects given. Avoid claiming exact archaeological reconstruction from one photo.

### 8 — Sports
Use the existing movement controller for a simple run. No new horse/swimming/wrestling/weapon systems. Other sports are shown in cards or existing safe animations. Avoid modern sports logos or equipment. The Olympic explanation follows the source only; the research task about the name is not supplied content.

### 9 — Jordan
Reuse the record frame to signal a change of place and time. Do not extend the eastward Alexander map with invented contemporary borders/coordinates. Prefer a short source-bound timeline + city-name matching + compact heritage diorama, at existing visual quality.

Required source points: 332 BCE connection, Ptolemaic succession, Rabbath Ammon/Amman and 300 BCE as in the lesson, later Philadelphia name/Ptolemy Philadelphus; Pella/Gadara/Gerasa/Heshbon source spellings; wars/natural disasters; Qasr Iraq al-Amir/Qasr al-Abd with the inset's 2nd-century-BCE date and location details; concluding Pompey/Roman transition. Keep these as the textbook account, not an independently verified exact chronology.

The full source paragraph is available for broad or simplified claims. Do not silently replace it with online history. Do not claim a modeled palace is exact. Source photos are references only unless the user explicitly approves runtime use.

## NPCs and animation
Use fictional reusable roles: guide, civic guide, farmer, artisan, merchant, scribe, temple guide, theatre director/actors, library guide, architect, coach, heritage guide. Reuse rigs and wardrobe variants. Only a modest visible set of ambient NPCs needs to run concurrently.

Use existing walk/idle/talk/listen/point gestures. Walk on valid navigation routes, face the listener, pause roaming during interactions and resume afterward. Animation is driven by dialogue state in silent mode, not audio amplitude.

Do not automatically upgrade/rebuild existing character models or import new paid packs. Report a missing visual category rather than quietly dropping quality back to capsules and primitive barrels.

## Optional study record
A compact «سجل التعلم» organized in textbook order contains the source facts and page numbers. Required interactions expose key facts; optional cards hold detailed lists and broad attributed textbook statements. Add a «مراجعة» tab reflecting p.17 with non-punitive feedback, but do not replace the adventure with a sequence of quizzes.

Trojan Horse research and external Olympic-name research are not included in the provided lesson content. Do not add those plots or browse for them in this task.

## Technical integration order
1. Inspect actual repository and current tests; take a reversible backup of changed files outside runtime-imported areas. Do not assume Git is installed.
2. Implement no-voice operation for BOTH lessons and validate the old flow with the final_voice folder absent.
3. Add chapter routing with menu labels «الدرس الأول»، «الدرس الثاني». Preserve old IDs, audio mappings and source files. Allow direct Lesson 2 testing without replaying Lesson 1.
4. Create the connected route and all stage completion flags before adding optional detail.
5. Implement stages incrementally; keep each checkpoint playable. Store final approved new runtime data in a real project data folder, not in this ignored context directory.
6. Use stable `l2_*` line/quest/speaker IDs. A lightweight state structure or existing save mechanism is enough; no elaborate new framework. Ensure a “restart Lesson 2” clears only Lesson 2 progress.
7. Implement the ending, replay/menu return, then test the entire old+new game.

## Constraints
No combat, paid tools, live TTS, API keys, new cloud services, voice generation, external asset scavenging or giant new open world. Do not overwrite the historical map, original voice transcript or old voice manifest. Dialogue JSON contains factual adaptations and explicitly tagged fictional tasks; only invent minimal extra connective lines, not new history.

## Finish by reporting
List changed files, playable chapter entry, implemented/remaining stages, source coverage, voice-disabled behavior and actual tests run. An import/parser check is NOT a visual or full gameplay test. Tell the user exactly what still needs manual testing; do not claim completion of unrun tests.
