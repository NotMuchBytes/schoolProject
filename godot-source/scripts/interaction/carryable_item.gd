class_name Lesson2CarryableItem
extends Node3D

signal availability_changed(item: Lesson2CarryableItem, available: bool)

@export var item_id: String = ""
@export_enum("one_hand", "two_hand", "large", "tablet", "basket", "inspect")
var hold_pose: String = "one_hand"
@export_enum("bundle", "basket", "tablet", "crate", "amphora", "tool", "marker", "mask", "model")
var visual_shape: String = "bundle"
@export var primary_color: Color = Color(0.64, 0.39, 0.19)
@export var accent_color: Color = Color(0.84, 0.67, 0.32)
@export var source_lift: Vector3 = Vector3(0.0, 0.45, 0.0)

var _available := true
var _origin_transform := Transform3D.IDENTITY


func _ready() -> void:
	_origin_transform = global_transform


func is_available() -> bool:
	return _available


func set_available(value: bool) -> void:
	_available = value
	visible = value
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
	availability_changed.emit(self, value)


func reset_to_origin() -> void:
	global_transform = _origin_transform
	set_available(true)


func get_visual_spec() -> Dictionary:
	return {
		"shape": visual_shape,
		"hold_pose": hold_pose,
		"color": primary_color,
		"accent_color": accent_color,
		"source_offset": source_lift,
	}
