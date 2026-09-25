class_name StoryLevelController
extends Node3D

@export_node_path("CharacterBody3D") var player_path: NodePath = NodePath("Player")
@export_node_path("CanvasLayer") var hud_path: NodePath = NodePath("GameHUD")
@export_node_path("Node3D") var cutscene_controller_path: NodePath = NodePath("CutsceneController")

var player: PlayerController
var hud: GameHUD
var cutscene: CutsceneController

var _nearby_npcs: Array[Node] = []
var _active_conversation_npc: Node3D
var _active_conversation_id: String = ""
var _story_level_initialized: bool = false
var _player_dialogue_speaker_names: PackedStringArray = PackedStringArray(["الرسول"])


func _ready() -> void:
	player = get_node_or_null(player_path) as PlayerController
	hud = get_node_or_null(hud_path) as GameHUD
	cutscene = get_node_or_null(cutscene_controller_path) as CutsceneController
	if player == null or hud == null or cutscene == null:
		push_error("StoryLevelController is missing its player, HUD, or cutscene controller.")
		return
	player.interact_pressed.connect(_on_player_interact_pressed)
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	Dialogue.line_changed.connect(_on_dialogue_line_changed)
	cutscene.subtitle_changed.connect(hud.show_cinematic_subtitle)
	cutscene.subtitle_hidden.connect(hud.hide_cinematic_subtitle)
	cutscene.cutscene_started.connect(_on_cutscene_started)
	cutscene.cutscene_finished.connect(_on_cutscene_finished)
	_register_story_npcs()
	_story_level_initialized = true


func _exit_tree() -> void:
	if Dialogue.dialogue_finished.is_connected(_on_dialogue_finished):
		Dialogue.dialogue_finished.disconnect(_on_dialogue_finished)
	if Dialogue.line_changed.is_connected(_on_dialogue_line_changed):
		Dialogue.line_changed.disconnect(_on_dialogue_line_changed)


func _register_story_npcs() -> void:
	for candidate in get_tree().get_nodes_in_group("story_npc"):
		if not is_ancestor_of(candidate):
			continue
		if candidate.has_signal("proximity_changed"):
			candidate.connect("proximity_changed", _on_npc_proximity_changed)
		if candidate.has_signal("interaction_requested"):
			candidate.connect("interaction_requested", _on_npc_interaction_requested)


func start_conversation(npc: Node3D, context_id: String, entries: Array) -> void:
	if Dialogue.is_active() or cutscene.is_active():
		return
	_active_conversation_npc = npc
	_active_conversation_id = context_id
	cutscene.begin_conversation(npc)
	Dialogue.start_dialogue(context_id, entries)


func set_objective(mission_title: String, objective_text: String) -> void:
	Objectives.set_objective(mission_title, objective_text)


func set_npc_available(npc: Node, enabled: bool, show_marker: bool = false) -> void:
	if npc == null:
		return
	if npc.has_method("set_interaction_enabled"):
		npc.call("set_interaction_enabled", enabled)
	if npc.has_method("set_quest_marker"):
		npc.call("set_quest_marker", show_marker and enabled)
	_refresh_interaction_prompt()


func on_npc_interaction_requested(_npc: Node) -> void:
	pass


func on_story_conversation_finished(_context_id: String, _npc: Node3D) -> void:
	pass


func on_cutscene_completed(_sequence_name: String, _was_skipped: bool) -> void:
	pass


func _on_player_interact_pressed() -> void:
	if Dialogue.is_active():
		Dialogue.advance()
		return
	if GameFlow.is_transitioning() or cutscene.is_active():
		return
	var nearest := _get_nearest_available_npc()
	if nearest != null and nearest.has_method("interact"):
		nearest.call("interact")


func _on_npc_proximity_changed(npc: Node, is_near: bool) -> void:
	if is_near:
		if not _nearby_npcs.has(npc):
			_nearby_npcs.append(npc)
	else:
		_nearby_npcs.erase(npc)
	_refresh_interaction_prompt()


func _on_npc_interaction_requested(npc: Node) -> void:
	if cutscene.is_active() or Dialogue.is_active():
		return
	on_npc_interaction_requested(npc)


func _on_dialogue_finished(context_id: String) -> void:
	if context_id != _active_conversation_id:
		return
	var finished_npc := _active_conversation_npc
	_active_conversation_id = ""
	_active_conversation_npc = null
	await cutscene.end_conversation()
	on_story_conversation_finished(context_id, finished_npc)
	_refresh_interaction_prompt()


func _on_dialogue_line_changed(
	speaker: String, _text: String, line_index: int, _line_count: int
) -> void:
	if _active_conversation_npc == null or not cutscene.is_active():
		return
	var entry := Dialogue.get_current_entry()
	cutscene.set_conversation_speaker(
		_is_active_npc_speaker(speaker), line_index, str(entry.get("gesture", "talk_explain"))
	)


func _is_active_npc_speaker(speaker: String) -> bool:
	var normalized_speaker := speaker.strip_edges()
	if _player_dialogue_speaker_names.has(normalized_speaker):
		return false
	if _active_conversation_npc.has_method("get_dialogue_display_name"):
		var npc_name := str(
			_active_conversation_npc.call("get_dialogue_display_name")
		).strip_edges()
		if not npc_name.is_empty() and normalized_speaker == npc_name:
			return true
	# Interactive conversations in these levels are always between the messenger
	# and the selected NPC. Unknown non-player names therefore safely remain on
	# the NPC side (and support contextual titles without hard-coded lists).
	return true


func _on_cutscene_started(_sequence_name: String) -> void:
	hud.show_cutscene_hint(true)
	hud.show_interaction_prompt(false)


func _on_cutscene_finished(sequence_name: String, was_skipped: bool) -> void:
	hud.show_cutscene_hint(false)
	on_cutscene_completed(sequence_name, was_skipped)
	_refresh_interaction_prompt()


func _get_nearest_available_npc() -> Node:
	var nearest: Node
	var nearest_distance := INF
	for npc in _nearby_npcs:
		if not is_instance_valid(npc):
			continue
		if npc.has_method("is_interaction_enabled") and not bool(npc.call("is_interaction_enabled")):
			continue
		var npc_3d := npc as Node3D
		if npc_3d == null:
			continue
		var distance := player.global_position.distance_squared_to(npc_3d.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = npc
	return nearest


func _refresh_interaction_prompt() -> void:
	if hud == null:
		return
	hud.show_interaction_prompt(
		_get_nearest_available_npc() != null
		and not Dialogue.is_active()
		and not cutscene.is_active()
	)
