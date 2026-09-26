class_name NPCController
extends CharacterBody3D

signal proximity_changed(npc: Node, is_near: bool)
signal interaction_requested(npc: Node)
signal destination_reached(npc: Node, waypoint_index: int)
signal receive_reaction_finished(npc: Node, reaction_kind: String)

@export var display_name: String = "شخصية"
@export var interaction_enabled: bool = true
@export var patrol_enabled: bool = false
@export var patrol_offsets: Array[Vector3] = []
@export var walk_speed: float = 1.35
@export var turn_speed: float = 5.5
@export_range(0.2, 10.0, 0.1) var wait_min: float = 1.4
@export_range(0.2, 10.0, 0.1) var wait_max: float = 3.2
@export var quest_marker_active: bool = false
@export_group("Appearance")
@export_enum(
	"Auto",
	"Player Messenger",
	"Teacher Elder",
	"Temple Attendant",
	"Athenian Citizen",
	"Athenian Elder",
	"Spartan Trainer",
	"Spartan Hoplite",
	"Macedonian Officer",
	"Alexander",
	"Macedonian Soldier",
	"Villager Youth",
	"Villager Merchant",
	"Villager Civic"
) var appearance_profile: int = 0
@export_range(-1, 7, 1) var appearance_variant: int = -1

@onready var interaction_area: Area3D = $InteractionArea
@onready var quest_marker: Label3D = $QuestMarker
@onready var quest_beacon: Node3D = $QuestBeacon
@onready var marker_base: MeshInstance3D = $MarkerBase
@onready var visual: Node3D = $Visual

var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _origin: Vector3
var _waypoint_index: int = 0
var _wait_time: float = 0.0
var _conversation_target: Node3D
var _in_conversation: bool = false
var _marker_time: float = 0.0
var _idle_time: float = 0.0
var _visual_base_rotation: Vector3
var _conversation_speaking: bool = false
var _conversation_gesture_time: float = 0.0
var _conversation_gesture_variant: int = 0
var _conversation_line_index: int = 0
var _conversation_gesture_state: String = "talk_explain"
var _pre_conversation_rotation_y: float = 0.0
var _return_rotation_tween: Tween
var _receive_reaction_active: bool = false
var _receive_reaction_elapsed: float = 0.0
var _receive_reaction_duration: float = 1.15
var _receive_reaction_kind: String = "receive"
var _receive_reaction_target: Node3D
var _receive_reaction_target_position: Vector3
var _receive_reaction_has_target: bool = false
var _receive_reaction_started_in_conversation: bool = false
var _pre_receive_rotation_y: float = 0.0


func _ready() -> void:
	_origin = global_position
	_visual_base_rotation = visual.rotation
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	set_quest_marker(quest_marker_active)
	if not patrol_offsets.is_empty():
		_wait_time = randf_range(0.25, wait_max)


func _process(delta: float) -> void:
	_marker_time += delta
	_idle_time += delta
	if quest_marker_active:
		quest_beacon.position.y = 3.08 + sin(_marker_time * 2.4) * 0.1

	if _receive_reaction_active:
		_receive_reaction_elapsed += delta
		var reaction_target := _current_receive_reaction_target()
		if _receive_reaction_has_target:
			_turn_toward(reaction_target, delta, turn_speed * 1.55)
		if _in_conversation:
			_update_conversation_gesture(delta)
		else:
			visual.rotation = _visual_base_rotation
		_apply_receive_reaction_pose()
		if _receive_reaction_elapsed >= _receive_reaction_duration:
			_finish_receive_reaction()
	elif _in_conversation and _conversation_target != null:
		_turn_toward(_conversation_target.global_position, delta, turn_speed * 1.4)
		_update_conversation_gesture(delta)
	elif Vector2(velocity.x, velocity.z).length() < 0.1:
		visual.rotation = _visual_base_rotation
		visual.rotation.y += sin(_idle_time * 0.7) * 0.055
	else:
		visual.rotation = _visual_base_rotation


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	if _in_conversation or _receive_reaction_active or not patrol_enabled or patrol_offsets.is_empty():
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		move_and_slide()
		return

	if _wait_time > 0.0:
		_wait_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, 7.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 7.0 * delta)
		move_and_slide()
		return

	var target := _origin + patrol_offsets[_waypoint_index]
	var flat_delta := target - global_position
	flat_delta.y = 0.0
	if flat_delta.length() <= 0.28:
		velocity.x = 0.0
		velocity.z = 0.0
		destination_reached.emit(self, _waypoint_index)
		_waypoint_index = (_waypoint_index + 1) % patrol_offsets.size()
		_wait_time = randf_range(wait_min, wait_max)
		return

	var direction := flat_delta.normalized()
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	_turn_toward(global_position + direction, delta, turn_speed)
	move_and_slide()


