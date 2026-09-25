extends SceneTree

const INPUT_PATH := "res://data/lesson2_dialogue.json"
const OUTPUT_PATH := "res://audio/VOICE_SCRIPT_LESSON2.md"
const VoiceManifest := preload("res://scripts/story/lesson2_voice_manifest.gd")


func _initialize() -> void:
	var source := FileAccess.open(INPUT_PATH, FileAccess.READ)
	if source == null:
		push_error("Cannot read " + INPUT_PATH)
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(source.get_as_text())
	if not parsed is Dictionary:
		push_error("Invalid Lesson 2 dialogue JSON")
		quit(1)
		return
	var raw_lines: Array = (parsed as Dictionary).get("lines", [])
	var lines := VoiceManifest.enrich_lines(raw_lines)
	if lines.size() != raw_lines.size():
		push_error("Lesson 2 voice manifest did not preserve every source line")
		quit(1)
		return

	var groups := _group_by_speaker(lines)
	var output := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if output == null:
		push_error("Cannot write " + OUTPUT_PATH)
		quit(1)
		return

	_write_header(output, lines, groups)
	output.store_line("## IMPORTANT CHAPTER 2 NPCS")
	output.store_line("")
	for speaker_id in VoiceManifest.IMPORTANT_SPEAKER_ORDER:
		var speaker_lines: Array = groups.get(speaker_id, [])
		if speaker_lines.is_empty():
			continue
		_write_character_section(output, speaker_id, speaker_lines)

	output.store_line("## NARRATOR CHAPTER 2")
	output.store_line("")
	_write_character_section(output, "l2_narrator", groups.get("l2_narrator", []))

	output.store_line("## AMBIENT CHAPTER 2")
	output.store_line("")
	output.store_line("These are authored positional city lines. They are separate from mission dialogue.")
	output.store_line("")
	for speaker_id in VoiceManifest.AMBIENT_SPEAKER_ORDER:
		var ambient_lines: Array = groups.get(speaker_id, [])
		if ambient_lines.is_empty():
			continue
		_write_character_section(output, speaker_id, ambient_lines)

	_write_totals(output, lines)
	print("LESSON2_VOICE_SCRIPT_EXPORTED: %d exact lines to %s" % [lines.size(), OUTPUT_PATH])
	quit(0)


func _write_header(output: FileAccess, lines: Array, groups: Dictionary) -> void:
	output.store_line("# VOICE SCRIPT — CHAPTER 2")
	output.store_line("")
	output.store_line("Frozen from the current implemented Arabic subtitles in `%s`." % INPUT_PATH)
	output.store_line("")
	output.store_line("- Future recording root: `%s/`" % VoiceManifest.FUTURE_AUDIO_ROOT)
	output.store_line("- Runtime status: subtitle-only; no Chapter 2 MP3 files are required or preloaded.")
	output.store_line("- Player: silent protagonist. The current Chapter 2 subtitle source contains **0 player lines**, so no player filename is assigned.")
	output.store_line("- Scope: only lines routed through the Chapter 2 dialogue, cinematic, or authored ambient subtitle systems are recordings. HUD objectives, counters, hover labels, and correct/wrong UI notices are visual interface text and are not voice lines.")
	output.store_line("")
	output.store_line("## SUMMARY TABLE")
	output.store_line("")
	output.store_line("| Character | Speaker ID | Number of lines | First filename | Last filename | Suggested voice style |")
	output.store_line("|---|---|---:|---|---|---|")
	for speaker_id in VoiceManifest.full_speaker_order():
		var speaker_lines: Array = groups.get(speaker_id, [])
		if speaker_lines.is_empty():
			continue
		var first: Dictionary = speaker_lines.front()
		var last: Dictionary = speaker_lines.back()
		var definition := VoiceManifest.speaker_definition(speaker_id)
		output.store_line("| %s | `%s` | %d | `%s` | `%s` | %s |" % [
			str(definition.get("name_ar", first.get("speaker_name_ar", speaker_id))),
			speaker_id,
			speaker_lines.size(),
			str(first.get("voice_filename", "")),
			str(last.get("voice_filename", "")),
			str(definition.get("style", "")),
		])
	output.store_line("")
	output.store_line("Total extracted subtitle/voice lines: **%d**." % lines.size())
	output.store_line("")


func _write_character_section(output: FileAccess, speaker_id: String, speaker_lines: Array) -> void:
	if speaker_lines.is_empty():
		return
	var definition := VoiceManifest.speaker_definition(speaker_id)
	var name_ar := str(definition.get("name_ar", (speaker_lines.front() as Dictionary).get("speaker_name_ar", speaker_id)))
	output.store_line("### %s" % name_ar)
	output.store_line("")
	output.store_line("speaker_id: `%s`  " % speaker_id)
	output.store_line("suggested_voice_style: %s" % str(definition.get("style", "")))
	output.store_line("")
	for line_variant in speaker_lines:
		_write_line(output, line_variant as Dictionary)


func _write_line(output: FileAccess, line: Dictionary) -> void:
	var filename := str(line.get("voice_filename", ""))
	output.store_line("#### %s" % filename)
	output.store_line("")
	output.store_line("- `filename`: `%s`" % filename)
	output.store_line("- `speaker_id`: `%s`" % str(line.get("speaker_id", "")))
	output.store_line("- `dialogue_id`: `%s`" % str(line.get("line_id", "")))
	output.store_line("- `text`: \"%s\"" % str(line.get("text_ar", "")).replace("\"", "\\\""))
	output.store_line("- `audio_path`: `%s`" % str(line.get("future_audio_path", "")))
	output.store_line("- `context`: %s" % str(line.get("recording_context", "")))
	output.store_line("- `delivery`: %s" % str(line.get("delivery", "")))
	output.store_line("")


func _write_totals(output: FileAccess, lines: Array) -> void:
	var important_speakers: Dictionary = {}
	var important_lines := 0
	var narrator_lines := 0
	var npc_to_npc_lines := 0
	var ambient_lines := 0
	for line_variant in lines:
		var line: Dictionary = line_variant
		match str(line.get("voice_category", "")):
			"important_npc":
				important_lines += 1
				important_speakers[str(line.get("speaker_id", ""))] = true
			"npc_to_npc":
				npc_to_npc_lines += 1
				important_speakers[str(line.get("speaker_id", ""))] = true
			"narrator": narrator_lines += 1
			"ambient": ambient_lines += 1
	output.store_line("## EXACT TOTALS")
	output.store_line("")
	output.store_line("- TOTAL IMPORTANT CHARACTERS: **%d**" % important_speakers.size())
	output.store_line("- TOTAL IMPORTANT NPC LINES: **%d**" % important_lines)
	output.store_line("- TOTAL NARRATOR LINES: **%d**" % narrator_lines)
	output.store_line("- TOTAL NPC-TO-NPC LINES: **%d**" % npc_to_npc_lines)
	output.store_line("- TOTAL AMBIENT LINES: **%d**" % ambient_lines)
	output.store_line("- GRAND TOTAL RECORDINGS: **%d**" % lines.size())
	output.store_line("")
	output.store_line("The total categories above are mutually exclusive and sum to the grand total. No player recording is included.")


func _group_by_speaker(lines: Array) -> Dictionary:
	var groups: Dictionary = {}
	for line_variant in lines:
		var line: Dictionary = line_variant
		var speaker_id := str(line.get("speaker_id", ""))
		if not groups.has(speaker_id):
			groups[speaker_id] = []
		(groups[speaker_id] as Array).append(line)
	return groups
