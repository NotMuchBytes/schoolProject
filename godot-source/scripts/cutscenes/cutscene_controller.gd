class_name CutsceneController
extends Node3D

signal cutscene_started(sequence_name: String)
signal cutscene_finished(sequence_name: String, was_skipped: bool)
signal shot_started(sequence_name: String, shot_index: int, shot: Dictionary)
signal subtitle_changed(speaker: String, text: String)
signal subtitle_hidden

@export_node_path("CharacterBody3D") var player_path: NodePath

var _player: PlayerController
var _cinematic_camera: Camera3D
var _active: bool = false
var _skip_allowed: bool = false
var _skip_requested: bool = false
var _advance_shot_requested: bool = false
var _sequence_name: String = ""
var _active_tween: Tween
var _conversation_npc: Node3D
var _conversation_side_sign: float = 1.0
var _conversation_npc_speaking: bool = true
var _conversation_line_index: int = 0
var _fallback_npc_visual: Node3D
var _fallback_npc_visual_rotation: Vector3
var _fallback_gesture_time: float = 0.0


func _process(delta: float) -> void:
	if not _active or _sequence_name != "conversation" or _fallback_npc_visual == null:
		return
	if not is_instance_valid(_fallback_npc_visual):
		_fallback_npc_visual = null
		return
	_fallback_gesture_time += delta
	_fallback_npc_visual.rotation = _fallback_npc_visual_rotation
	if _conversation_npc_speaking:
		_fallback_npc_visual.rotation.x += sin(_fallback_gesture_time * 3.15) * 0.016
		_fallback_npc_visual.rotation.z += sin(_fallback_gesture_time * 1.8 + 0.6) * 0.012
	else:
		_fallback_npc_visual.rotation.x += sin(_fallback_gesture_time * 1.2) * 0.005
		_fallback_npc_visual.rotation.z += sin(_fallback_gesture_time * 0.75) * 0.004


func _ready() -> void:
	_player = get_node_or_null(player_path) as PlayerController
	_cinematic_camera = Camera3D.new()
	_cinematic_camera.name = "CinematicCamera"
	_cinematic_camera.fov = 57.0
	_cinematic_camera.near = 0.08
	add_child(_cinematic_camera)
	_cinematic_camera.current = false


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not _skip_allowed:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_skip_requested = true
			get_viewport().set_input_as_handled()
		elif key_event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
			VoiceDirector.stop_narrator(true)
			_advance_shot_requested = true
			get_viewport().set_input_as_handled()


func play_shots(sequence_name: String, shots: Array, allow_skip: bool = true) -> void:
	if _active or shots.is_empty() or _player == null:
		return
	_active = true
	_skip_allowed = allow_skip
	_skip_requested = false
	_advance_shot_requested = false
	_sequence_name = sequence_name
	VoiceDirector.begin_scripted_speech(StringName(_sequence_name))
	_player.set_cinematic_mode(true)
	cutscene_started.emit(_sequence_name)

	var first_shot: Dictionary = shots[0]
	var first_position: Vector3 = first_shot.get("position", Vector3.ZERO)
	var first_target: Vector3 = first_shot.get("target", Vector3.ZERO)
	_cinematic_camera.global_transform = _make_camera_transform(
		first_position + Vector3(0.0, 0.35, 2.2), first_target
	)
	_cinematic_camera.current = true

	var voiced_shots := VoiceCatalog.normalize_entries(sequence_name, shots, "subtitle")
	for shot_index in voiced_shots.size():
		var shot_variant: Variant = voiced_shots[shot_index]
		if _skip_requested:
			break
		_advance_shot_requested = false
		var shot: Dictionary = shot_variant
		shot_started.emit(_sequence_name, shot_index, shot)
		var speaker := str(shot.get("speaker", ""))
		var subtitle := str(shot.get("subtitle", ""))
		if not subtitle.is_empty():
			subtitle_changed.emit(speaker, subtitle)
		var position: Vector3 = shot.get("position", _cinematic_camera.global_position)
		var target: Vector3 = shot.get("target", Vector3.ZERO)
		var voice_duration := VoiceDirector.play_narrator_entry(shot)
		var duration := maxf(maxf(float(shot.get("duration", 3.0)), voice_duration + 0.25), 0.15)
		_active_tween = create_tween()
		_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_active_tween.tween_property(
			_cinematic_camera,
			"global_transform",
			_make_camera_transform(position, target),
			duration
		)
		while (
			_active_tween != null
			and _active_tween.is_running()
			and not _skip_requested
			and not _advance_shot_requested
		):
			await get_tree().process_frame
		if (_skip_requested or _advance_shot_requested) and _active_tween != null and _active_tween.is_valid():
			_active_tween.kill()
		VoiceDirector.stop_narrator(false)

	await _finish_active_sequence()


