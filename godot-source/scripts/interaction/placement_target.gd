class_name Lesson2PlacementTarget
extends Area3D

signal item_accepted(target: Lesson2PlacementTarget, item_id: String, visual: Node3D)

@export var target_id: String = ""
@export var expected_item_id: String = ""
@export var placement_offset: Vector3 = Vector3(0.0, 0.16, 0.0)
@export var keep_placed_visual: bool = true

var _preview: MeshInstance3D


func can_accept_item(item_id: String) -> bool:
	return not item_id.is_empty() and (expected_item_id.is_empty() or expected_item_id == item_id)


func get_placement_transform(extra_offset: Vector3 = Vector3.ZERO) -> Transform3D:
	return global_transform * Transform3D(Basis.IDENTITY, placement_offset + extra_offset)


func set_placement_preview(enabled: bool, valid: bool = true, spec: Dictionary = {}) -> void:
	if not enabled:
		if is_instance_valid(_preview):
			_preview.visible = false
		return
	_ensure_preview()
	_preview.visible = true
	_preview.position = placement_offset + _dict_vector3(spec, "preview_offset", Vector3.ZERO)
	var material := _preview.material_override as StandardMaterial3D
	if material != null:
		var valid_color := Color(0.38, 0.82, 0.62, 0.38)
		var invalid_color := Color(0.92, 0.32, 0.22, 0.4)
		material.albedo_color = valid_color if valid else invalid_color
		material.emission = (valid_color if valid else invalid_color) * 0.75
	var radius := maxf(float(spec.get("preview_radius", 0.7)), 0.2)
	_preview.scale = Vector3(radius, 1.0, radius)


func accept_item(item_id: String, visual: Node3D) -> bool:
	if not can_accept_item(item_id):
		return false
	set_placement_preview(false)
	item_accepted.emit(self, item_id, visual)
	return true


func _ensure_preview() -> void:
	if is_instance_valid(_preview):
		return
	_preview = MeshInstance3D.new()
	_preview.name = "PlacementPreview"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.025
	mesh.radial_segments = 32
	_preview.mesh = mesh
	_preview.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.38, 0.82, 0.62, 0.38)
	material.emission_enabled = true
	material.emission = Color(0.2, 0.52, 0.34)
	material.emission_energy_multiplier = 0.75
	material.no_depth_test = false
	_preview.material_override = material
	add_child(_preview)


func _dict_vector3(source: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = source.get(key, fallback)
	return value as Vector3 if value is Vector3 else fallback
