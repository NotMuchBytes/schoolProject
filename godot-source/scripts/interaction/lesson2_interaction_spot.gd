class_name Lesson2InteractionSpot
extends Area3D

signal proximity_changed(spot: Lesson2InteractionSpot, is_near: bool)
signal placement_preview_changed(spot: Lesson2InteractionSpot, is_visible: bool, is_valid: bool)

enum GuidanceLevel {
	HIDDEN,
	SUBTLE,
	EMPHASIZED,
}

@export var spot_id: String = ""
@export var label_ar: String = "تفحّص"
@export var interaction_enabled: bool = false
@export var guidance_level: GuidanceLevel = GuidanceLevel.SUBTLE
@export_range(3.0, 15.0, 0.5) var subtle_reveal_distance: float = 7.5
@export_range(8.0, 40.0, 1.0) var emphasized_reveal_distance: float = 24.0
@export var expected_item_id: String = ""
@export var placement_offset: Vector3 = Vector3(0.0, 0.12, 0.0)

var marker: Label3D
var _preview: MeshInstance3D
var _tracked_player: PlayerController
var _nearby_player_ids: Dictionary = {}
var _marker_update_time: float = 0.0
var _preview_visible: bool = false
var _preview_valid: bool = true
var _primary_guidance: bool = false
var _marker_pulse_time: float = 0.0


func _ready() -> void:
	add_to_group("lesson2_spot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker = get_node_or_null("Marker") as Label3D
	if marker != null:
		# Mission labels become readable only near their physical subject. At a
		# distance, the player sees a quiet point of interest instead of a wall of
		# floating quest text.
		marker.font_size = mini(marker.font_size, 24)
		marker.outline_size = mini(marker.outline_size, 5)
		marker.pixel_size = minf(marker.pixel_size, 0.005)
		marker.visibility_range_end = emphasized_reveal_distance + 2.0
	_update_marker(true)
	set_process(interaction_enabled)


func _process(delta: float) -> void:
	_marker_pulse_time += delta
	_marker_update_time -= delta
	if _marker_update_time > 0.0:
		return
	_marker_update_time = 0.12
	if not is_instance_valid(_tracked_player):
		_tracked_player = _find_player()
	_update_marker()


func set_interaction_enabled(enabled: bool) -> void:
	if interaction_enabled == enabled:
		_update_marker(true)
		return
	interaction_enabled = enabled
	set_process(enabled or _preview_visible or _primary_guidance)
	_update_marker(true)
	if not enabled and not _nearby_player_ids.is_empty():
		proximity_changed.emit(self, false)
		_nearby_player_ids.clear()
	if enabled:
		for body in get_overlapping_bodies():
			if body is PlayerController:
				_track_nearby_player(body as PlayerController)
				break


func set_guidance_level(level: GuidanceLevel) -> void:
	guidance_level = level
	_update_marker(true)


func set_guidance_escalated(escalated: bool) -> void:
	set_guidance_level(GuidanceLevel.EMPHASIZED if escalated else GuidanceLevel.SUBTLE)


func set_primary_guidance(active: bool) -> void:
	_primary_guidance = active
	_marker_pulse_time = 0.0
	set_process(interaction_enabled or _preview_visible or active)
	_update_marker(true)


func is_primary_guidance() -> bool:
	return _primary_guidance


func can_accept_item(item_id: String) -> bool:
	return not item_id.is_empty() and (expected_item_id.is_empty() or expected_item_id == item_id)


func get_placement_transform(extra_offset: Vector3 = Vector3.ZERO) -> Transform3D:
	return global_transform * Transform3D(Basis.IDENTITY, placement_offset + extra_offset)


func set_placement_preview(enabled: bool, valid: bool = true, spec: Dictionary = {}) -> void:
	_preview_visible = enabled
	_preview_valid = valid
	if enabled:
		_ensure_preview()
		_preview.visible = true
		_preview.position = placement_offset + _dict_vector3(spec, "preview_offset", Vector3.ZERO)
		var radius := maxf(float(spec.get("preview_radius", 0.68)), 0.2)
		_preview.scale = Vector3(radius, 1.0, radius)
		var material := _preview.material_override as StandardMaterial3D
		if material != null:
			var color := (
				Color(0.34, 0.82, 0.62, 0.42)
				if valid
				else Color(0.94, 0.3, 0.2, 0.43)
			)
			material.albedo_color = color
			material.emission = color * 0.8
	elif is_instance_valid(_preview):
		_preview.visible = false
	set_process(interaction_enabled or enabled or _primary_guidance)
	_update_marker(true)
	placement_preview_changed.emit(self, enabled, valid)


func is_placement_preview_visible() -> bool:
	return _preview_visible


func _update_marker(_force: bool = false) -> void:
	if marker == null:
		return
	if not interaction_enabled and not _preview_visible:
		marker.visible = false
		return
	if _primary_guidance:
		marker.visible = true
		marker.text = "!"
		marker.position.y = 2.72 + sin(_marker_pulse_time * 2.4) * 0.10
		marker.modulate = Color(1.0, 0.76, 0.18, 0.98)
		marker.font_size = 52
		marker.outline_size = 9
		marker.pixel_size = 0.005
		marker.no_depth_test = true
		marker.fixed_size = true
		marker.visibility_range_end = 30.0
	elif _preview_visible:
		marker.visible = true
		marker.text = "◆" if _preview_valid else "×"
		marker.modulate = (
			Color(0.45, 0.92, 0.7, 0.88)
			if _preview_valid
			else Color(1.0, 0.4, 0.3, 0.88)
		)
		marker.font_size = 22
		marker.pixel_size = 0.0045
		marker.no_depth_test = true
		marker.fixed_size = true
	else:
		# Only the single current objective receives a world-space marker. Nearby
		# interaction remains communicated by the existing bottom HUD prompt.
		marker.visible = false
		marker.no_depth_test = false
		marker.fixed_size = false


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		_tracked_player = body as PlayerController
		if interaction_enabled:
			_track_nearby_player(body as PlayerController)
		else:
			_update_marker(true)


func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerController:
		return
	var body_id := body.get_instance_id()
	if _nearby_player_ids.erase(body_id) and _nearby_player_ids.is_empty():
		proximity_changed.emit(self, false)
	_update_marker(true)


func _track_nearby_player(player: PlayerController) -> void:
	_tracked_player = player
	var was_empty := _nearby_player_ids.is_empty()
	_nearby_player_ids[player.get_instance_id()] = true
	if interaction_enabled and was_empty:
		proximity_changed.emit(self, true)
	_update_marker(true)


func _find_player() -> PlayerController:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as PlayerController


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
	material.albedo_color = Color(0.34, 0.82, 0.62, 0.42)
	material.emission_enabled = true
	material.emission = Color(0.23, 0.57, 0.39)
	material.emission_energy_multiplier = 0.72
	_preview.material_override = material
	add_child(_preview)


func _dict_vector3(source: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = source.get(key, fallback)
	return value as Vector3 if value is Vector3 else fallback
