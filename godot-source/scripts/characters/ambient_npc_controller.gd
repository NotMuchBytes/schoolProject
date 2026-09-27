class_name AmbientNPCController
extends NPCController

@export var ambient_category: String = "villager"
@export var active_in_scene: bool = true
@export var ambient_lines: PackedStringArray = PackedStringArray()
@export_range(2.0, 30.0, 0.5) var speech_interval_min: float = 7.0
@export_range(2.0, 30.0, 0.5) var speech_interval_max: float = 13.0
@export_range(1.0, 8.0, 0.25) var speech_duration: float = 3.0
@export_group("Ambient Conversation")
@export var initiates_conversations: bool = false
@export_node_path("AmbientNPCController") var conversation_partner_path: NodePath

@onready var ambient_speech: Label3D = $AmbientSpeech

var _speech_timer := 0.0
var _speech_hide_timer := 0.0
var _ambient_line_index := 0
var _ambient_player: AudioStreamPlayer3D
var _owns_ambient_slot := false
var _exchange_running := false


func _ready() -> void:
	super._ready()
	if not active_in_scene:
		hide()
		set_process(false)
		set_physics_process(false)
		return
	add_to_group("ambient_roamers")
	interaction_enabled = false
	patrol_enabled = true
	_keep_roamer_visible()
	ambient_speech.hide()
	_speech_timer = randf_range(speech_interval_min, speech_interval_max)
	_ambient_player = AudioStreamPlayer3D.new()
	_ambient_player.name = "AmbientVoicePlayer3D"
	_ambient_player.position = Vector3(0.0, 1.55, 0.0)
	_ambient_player.max_distance = 18.0
	_ambient_player.unit_size = 2.5
	if AudioServer.get_bus_index("Voice") >= 0:
		_ambient_player.bus = "Voice"
	add_child(_ambient_player)
	VoiceDirector.ambient_silence_requested.connect(_on_ambient_silence_requested)


## Ambient citizens are real, visible world population rather than quest NPCs.
## Keep their character meshes resident at normal gameplay distances while
## leaving markers and interaction disabled.
func _keep_roamer_visible() -> void:
	show()
	if visual != null:
		visual.show()
		var character_model := visual.get_node_or_null("CharacterModel") as Node3D
		if character_model != null:
			character_model.show()
			_stabilize_roamer_meshes(character_model)


func _stabilize_roamer_meshes(node: Node) -> void:
	if node is GeometryInstance3D:
		var geometry := node as GeometryInstance3D
		geometry.visibility_range_end = 0.0
		geometry.ignore_occlusion_culling = true
		geometry.extra_cull_margin = maxf(geometry.extra_cull_margin, 3.0)
	for child in node.get_children():
		_stabilize_roamer_meshes(child)


func _exit_tree() -> void:
	if VoiceDirector.ambient_silence_requested.is_connected(_on_ambient_silence_requested):
		VoiceDirector.ambient_silence_requested.disconnect(_on_ambient_silence_requested)
	VoiceDirector.release_ambient(self)


func _process(delta: float) -> void:
	super._process(delta)
	if _exchange_running:
		return
	if _speech_hide_timer > 0.0:
		_speech_hide_timer -= delta
		if _speech_hide_timer <= 0.0:
			_finish_local_speech()
		return
	if ambient_lines.is_empty() or _in_conversation:
		return
	_speech_timer -= delta
	if _speech_timer > 0.0:
		return
	_speech_timer = randf_range(speech_interval_min, speech_interval_max)
	if initiates_conversations and not conversation_partner_path.is_empty():
		var partner := get_node_or_null(conversation_partner_path) as AmbientNPCController
		if partner != null and partner.is_visible_in_tree() and not partner._exchange_running:
			_run_ambient_exchange(partner)
			return
	_try_play_solo_line()


func play_scripted_ambient_entry(entry: Dictionary) -> float:
	var duration := _play_local_entry(entry)
	return maxf(duration, speech_duration)


func finish_scripted_ambient_entry() -> void:
	_finish_local_speech(false)


