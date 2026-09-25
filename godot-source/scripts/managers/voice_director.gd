extends Node

signal dialogue_voice_started(line_id: String, speaker_id: String, duration: float)
signal dialogue_voice_finished(line_id: String, skipped: bool)
signal narrator_voice_started(line_id: String, duration: float)
signal narrator_voice_finished(line_id: String, skipped: bool)
signal voice_file_missing(line_id: String, expected_path: String)
signal ambient_silence_requested

const DUCK_DIALOGUE_VOICE: StringName = &"voice_director_dialogue_voice"
const DUCK_NARRATOR_VOICE: StringName = &"voice_director_narrator_voice"
const LEGACY_AMBIENT_SUSPEND_SOURCE: StringName = &"voice_director_ambient_suspend"
const SPEECH_ENABLED_SETTING := "audio/voice/speech_enabled"

var _dialogue_player: AudioStreamPlayer
var _narrator_player: AudioStreamPlayer
var _dialogue_line_id := ""
var _narrator_line_id := ""
var _dialogue_duration := 0.0
var _narrator_duration := 0.0
var _ambient_owner_id: int = 0
var _ambient_reserved_until_msec: int = 0
var _ambient_suspended := false
var _ambient_suspend_sources: Dictionary = {}
var _speech_session_sources: Dictionary = {}
var _reported_missing_voice_files: Dictionary = {}


func _ready() -> void:
	_dialogue_player = _create_player("DialogueVoicePlayer")
	_narrator_player = _create_player("NarratorVoicePlayer")
	_dialogue_player.finished.connect(_on_dialogue_finished)
	_narrator_player.finished.connect(_on_narrator_finished)


func play_dialogue_entry(entry: Dictionary) -> float:
	stop_dialogue(false)
	stop_narrator(false)
	ambient_silence_requested.emit()
	if not is_speech_enabled():
		_dialogue_line_id = ""
		_dialogue_duration = 0.0
		_refresh_important_voice_duck()
		return 0.0
	var speaker_id := str(entry.get("speaker_id", "npc"))
	# The messenger is intentionally silent. His subtitle and dialogue timing stay
	# active, but an empty recording is never loaded or reported as missing.
	if speaker_id == "player":
		_dialogue_line_id = ""
		_dialogue_duration = 0.0
		_refresh_important_voice_duck()
		return 0.0
	_dialogue_line_id = str(entry.get("line_id", ""))
	var stream := load_entry_stream(entry)
	if stream == null:
		_dialogue_line_id = ""
		_dialogue_duration = 0.0
		_refresh_important_voice_duck()
		return 0.0
	_dialogue_duration = maxf(stream.get_length(), 0.0)
	_dialogue_player.stream = stream
	_dialogue_player.play()
	_refresh_important_voice_duck()
	dialogue_voice_started.emit(_dialogue_line_id, speaker_id, _dialogue_duration)
	return _dialogue_duration


func play_narrator_entry(entry: Dictionary) -> float:
	stop_narrator(false)
	stop_dialogue(false)
	ambient_silence_requested.emit()
	if not is_speech_enabled():
		_narrator_line_id = ""
		_narrator_duration = 0.0
		_refresh_important_voice_duck()
		return 0.0
	_narrator_line_id = str(entry.get("line_id", ""))
	var stream := load_entry_stream(entry)
	if stream == null:
		_narrator_line_id = ""
		_narrator_duration = 0.0
		_refresh_important_voice_duck()
		return 0.0
	_narrator_duration = maxf(stream.get_length(), 0.0)
	_narrator_player.stream = stream
	_narrator_player.play()
	_refresh_important_voice_duck()
	narrator_voice_started.emit(_narrator_line_id, _narrator_duration)
	return _narrator_duration


func stop_dialogue(skipped: bool = true) -> bool:
	if _dialogue_player == null or not _dialogue_player.playing:
		return false
	var completed_line := _dialogue_line_id
	_dialogue_player.stop()
	_dialogue_line_id = ""
	_dialogue_duration = 0.0
	_refresh_important_voice_duck()
	dialogue_voice_finished.emit(completed_line, skipped)
	return true


func stop_narrator(skipped: bool = true) -> bool:
	if _narrator_player == null or not _narrator_player.playing:
		return false
	var completed_line := _narrator_line_id
	_narrator_player.stop()
	_narrator_line_id = ""
	_narrator_duration = 0.0
	_refresh_important_voice_duck()
	narrator_voice_finished.emit(completed_line, skipped)
	return true


func stop_all_voice() -> void:
	ambient_silence_requested.emit()
	stop_dialogue(false)
	stop_narrator(false)
	for source_variant in _speech_session_sources.keys():
		AudioDirector.set_speech_duck(StringName(source_variant), false)
	_speech_session_sources.clear()
	_ambient_suspend_sources.clear()
	_ambient_suspended = false
	AudioDirector.set_speech_duck(LEGACY_AMBIENT_SUSPEND_SOURCE, false)
	ambience_reset()


func is_dialogue_playing() -> bool:
	return _dialogue_player != null and _dialogue_player.playing