func interact() -> void:
	if interaction_enabled and not _in_conversation:
		interaction_requested.emit(self)


func set_quest_marker(active: bool) -> void:
	quest_marker_active = active
	quest_marker.visible = false
	quest_beacon.visible = true
	quest_beacon.scale = Vector3.ONE if active else Vector3.ZERO
	marker_base.visible = active
	_marker_time = 0.0
	quest_beacon.position.y = 3.08


func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
	if not enabled:
		set_quest_marker(false)
	else:
		for body in interaction_area.get_overlapping_bodies():
			if body is PlayerController:
				proximity_changed.emit(self, true)
				break


func is_interaction_enabled() -> bool:
	return interaction_enabled


## Plays a short, reusable acknowledgement without taking ownership of dialogue.
## `target` may be a Node3D (normally the player or held item), a world-space
## Vector3, or null. Mission code can safely call this while the NPC is idle,
## patrolling, or already in a conversation.
func play_receive_reaction(
	target: Variant = null, reaction_kind: String = "receive", duration: float = 1.15
) -> void:
	if not _receive_reaction_active:
		_pre_receive_rotation_y = rotation.y
	_receive_reaction_active = true
	_receive_reaction_elapsed = 0.0
	_receive_reaction_duration = clampf(duration, 0.45, 3.0)
	_receive_reaction_kind = reaction_kind if not reaction_kind.is_empty() else "receive"
	_receive_reaction_started_in_conversation = _in_conversation
	_receive_reaction_target = null
	_receive_reaction_has_target = false
	if target is Node3D:
		_receive_reaction_target = target as Node3D
		_receive_reaction_target_position = _receive_reaction_target.global_position
		_receive_reaction_has_target = true
	elif target is Vector3:
		_receive_reaction_target_position = target as Vector3
		_receive_reaction_has_target = true
	velocity.x = 0.0
	velocity.z = 0.0
	if _return_rotation_tween != null and _return_rotation_tween.is_valid():
		_return_rotation_tween.kill()
	if not _in_conversation and visual.has_method("set_conversation_state"):
		visual.call("set_conversation_state", true, 1, "talk_response")


## Readable alias for receivers that acknowledge a delivered mission object.
func acknowledge_interaction(
	target: Variant = null, reaction_kind: String = "receive", duration: float = 1.15
) -> void:
	play_receive_reaction(target, reaction_kind, duration)


## Stable mission-facing API. Repeated calls intentionally restart the short
## acknowledgement, which makes rapid scripted placement sequences harmless.
func play_mission_reaction(
	player_or_item: Node3D = null, reaction: String = "receive"
) -> void:
	play_receive_reaction(player_or_item, reaction, 1.15)


func is_playing_receive_reaction() -> bool:
	return _receive_reaction_active


func begin_conversation(target: Node3D) -> void:
	if _return_rotation_tween != null and _return_rotation_tween.is_valid():
		_return_rotation_tween.kill()
	_pre_conversation_rotation_y = (
		_pre_receive_rotation_y if _receive_reaction_active else rotation.y
	)
	_in_conversation = true
	_conversation_target = target
	_conversation_speaking = false
	_conversation_gesture_time = 0.0
	_conversation_line_index = 0
	_conversation_gesture_state = "listen"
	velocity.x = 0.0
	velocity.z = 0.0
	if visual.has_method("set_conversation_state"):
		visual.call("set_conversation_state", false, 0)


func end_conversation() -> void:
	_in_conversation = false
	_conversation_target = null
	_conversation_speaking = false
	visual.rotation = _visual_base_rotation
	if visual.has_method("clear_conversation_state") and not _receive_reaction_active:
		visual.call("clear_conversation_state")
	# A stationary NPC returns to the pose it held before the exchange. Patrolling
	# NPCs retain their current heading so the locomotion controller can naturally
	# turn them toward their next waypoint instead of fighting a rotation tween.
	if not patrol_enabled and not _receive_reaction_active:
		_return_rotation_tween = create_tween()
		_return_rotation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_return_rotation_tween.tween_property(self, "rotation:y", _pre_conversation_rotation_y, 0.38)