func _try_play_solo_line() -> void:
	var entry := _next_ambient_entry()
	var prepared := _prepare_local_entry(entry)
	var duration := float(prepared.get("duration", speech_duration))
	if not VoiceDirector.try_reserve_ambient(self, duration + 0.35):
		return
	_owns_ambient_slot = true
	_play_prepared_local_entry(entry, prepared)


func _run_ambient_exchange(partner: AmbientNPCController) -> void:
	var first_entry := _next_ambient_entry()
	var reply_entry := partner._next_ambient_entry()
	var first_prepared := _prepare_local_entry(first_entry)
	var reply_prepared := partner._prepare_local_entry(reply_entry)
	var first_duration := float(first_prepared.get("duration", speech_duration))
	var reply_duration := float(reply_prepared.get("duration", partner.speech_duration))
	var total_duration := first_duration + reply_duration + 0.7
	if not VoiceDirector.try_reserve_ambient(self, total_duration):
		return
	_owns_ambient_slot = true
	_exchange_running = true
	partner._exchange_running = true
	begin_conversation(partner)
	partner.begin_conversation(self)
	_play_prepared_local_entry(first_entry, first_prepared)
	await get_tree().create_timer(maxf(first_duration, speech_duration)).timeout
	if not _exchange_running:
		return
	_finish_local_speech(false)
	if not is_instance_valid(partner):
		_end_exchange(null)
		return
	partner._play_prepared_local_entry(reply_entry, reply_prepared)
	await get_tree().create_timer(maxf(reply_duration, partner.speech_duration)).timeout
	if not _exchange_running:
		return
	if is_instance_valid(partner):
		partner._finish_local_speech(false)
	_end_exchange(partner)


func _end_exchange(partner: AmbientNPCController) -> void:
	end_conversation()
	_exchange_running = false
	if partner != null and is_instance_valid(partner):
		partner.end_conversation()
		partner._exchange_running = false
	VoiceDirector.release_ambient(self)
	_owns_ambient_slot = false


func _next_ambient_entry() -> Dictionary:
	if ambient_lines.is_empty():
		return VoiceCatalog.ambient_entry(ambient_category, 0, "")
	var index := _ambient_line_index
	_ambient_line_index = (_ambient_line_index + 1) % ambient_lines.size()
	return VoiceCatalog.ambient_entry(ambient_category, index, ambient_lines[index])


func _play_local_entry(entry: Dictionary) -> float:
	return _play_prepared_local_entry(entry, _prepare_local_entry(entry))


func _prepare_local_entry(entry: Dictionary) -> Dictionary:
	var stream := VoiceDirector.load_entry_stream(entry)
	var duration := speech_duration
	if stream != null:
		duration = maxf(stream.get_length(), speech_duration)
	return {"stream": stream, "duration": duration}


func _play_prepared_local_entry(entry: Dictionary, prepared: Dictionary) -> float:
	ambient_speech.text = str(entry.get("text", ""))
	ambient_speech.show()
	var visual_node := visual as Node3D
	if visual_node != null and visual_node.has_method("set_conversation_state"):
		visual_node.call("set_conversation_state", true, _ambient_line_index, "talk_ambient")
	var stream := prepared.get("stream") as AudioStream
	var duration := float(prepared.get("duration", speech_duration))
	if stream != null:
		_ambient_player.stream = stream
		_ambient_player.play()
	_speech_hide_timer = duration
	return duration


func _finish_local_speech(release_slot: bool = true) -> void:
	_speech_hide_timer = 0.0
	ambient_speech.hide()
	if _ambient_player != null:
		_ambient_player.stop()
	if visual != null and visual.has_method("clear_conversation_state"):
		visual.call("clear_conversation_state")
	if release_slot and _owns_ambient_slot:
		VoiceDirector.release_ambient(self)
		_owns_ambient_slot = false


func _on_ambient_silence_requested() -> void:
	_finish_local_speech()
	if _exchange_running:
		_exchange_running = false
		end_conversation()
