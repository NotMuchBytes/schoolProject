extends Node

signal cue_requested(category: String, cue_name: String)

const SPEECH_DUCK_MUSIC_DB := -6.0
const SPEECH_DUCK_AMBIENT_DB := -3.0
const SPEECH_DUCK_ATTACK := 0.20
const SPEECH_DUCK_RELEASE := 0.45

var _registered_cues: Dictionary = {}
var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _speech_duck_sources: Dictionary = {}
var _base_bus_volumes: Dictionary = {}
var _duck_tween: Tween


func _ready() -> void:
	_music_player = _create_player("MusicPlayer", "Music")
	_ambient_player = _create_player("AmbientPlayer", "Ambient")
	_sfx_player = _create_player("SFXPlayer", "SFX")
	_remember_bus_volume("Music")
	_remember_bus_volume("Ambient")


func register_cue(cue_name: String, stream: AudioStream) -> void:
	_registered_cues[cue_name] = stream


func play_music(cue_name: String) -> bool:
	return _play_registered(_music_player, "music", cue_name)


func play_ambient(cue_name: String) -> bool:
	return _play_registered(_ambient_player, "ambient", cue_name)


func play_sfx(cue_name: String) -> bool:
	return _play_registered(_sfx_player, "sfx", cue_name)


func stop_music() -> void:
	_music_player.stop()


func stop_ambient() -> void:
	_ambient_player.stop()


func set_speech_duck(source_key: StringName, active: bool) -> void:
	# Source keys make overlapping dialogue, narration, and scripted speech safe:
	# the mix is restored only after the final active source releases its key.
	if source_key.is_empty():
		return
	var was_active := not _speech_duck_sources.is_empty()
	if active:
		_speech_duck_sources[source_key] = true
	else:
		_speech_duck_sources.erase(source_key)
	var is_active := not _speech_duck_sources.is_empty()
	if was_active != is_active:
		_apply_speech_duck(is_active)


func is_speech_duck_active() -> bool:
	return not _speech_duck_sources.is_empty()


func _play_registered(player: AudioStreamPlayer, category: String, cue_name: String) -> bool:
	cue_requested.emit(category, cue_name)
	if not _registered_cues.has(cue_name):
		return false
	player.stream = _registered_cues[cue_name] as AudioStream
	player.play()
	return true


func _create_player(player_name: String, target_bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	if AudioServer.get_bus_index(target_bus) >= 0:
		player.bus = target_bus
	add_child(player)
	return player


func _remember_bus_volume(bus_name: StringName) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		_base_bus_volumes[bus_name] = AudioServer.get_bus_volume_db(bus_index)


func _apply_speech_duck(active: bool) -> void:
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_tween = create_tween().set_parallel(true)
	_duck_tween.set_ignore_time_scale(true)
	var duration := SPEECH_DUCK_ATTACK if active else SPEECH_DUCK_RELEASE
	_tween_bus_volume(
		&"Music", SPEECH_DUCK_MUSIC_DB if active else 0.0, duration
	)
	_tween_bus_volume(
		&"Ambient", SPEECH_DUCK_AMBIENT_DB if active else 0.0, duration
	)


func _tween_bus_volume(bus_name: StringName, offset_db: float, duration: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0 or not _base_bus_volumes.has(bus_name):
		return
	var start_db := AudioServer.get_bus_volume_db(bus_index)
	var target_db := float(_base_bus_volumes[bus_name]) + offset_db
	_duck_tween.tween_method(
		_set_bus_volume.bind(bus_index), start_db, target_db, duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_bus_volume(volume_db: float, bus_index: int) -> void:
	if bus_index >= 0 and bus_index < AudioServer.bus_count:
		AudioServer.set_bus_volume_db(bus_index, volume_db)
