class_name TestNPC
extends StaticBody3D

enum NPCRole { TEACHER, TEMPLE_RECIPIENT }

signal proximity_changed(npc: TestNPC, is_near: bool)
signal interaction_requested(npc: TestNPC)

@export var npc_role: NPCRole = NPCRole.TEACHER
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

var _interaction_enabled: bool = true
var _marker_base_y: float = 3.08
var _marker_time: float = 0.0
var _quest_marker_active: bool = false
var _base_rotation_y: float = 0.0


func _ready() -> void:
	_base_rotation_y = rotation.y
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	quest_marker.hide()
	marker_base.hide()
	set_quest_marker(false)
	set_process(false)


func _process(delta: float) -> void:
	if _quest_marker_active:
		_marker_time += delta
		quest_beacon.position.y = _marker_base_y + sin(_marker_time * 2.4) * 0.1


func interact() -> void:
	if _interaction_enabled:
		interaction_requested.emit(self)


func set_quest_marker(active: bool) -> void:
	# Label3D visibility is unreliable in the WebGL renderer. The lightweight
	# mesh beacon keeps the same exclamation-mark silhouette on every platform.
	quest_marker.visible = false
	_quest_marker_active = active
	quest_beacon.visible = true
	quest_beacon.scale = Vector3.ONE if active else Vector3.ZERO
	marker_base.visible = active
	_marker_time = 0.0
	quest_beacon.position.y = _marker_base_y
	set_process(active)


func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled
	if not enabled:
		quest_marker.hide()
		_quest_marker_active = false
		quest_beacon.scale = Vector3.ZERO
		marker_base.hide()
		set_process(false)
	else:
		for body in interaction_area.get_overlapping_bodies():
			if body is PlayerController:
				proximity_changed.emit(self, true)
				break


func is_interaction_enabled() -> bool:
	return _interaction_enabled


func begin_conversation(target: Node3D) -> void:
	var visual := get_node_or_null("Visual")
	if visual != null and visual.has_method("set_conversation_state"):
		visual.call("set_conversation_state", false, 0)
	var direction := target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.0001:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation:y", atan2(direction.x, direction.z), 0.35)


func end_conversation() -> void:
	var visual := get_node_or_null("Visual")
	if visual != null and visual.has_method("clear_conversation_state"):
		visual.call("clear_conversation_state")
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", _base_rotation_y, 0.35)


func set_conversation_speaking(
	speaking: bool, line_index: int = 0, gesture_state: String = "talk_explain"
) -> void:
	var visual := get_node_or_null("Visual")
	if visual != null and visual.has_method("set_conversation_state"):
		visual.call("set_conversation_state", speaking, line_index, gesture_state)


func get_dialogue_display_name() -> String:
	return "المعلّم" if npc_role == NPCRole.TEACHER else "أمين المعبد"


func get_camera_focus_position() -> Vector3:
	return global_position + Vector3.UP * 1.25


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		proximity_changed.emit(self, true)


func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		proximity_changed.emit(self, false)