func begin_conversation(npc: Node3D) -> void:
	if _active or _player == null or npc == null:
		return
	_active = true
	_skip_allowed = false
	_skip_requested = false
	_sequence_name = "conversation"
	VoiceDirector.stop_narrator(false)
	_conversation_npc = npc
	_player.set_cinematic_mode(true)
	if _player.has_method("begin_conversation_pose"):
		_player.call("begin_conversation_pose", npc)
	if npc.has_method("begin_conversation"):
		npc.call("begin_conversation", _player)

	_fallback_npc_visual = null
	var npc_visual := npc.get_node_or_null("Visual") as Node3D
	var has_native_gestures := npc is NPCController
	if npc_visual != null and npc_visual.has_method("set_conversation_state"):
		has_native_gestures = true
	if not has_native_gestures and npc_visual != null:
		_fallback_npc_visual = npc_visual
		_fallback_npc_visual_rotation = _fallback_npc_visual.rotation
	_fallback_gesture_time = 0.0
	_conversation_npc_speaking = true
	_conversation_line_index = 0
	_conversation_side_sign = _choose_conversation_side()

	_cinematic_camera.global_transform = _player.get_gameplay_camera().global_transform
	_cinematic_camera.fov = _player.get_gameplay_camera().fov
	_cinematic_camera.current = true
	_update_conversation_camera(0.72, true)


func set_conversation_speaker(
	npc_is_speaking: bool, line_index: int = 0, gesture_state: String = "talk_explain"
) -> void:
	if not _active or _sequence_name != "conversation" or _conversation_npc == null:
		return
	_conversation_npc_speaking = npc_is_speaking
	_conversation_line_index = line_index
	_fallback_gesture_time = float(posmod(line_index * 11, 17)) * 0.1
	if _conversation_npc.has_method("set_conversation_speaking"):
		_conversation_npc.call("set_conversation_speaking", npc_is_speaking, line_index, gesture_state)
	if _player.has_method("set_conversation_speaking"):
		_player.call("set_conversation_speaking", not npc_is_speaking, line_index, gesture_state)
	_update_conversation_camera(0.62, false)


func end_conversation() -> void:
	if not _active or _sequence_name != "conversation" or _player == null:
		return
	var gameplay_camera := _player.get_gameplay_camera()
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(
		_cinematic_camera, "global_transform", gameplay_camera.global_transform, 0.42
	)
	await _active_tween.finished
	gameplay_camera.current = true
	if _fallback_npc_visual != null and is_instance_valid(_fallback_npc_visual):
		_fallback_npc_visual.rotation = _fallback_npc_visual_rotation
	if _conversation_npc != null and _conversation_npc.has_method("end_conversation"):
		_conversation_npc.call("end_conversation")
	if _player.has_method("end_conversation_pose"):
		_player.call("end_conversation_pose")
	_fallback_npc_visual = null
	_conversation_npc = null
	_active = false
	_sequence_name = ""
	_player.set_cinematic_mode(false)


func is_active() -> bool:
	return _active


func was_skip_requested() -> bool:
	return _skip_requested


func _finish_active_sequence() -> void:
	var completed_name := _sequence_name
	var skipped := _skip_requested
	subtitle_hidden.emit()
	VoiceDirector.stop_narrator(false)
	VoiceDirector.end_scripted_speech(StringName(completed_name))
	var gameplay_camera := _player.get_gameplay_camera()
	var return_duration := 0.08 if skipped else 0.52
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(
		_cinematic_camera, "global_transform", gameplay_camera.global_transform, return_duration
	)
	await _active_tween.finished
	gameplay_camera.current = true
	_player.set_cinematic_mode(false)
	_active = false
	_skip_allowed = false
	_sequence_name = ""
	cutscene_finished.emit(completed_name, skipped)


func _make_camera_transform(position: Vector3, target: Vector3) -> Transform3D:
	var camera_transform := Transform3D.IDENTITY
	camera_transform.origin = position
	return camera_transform.looking_at(target, Vector3.UP)