func is_narrator_playing() -> bool:
	return _narrator_player != null and _narrator_player.playing


func get_dialogue_duration() -> float:
	return _dialogue_duration


func get_narrator_duration() -> float:
	return _narrator_duration


func try_reserve_ambient(owner: Node, duration: float) -> bool:
	if not is_speech_enabled():
		return false
	if owner == null or _ambient_suspended or is_dialogue_playing() or is_narrator_playing():
		return false
	_clear_expired_ambient_reservation()
	if _ambient_owner_id != 0 and _ambient_owner_id != owner.get_instance_id():
		return false
	_ambient_owner_id = owner.get_instance_id()
	_ambient_reserved_until_msec = Time.get_ticks_msec() + int(maxf(duration, 0.5) * 1000.0)
	return true


func release_ambient(owner: Node) -> void:
	if owner != null and _ambient_owner_id == owner.get_instance_id():
		ambience_reset()


func set_ambient_suspended(suspended: bool) -> void:
	_set_ambient_suppression_source(LEGACY_AMBIENT_SUSPEND_SOURCE, suspended)
	AudioDirector.set_speech_duck(
		LEGACY_AMBIENT_SUSPEND_SOURCE, suspended and is_speech_enabled()
	)


func begin_dialogue_session(source_key: StringName = &"default") -> void:
	_set_speech_session(_scoped_source(&"dialogue_session", source_key), true)


func end_dialogue_session(source_key: StringName = &"default") -> void:
	_set_speech_session(_scoped_source(&"dialogue_session", source_key), false)


func begin_scripted_speech(source_key: StringName = &"default") -> void:
	_set_speech_session(_scoped_source(&"scripted_speech", source_key), true)


func end_scripted_speech(source_key: StringName = &"default") -> void:
	_set_speech_session(_scoped_source(&"scripted_speech", source_key), false)


func ambience_reset() -> void:
	_ambient_owner_id = 0
	_ambient_reserved_until_msec = 0


func load_optional_stream(path: String) -> AudioStream:
	if not is_speech_enabled():
		return null
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


func load_entry_stream(entry: Dictionary) -> AudioStream:
	# Entry-aware loading is shared by important and positional speech so missing
	# non-player recordings use one deduplicated reporting path.
	if not is_speech_enabled() or str(entry.get("speaker_id", "")) == "player":
		return null
	var path := str(entry.get("audio_path", ""))
	var stream := load_optional_stream(path)
	if stream == null:
		var line_id := str(entry.get("line_id", "unknown"))
		var warning_key := "%s\u001f%s" % [line_id, path]
		if not _reported_missing_voice_files.has(warning_key):
			_reported_missing_voice_files[warning_key] = true
			voice_file_missing.emit(line_id, path)
			push_warning("Missing voice file for %s: %s" % [line_id, path])
	return stream


func _clear_expired_ambient_reservation() -> void:
	if _ambient_owner_id != 0 and Time.get_ticks_msec() >= _ambient_reserved_until_msec:
		ambience_reset()


func _create_player(player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	if AudioServer.get_bus_index("Voice") >= 0:
		player.bus = "Voice"
	add_child(player)
	return player


func _on_dialogue_finished() -> void:
	var completed_line := _dialogue_line_id
	_dialogue_line_id = ""
	_dialogue_duration = 0.0
	_refresh_important_voice_duck()
	dialogue_voice_finished.emit(completed_line, false)


func _on_narrator_finished() -> void:
	var completed_line := _narrator_line_id
	_narrator_line_id = ""
	_narrator_duration = 0.0
	_refresh_important_voice_duck()
	narrator_voice_finished.emit(completed_line, false)


func _refresh_important_voice_duck() -> void:
	AudioDirector.set_speech_duck(
		DUCK_DIALOGUE_VOICE, is_speech_enabled() and is_dialogue_playing()
	)
	AudioDirector.set_speech_duck(
		DUCK_NARRATOR_VOICE, is_speech_enabled() and is_narrator_playing()
	)


func _set_speech_session(source_key: StringName, active: bool) -> void:
	if active:
		_speech_session_sources[source_key] = true
	else:
		_speech_session_sources.erase(source_key)
	_set_ambient_suppression_source(source_key, active)
	AudioDirector.set_speech_duck(source_key, active and is_speech_enabled())


func _set_ambient_suppression_source(source_key: StringName, active: bool) -> void:
	var was_suspended := not _ambient_suspend_sources.is_empty()
	if active:
		_ambient_suspend_sources[source_key] = true
	else:
		_ambient_suspend_sources.erase(source_key)
	_ambient_suspended = not _ambient_suspend_sources.is_empty()
	if not was_suspended and _ambient_suspended:
		ambient_silence_requested.emit()
		ambience_reset()


func _scoped_source(scope: StringName, source_key: StringName) -> StringName:
	return StringName("%s:%s" % [scope, source_key])


func is_speech_enabled() -> bool:
	return bool(ProjectSettings.get_setting(SPEECH_ENABLED_SETTING, false))
