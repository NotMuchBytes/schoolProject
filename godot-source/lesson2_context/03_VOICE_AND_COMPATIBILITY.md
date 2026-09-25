# No-voice mode and preservation of previous work

## User decision
The recordings were intentionally moved OUTSIDE the project. Do not ask to regenerate them, copy them back, rename them or delete them. The player is always subtitle-only. For this development phase all other speakers are subtitle-only too, across both lessons.

Keep existing music, footsteps, interface sounds, wind/sea ambience and other non-speech sounds if their resources exist. “Without voices” does not mean a globally muted game.

## Required behavior
- Use one existing or new central speech-enabled flag, default OFF. Its exact project setting name is implementation-specific.
- Check that flag BEFORE resolving or loading any voice resource. No missing-voice warnings in intentional silent mode.
- Search actual `.gd`, `.tscn`, `.tres`, autoload and export dependencies for direct references into the removed `audio/final_voice` directory. A bus mute alone is not sufficient.
- Replace mandatory voice `preload` / scene external-resource references with optional mapping/path metadata. Preserve the map itself as strings; do not destroy the legacy ID mapping.
- When voices are re-enabled later, check that a recognized audio resource exists before loading. Missing file: subtitle fallback, at most one useful warning, never a fatal error.
- A narrative line finishes through explicit input or the cutscene's subtitle timing, NOT solely by awaiting an absent `AudioStreamPlayer.finished` signal.
- NPC conversation: retain existing manual Continue behavior. If typewriter reveal exists, first input may reveal all text, then next advances. Do not consume a press to “skip audio” when no audio is playing. Debounce held input so one press does not skip multiple lines.
- Silent cutscenes: give each caption a configurable minimum reading duration, with Continue/Skip support consistent with current UI. A draft starting heuristic is about 2.5 Arabic words/second with a minimum 3 s; playtest and adjust. Do not treat this as a measured reading standard.
- Skip/close/restart/change-scene must cancel callbacks/tweens, release player/camera locks exactly once, restore ambience mix and release any ambient conversation slot.
- NPC gestures follow dialogue state/timing while silent. No mouth/amplitude code should require an active audio stream.
- Quiet ambient NPC exchanges may keep nearby short subtitles and gestures on controlled cooldowns; prevent label spam.
- No fake empty audio files, no live speech APIs, no automatic audio generation, and no waiting for nonexistent clip lengths.

## Why explicit completion matters
Godot 4.7 documents that `AudioStreamPlayer.finished` is not emitted for `stop()` or for leaving the tree mid-playback. Handle these outcomes explicitly instead of assuming stop means finished. `ResourceLoader.exists()` can be used before optional loading; its cache behavior does not repair missing hard scene/preload references.

Technical references (official Godot documentation, consulted for this pack):
- https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer.html#signals
- https://docs.godotengine.org/en/4.7/classes/class_resourceloader.html#class-resourceloader-method-exists

Inspect the locally installed project version rather than upgrading it to match a web page.

## Existing recordings: do not discard
Old user filenames were renumbered per speaker, and do not always equal the game's original line IDs. `legacy_lesson1_voice_mapping.json` preserves this relationship using the uploaded original VOICE_SCRIPT and the subsequent naming decisions. It is a mapping reference, NOT confirmation of current local files or audio contents.

There are 65 expected old non-player recordings and six intentionally silent player lines in that reference. Some old folders used short names such as `temple` while the logical speaker was `temple_recipient`.

Keep old dialogue text/IDs unchanged wherever possible. If a small transition needs new words, create a new stable line ID instead of replacing an existing line. If a genuine necessary rewrite is proposed, record old text, proposed text, reason and affected clip in `VOICE_CHANGELOG_LESSON2.md`; do not delete the clip.

No recording is recommended for deletion at this stage. Reusability should be decided after the revised story is approved, not guessed before implementation.

## New lesson speech metadata
For each new line keep:
- stable `line_id` and `speaker_id`;
- exact final Arabic subtitle text;
- optional `audio_path` initially empty;
- `voice_status = deferred_not_recorded`;
- context, gesture and source fact IDs;
- a text version/hash when exporting the future voice script.

Never attach a reused recording to different words merely because the voice sounds suitable. Prefix new IDs with `l2_` and never renumber them when inserting a line.

After implementation, export a separate `VOICE_SCRIPT_LESSON2.md` (and machine-readable JSON) reflecting the actual final runtime text, not an untouched draft. Do not overwrite the Lesson 1 VOICE_SCRIPT/VOICE_MANIFEST. Generation of new audio comes only after the user approves both lessons.