func set_conversation_speaking(
	speaking: bool, line_index: int = 0, gesture_state: String = "talk_explain"
) -> void:
	_conversation_speaking = speaking
	_conversation_line_index = line_index
	_conversation_gesture_state = gesture_state
	_conversation_gesture_variant = (
		2 if gesture_state == "talk_emphasis"
		else 1 if gesture_state == "talk_response"
		else posmod(line_index, 2)
	)
	_conversation_gesture_time = float(posmod(line_index * 13, 19)) * 0.09
	if visual.has_method("set_conversation_state"):
		visual.call("set_conversation_state", speaking, line_index, gesture_state)


func get_dialogue_display_name() -> String:
	return display_name


func get_camera_focus_position() -> Vector3:
	return global_position + Vector3.UP * 1.25


func _update_conversation_gesture(delta: float) -> void:
	_conversation_gesture_time += delta
	visual.rotation = _visual_base_rotation
	if _conversation_speaking:
		var speed := 3.0 + float(_conversation_gesture_variant) * 0.28
		var nod := sin(_conversation_gesture_time * speed)
		var emphasis := sin(_conversation_gesture_time * (speed * 0.47) + 0.8)
		visual.rotation.x += nod * (0.015 + float(_conversation_gesture_variant) * 0.003)
		visual.rotation.y += emphasis * 0.012
		visual.rotation.z += emphasis * (0.012 if _conversation_gesture_variant != 1 else -0.012)
	else:
		# Listening stays visibly alive but calmer than the speaking pose.
		visual.rotation.x += sin(_conversation_gesture_time * 1.25 + 0.4) * 0.005
		visual.rotation.z += sin(_conversation_gesture_time * 0.82) * 0.004


func _current_receive_reaction_target() -> Vector3:
	if _receive_reaction_target != null and is_instance_valid(_receive_reaction_target):
		_receive_reaction_target_position = _receive_reaction_target.global_position
	return _receive_reaction_target_position


func _apply_receive_reaction_pose() -> void:
	var progress := clampf(
		_receive_reaction_elapsed / maxf(_receive_reaction_duration, 0.001), 0.0, 1.0
	)
	var envelope := sin(progress * PI)
	var double_nod := sin(progress * PI * 3.0) * envelope
	match _receive_reaction_kind:
		"approve", "success", "thanks":
			visual.rotation.x += 0.055 * envelope + 0.025 * double_nod
			visual.rotation.z += sin(progress * TAU) * 0.012 * envelope
		"inspect", "consider":
			visual.rotation.x += 0.075 * envelope
			visual.rotation.y += sin(progress * PI) * 0.018
		"point", "direct":
			visual.rotation.x += 0.025 * envelope
			visual.rotation.z += 0.045 * envelope
		_:
			# A clear receive-and-thank motion: lean toward the item, then nod.
			visual.rotation.x += 0.065 * envelope + 0.018 * double_nod
			visual.rotation.z += sin(progress * TAU) * 0.014 * envelope


func _finish_receive_reaction() -> void:
	if not _receive_reaction_active:
		return
	var finished_kind := _receive_reaction_kind
	_receive_reaction_active = false
	_receive_reaction_target = null
	_receive_reaction_has_target = false
	visual.rotation = _visual_base_rotation
	if _in_conversation:
		if visual.has_method("set_conversation_state"):
			visual.call(
				"set_conversation_state",
				_conversation_speaking,
				_conversation_line_index,
				_conversation_gesture_state
			)
	else:
		if visual.has_method("clear_conversation_state"):
			visual.call("clear_conversation_state")
		if not patrol_enabled:
			var return_yaw := (
				_pre_conversation_rotation_y
				if _receive_reaction_started_in_conversation
				else _pre_receive_rotation_y
			)
			_return_rotation_tween = create_tween()
			_return_rotation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_return_rotation_tween.tween_property(self, "rotation:y", return_yaw, 0.32)
	receive_reaction_finished.emit(self, finished_kind)


func _turn_toward(target_position: Vector3, delta: float, speed: float) -> void:
	var direction := target_position - global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		return
	var target_yaw := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(speed * delta, 0.0, 1.0))


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController and interaction_enabled:
		proximity_changed.emit(self, true)


func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		proximity_changed.emit(self, false)