func _update_conversation_camera(duration: float, first_frame: bool) -> void:
	if _conversation_npc == null or not is_instance_valid(_conversation_npc):
		return
	var player_focus := _get_player_focus()
	var npc_focus := _get_npc_focus()
	var midpoint := (player_focus + npc_focus) * 0.5
	var between := npc_focus - player_focus
	between.y = 0.0
	if between.length_squared() < 0.01:
		between = Vector3.FORWARD
	between = between.normalized()
	var side := Vector3(-between.z, 0.0, between.x) * _conversation_side_sign

	# Keep one side of the eye-line throughout the exchange. Speaker changes only
	# add a restrained drift and focus bias, avoiding a hard cut on every line.
	var speaker_shift := -0.28 if _conversation_npc_speaking else 0.28
	var desired_position := midpoint + side * 2.85 + Vector3.UP * 0.72 + between * speaker_shift
	var focus_bias := npc_focus if _conversation_npc_speaking else player_focus
	var desired_target := midpoint.lerp(focus_bias, 0.30) + Vector3.UP * 0.04
	desired_position = _resolve_camera_collision(desired_target, desired_position)

	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT if first_frame else Tween.EASE_IN_OUT
	)
	_active_tween.tween_property(
		_cinematic_camera,
		"global_transform",
		_make_camera_transform(desired_position, desired_target),
		duration
	)
	_active_tween.tween_property(_cinematic_camera, "fov", 51.5, duration)


func _choose_conversation_side() -> float:
	var player_focus := _get_player_focus()
	var npc_focus := _get_npc_focus()
	var midpoint := (player_focus + npc_focus) * 0.5
	var between := npc_focus - player_focus
	between.y = 0.0
	if between.length_squared() < 0.01:
		between = Vector3.FORWARD
	between = between.normalized()
	var side := Vector3(-between.z, 0.0, between.x)
	var camera_position := _player.get_gameplay_camera().global_position
	var positive := midpoint + side * 2.85 + Vector3.UP * 0.72
	var negative := midpoint - side * 2.85 + Vector3.UP * 0.72
	var positive_score := (
		_camera_clearance(midpoint, positive) * 2.0
		- camera_position.distance_to(positive) * 0.12
		- _conversation_frame_clutter(positive, midpoint) * 2.4
	)
	var negative_score := (
		_camera_clearance(midpoint, negative) * 2.0
		- camera_position.distance_to(negative) * 0.12
		- _conversation_frame_clutter(negative, midpoint) * 2.4
	)
	return 1.0 if positive_score >= negative_score else -1.0


func _conversation_frame_clutter(camera_position: Vector3, target: Vector3) -> float:
	# Keep ambient characters from accidentally becoming a foreground third party
	# in an otherwise clean two-shot. This only influences the initial side choice;
	# the eye-line remains locked for the full exchange.
	var view_direction := target - camera_position
	view_direction.y = 0.0
	var target_distance := view_direction.length()
	if target_distance < 0.01:
		return 0.0
	view_direction /= target_distance
	var clutter := 0.0
	for candidate in get_tree().get_nodes_in_group("story_npc"):
		if candidate == _conversation_npc or not candidate is Node3D:
			continue
		var actor_direction := (candidate as Node3D).global_position - camera_position
		actor_direction.y = 0.0
		var actor_distance := actor_direction.length()
		if actor_distance < 0.01 or actor_distance > target_distance + 6.0:
			continue
		var alignment := view_direction.dot(actor_direction / actor_distance)
		if alignment > 0.72:
			clutter += inverse_lerp(0.72, 1.0, alignment)
	return clutter


func _get_player_focus() -> Vector3:
	return _player.global_position + Vector3.UP * 1.25


func _get_npc_focus() -> Vector3:
	if _conversation_npc != null and _conversation_npc.has_method("get_camera_focus_position"):
		return _conversation_npc.call("get_camera_focus_position") as Vector3
	return _conversation_npc.global_position + Vector3.UP * 1.25


func _resolve_camera_collision(target: Vector3, desired_position: Vector3) -> Vector3:
	var hit := _camera_ray(target, desired_position)
	if hit.is_empty():
		return desired_position
	var ray := desired_position - target
	var ray_length := ray.length()
	if ray_length < 0.001:
		return desired_position
	var hit_position: Vector3 = hit.get("position", desired_position)
	# Stay on the target-facing side of the obstacle, even in a very tight space.
	# A minimum larger than the hit distance could push the camera through a wall.
	var safe_distance := maxf(target.distance_to(hit_position) - 0.32, 0.45)
	return target + ray / ray_length * minf(safe_distance, ray_length)


func _camera_clearance(target: Vector3, desired_position: Vector3) -> float:
	var hit := _camera_ray(target, desired_position)
	if hit.is_empty():
		return target.distance_to(desired_position)
	var hit_position: Vector3 = hit.get("position", target)
	return target.distance_to(hit_position)


func _camera_ray(from: Vector3, to: Vector3) -> Dictionary:
	if not is_inside_tree():
		return {}
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var excluded: Array[RID] = []
	if _player is CollisionObject3D:
		excluded.append((_player as CollisionObject3D).get_rid())
	if _conversation_npc is CollisionObject3D:
		excluded.append((_conversation_npc as CollisionObject3D).get_rid())
	query.exclude = excluded
	return get_world_3d().direct_space_state.intersect_ray(query)
