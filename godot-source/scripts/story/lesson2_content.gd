class_name Lesson2Content
extends RefCounted

const DATA_PATH := "res://data/lesson2_dialogue.json"
const VoiceManifest := preload("res://scripts/story/lesson2_voice_manifest.gd")

static var _lines: Array = []


static func all_lines() -> Array:
	_ensure_loaded()
	return _lines.duplicate(true)


static func entries(prefix: String) -> Array:
	_ensure_loaded()
	var result: Array = []
	for line_variant in _lines:
		var line: Dictionary = line_variant
		if str(line.get("line_id", "")).begins_with(prefix):
			result.append(_runtime_entry(line))
	return result


static func entry(line_id: String) -> Dictionary:
	_ensure_loaded()
	for line_variant in _lines:
		var line: Dictionary = line_variant
		if str(line.get("line_id", "")) == line_id:
			return _runtime_entry(line)
	return {}


static func _ensure_loaded() -> void:
	if not _lines.is_empty():
		return
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Lesson 2 dialogue data is missing: %s" % DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Lesson 2 dialogue data is invalid JSON.")
		return
	var source_lines: Array = (parsed as Dictionary).get("lines", [])
	_lines = VoiceManifest.enrich_lines(source_lines)


static func _runtime_entry(source: Dictionary) -> Dictionary:
	var result := source.duplicate(true)
	result["speaker"] = str(source.get("speaker_name_ar", "الراوي"))
	result["text"] = str(source.get("text_ar", ""))
	# The manifest documents the future MP3 path, but runtime audio remains empty
	# until that exact resource exists. This keeps the subtitle-only game silent,
	# warning-free, and free of waits while allowing a later recording drop-in.
	var future_path := str(source.get("future_audio_path", ""))
	var is_player := str(source.get("speaker_id", "")) == "player"
	result["audio_path"] = (
		future_path if not is_player and not future_path.is_empty()
		and ResourceLoader.exists(future_path) else ""
	)
	return result
