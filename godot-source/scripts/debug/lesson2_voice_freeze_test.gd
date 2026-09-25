extends SceneTree

const VoiceManifest := preload("res://scripts/story/lesson2_voice_manifest.gd")
const DATA_PATH := "res://data/lesson2_dialogue.json"
const SCRIPT_PATH := "res://audio/VOICE_SCRIPT_LESSON2.md"
const LEVEL_PATH := "res://scenes/levels/lesson2_level.tscn"

var _failed := false


func _initialize() -> void:
	var source := FileAccess.open(DATA_PATH, FileAccess.READ)
	_check(source != null, "canonical Chapter 2 dialogue JSON exists")
	if source == null:
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(source.get_as_text())
	_check(parsed is Dictionary, "canonical Chapter 2 dialogue JSON parses")
	if not parsed is Dictionary:
		quit(1)
		return
	var raw_lines: Array = (parsed as Dictionary).get("lines", [])
	var lines := VoiceManifest.enrich_lines(raw_lines)
	_check(lines.size() == 58, "exactly 58 implemented Chapter 2 voice/subtitle lines")

	var line_ids: Dictionary = {}
	var filenames: Dictionary = {}
	var paths: Dictionary = {}
	var exact_texts: Dictionary = {}
	var important_speakers: Dictionary = {}
	var category_counts := {
		"important_npc": 0,
		"narrator": 0,
		"npc_to_npc": 0,
		"ambient": 0,
	}
	var script_text := FileAccess.get_file_as_string(SCRIPT_PATH)
	_check(not script_text.is_empty(), "generated VOICE_SCRIPT_LESSON2.md exists")

	for line_variant in lines:
		var line: Dictionary = line_variant
		var line_id := str(line.get("line_id", ""))
		var filename := str(line.get("voice_filename", ""))
		var future_path := str(line.get("future_audio_path", ""))
		var text_ar := str(line.get("text_ar", ""))
		var category := str(line.get("voice_category", ""))
		_check(line_id.begins_with("l2_"), "stable Lesson 2 ID: " + line_id)
		_check(not line_ids.has(line_id), "unique dialogue ID: " + line_id)
		_check(not filenames.has(filename), "unique recording filename: " + filename)
		_check(not paths.has(future_path), "unique future audio path: " + future_path)
		_check(not text_ar.is_empty(), "non-empty exact Arabic subtitle: " + line_id)
		_check(str(line.get("audio_path", "")).is_empty(), "source audio remains optional: " + line_id)
		_check(future_path.begins_with(VoiceManifest.FUTURE_AUDIO_ROOT + "/"), "future path uses final Lesson 2 root: " + line_id)
		_check(future_path.ends_with(".mp3"), "future path is MP3: " + line_id)
		_check(script_text.contains("`dialogue_id`: `%s`" % line_id), "voice script contains ID: " + line_id)
		_check(script_text.contains(text_ar), "voice script preserves exact Arabic: " + line_id)
		line_ids[line_id] = true
		filenames[filename] = true
		paths[future_path] = true
		exact_texts[text_ar] = int(exact_texts.get(text_ar, 0)) + 1
		category_counts[category] = int(category_counts.get(category, 0)) + 1
		if category in ["important_npc", "npc_to_npc"]:
			important_speakers[str(line.get("speaker_id", ""))] = true

	_check(line_ids.size() == 58, "all dialogue IDs are unique")
	_check(filenames.size() == 58, "all recording filenames are unique")
	_check(paths.size() == 58, "all future recording paths are unique")
	_check(exact_texts.size() == 58, "no accidental duplicate recording text")
	_check(important_speakers.size() == 14, "14 real important Chapter 2 characters")
	_check(int(category_counts["important_npc"]) == 46, "46 important NPC lines")
	_check(int(category_counts["narrator"]) == 4, "4 narrator lines")
	_check(int(category_counts["npc_to_npc"]) == 2, "2 scripted NPC-to-NPC theatre lines")
	_check(int(category_counts["ambient"]) == 6, "6 authored ambient lines")
	_check(
		int(category_counts["important_npc"]) + int(category_counts["narrator"])
		+ int(category_counts["npc_to_npc"]) + int(category_counts["ambient"]) == 58,
		"exclusive totals equal 58 recordings"
	)

	var narrator_names: Array[String] = []
	var ambient_names: Array[String] = []
	for line_variant in lines:
		var line: Dictionary = line_variant
		if str(line.get("voice_category", "")) == "narrator":
			_check(str(line.get("speaker_id", "")) == "l2_narrator", "narrator uses l2_narrator")
			narrator_names.append(str(line.get("voice_filename", "")))
		elif str(line.get("voice_category", "")) == "ambient":
			ambient_names.append(str(line.get("voice_filename", "")))
	_check(narrator_names == [
		"narrator_l2_001.mp3", "narrator_l2_002.mp3",
		"narrator_l2_003.mp3", "narrator_l2_004.mp3",
	], "narrator filenames are sequential")
	_check(ambient_names == [
		"ambient_l2_001.mp3", "ambient_l2_002.mp3", "ambient_l2_003.mp3",
		"ambient_l2_004.mp3", "ambient_l2_005.mp3", "ambient_l2_006.mp3",
	], "ambient filenames are sequential and separate")

	var player_lines := lines.filter(func(line: Dictionary) -> bool:
		return str(line.get("speaker_id", "")) == "player"
	)
	_check(player_lines.is_empty(), "current Chapter 2 has no player recording lines")

	var level_text := FileAccess.get_file_as_string(LEVEL_PATH)
	for ambient_index in range(1, 7):
		var ambient_id := "l2_ambient_%03d" % ambient_index
		_check(level_text.contains(ambient_id), "level scene uses authored ambient ID: " + ambient_id)
	_check(
		FileAccess.get_file_as_string("res://scripts/story/lesson2_level.gd").contains("l2_stage_tragedy_001")
		and FileAccess.get_file_as_string("res://scripts/story/lesson2_level.gd").contains("l2_stage_comedy_001"),
		"implemented theatre rehearsal lines are included"
	)

	_check(not DirAccess.dir_exists_absolute(VoiceManifest.FUTURE_AUDIO_ROOT), "no Chapter 2 voice folder or placeholder audio was created")
	for line_variant in lines:
		var line: Dictionary = line_variant
		var runtime_entry := Lesson2Content.entry(str(line.get("line_id", "")))
		_check(str(runtime_entry.get("audio_path", "")).is_empty(), "missing future MP3 stays silent: " + str(line.get("line_id", "")))

	print("LESSON2_VOICE_FREEZE_TEST: ", "FAIL" if _failed else "PASS")
	quit(1 if _failed else 0)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
		return
	_failed = true
	push_error("FAIL: " + message)
