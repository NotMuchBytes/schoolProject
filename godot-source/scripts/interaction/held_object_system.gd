class_name Lesson2HeldObjectSystem
extends Node3D

## Runtime-friendly carry/placement system for Lesson 2.
##
## Minimal controller API:
##   pickup_item("grain", source.global_transform, {"shape": "basket"})
##   show_target_preview(target_spot, "grain")
##   place_item(target_spot.get_placement_transform(), {"target_id": "mill"})
##   reset_held_item()
##
## It deliberately uses visual-only objects. Keeping rigid bodies out of the
## player's hierarchy prevents collision explosions and stair/camera jitter.

signal pickup_started(item_id: String)
signal item_picked_up(item_id: String)
signal placement_started(item_id: String, target_id: String)
signal item_placed(item_id: String, target_id: String, visual: Node3D)
signal item_dropped(item_id: String, visual: Node3D)
signal item_reset(item_id: String)
signal held_item_changed(item_id: String)
signal action_rejected(reason: String)
signal inspection_started(item_id: String)
signal inspection_finished(item_id: String)

@export var pickup_duration: float = 0.36
@export var placement_duration: float = 0.4
@export var lock_player_during_actions: bool = true

var held_item_id: String = ""

var _held_spec: Dictionary = {}
var _held_visual: Node3D
var _held_source_transform := Transform3D.IDENTITY
var _player: PlayerController
var _active_tween: Tween
var _active_completion: Callable
var _active_action: String = ""
var _action_serial: int = 0
var _busy: bool = false
var _preview_spot: Lesson2InteractionSpot
var _placed_visuals: Dictionary = {}
var _failsafe_time: float = 0.0


func _ready() -> void:
	_resolve_player()
	set_process(true)


func _process(delta: float) -> void:
	_failsafe_time -= delta
	if _failsafe_time > 0.0:
		return
	_failsafe_time = 0.25
	if not is_instance_valid(_player):
		_resolve_player()
	if not is_instance_valid(_preview_spot):
		_preview_spot = null
	if held_item_id.is_empty() or _busy:
		return
	# Recover a visual proxy if a scene-side decoration was unexpectedly freed.
	if not is_instance_valid(_held_visual):
		_held_visual = _create_item_visual(held_item_id, _held_spec)
		var anchor := _get_anchor(_hold_pose_for(_held_spec))
		anchor.add_child(_held_visual)
		_held_visual.transform = _hold_transform(_held_spec)
		return
	var expected_anchor := _get_anchor(_hold_pose_for(_held_spec))
	if _held_visual.get_parent() != expected_anchor:
		_held_visual.reparent(expected_anchor, true)
		_held_visual.transform = _hold_transform(_held_spec)
	elif _held_visual.global_position.distance_squared_to(expected_anchor.global_position) > 9.0:
		_held_visual.transform = _hold_transform(_held_spec)


func configure(player: PlayerController) -> Lesson2HeldObjectSystem:
	_player = player
	return self


func is_holding() -> bool:
	return not held_item_id.is_empty() and is_instance_valid(_held_visual)


func is_busy() -> bool:
	return _busy


func get_held_visual() -> Node3D:
	return _held_visual if is_instance_valid(_held_visual) else null


func pickup_item(
	item_id: String, source_transform: Transform3D, visual_spec: Dictionary = {}
) -> bool:
	if item_id.is_empty():
		_reject("empty_item_id")
		return false
	if not is_instance_valid(_player):
		_resolve_player()
	if not is_instance_valid(_player):
		_reject("player_missing")
		return false
	if _busy:
		_finish_active_action_immediately()
	if is_holding():
		_reject("hands_full")
		return false
	clear_target_preview()
	_action_serial += 1
	var serial := _action_serial
	_busy = true
	_active_action = "pickup"
	held_item_id = item_id
	_held_spec = visual_spec.duplicate(true)
	_held_source_transform = source_transform
	_held_visual = _create_item_visual(item_id, _held_spec)
	var start_transform := source_transform
	start_transform.origin += source_transform.basis * _dict_vector3(
		_held_spec, "source_offset", Vector3(0.0, 0.42, 0.0)
	)
	var host := _world_host()
	host.add_child(_held_visual)
	_held_visual.global_transform = start_transform
	var anchor := _get_anchor(_hold_pose_for(_held_spec))
	_held_visual.reparent(anchor, true)
	var desired_transform := _hold_transform(_held_spec)
	var model := _held_visual.get_node_or_null("Model") as Node3D
	if model != null:
		var desired_scale := model.scale
		model.scale = desired_scale * 0.82
		var scale_tween := create_tween()
		scale_tween.tween_property(
			model, "scale", desired_scale, maxf(pickup_duration * 0.72, 0.12)
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_player.face_toward(source_transform.origin)
	_player.play_interaction_pose("pickup", pickup_duration + 0.12, lock_player_during_actions)
	pickup_started.emit(item_id)
	held_item_changed.emit(held_item_id)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_held_visual, "transform", desired_transform, pickup_duration)
	_active_tween.tween_callback(_complete_pickup.bind(serial))
	_active_completion = _complete_pickup.bind(serial)
	return true


func place_item(target_transform: Transform3D, placement_spec: Dictionary = {}) -> bool:
	if _busy:
		_finish_active_action_immediately()
	if not is_holding():
		_reject("nothing_held")
		return false
	var expected := str(placement_spec.get("expected_item_id", ""))
	if not expected.is_empty() and expected != held_item_id:
		_reject("wrong_item")
		return false
	clear_target_preview()
	_action_serial += 1
	var serial := _action_serial
	_busy = true
	_active_action = "place"
	var item_id := held_item_id
	var target_id := str(placement_spec.get("target_id", ""))
	var visual := _held_visual
	var host := _world_host()
	visual.reparent(host, true)
	var final_transform := target_transform
	final_transform = final_transform * Transform3D(
		Basis.from_euler(_dict_vector3(placement_spec, "placement_rotation", Vector3.ZERO)),
		_dict_vector3(placement_spec, "placement_offset", Vector3.ZERO)
	)
	if bool(placement_spec.get("face_target", true)):
		_player.face_toward(final_transform.origin)
	_player.play_interaction_pose(
		"place",
		maxf(float(placement_spec.get("duration", placement_duration)), 0.12) + 0.12,
		lock_player_during_actions
	)
	placement_started.emit(item_id, target_id)
	var duration := maxf(float(placement_spec.get("duration", placement_duration)), 0.08)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(visual, "global_transform", final_transform, duration)
	_active_tween.tween_callback(
		_complete_place.bind(serial, item_id, target_id, visual, final_transform, placement_spec)
	)
	_active_completion = _complete_place.bind(
		serial, item_id, target_id, visual, final_transform, placement_spec
	)
	return true


func place_at_spot(spot: Lesson2InteractionSpot, placement_spec: Dictionary = {}) -> bool:
	if not is_instance_valid(spot):
		_reject("target_missing")
		return false
	var spec := placement_spec.duplicate(true)
	if not spec.has("expected_item_id") and not spot.expected_item_id.is_empty():
		spec["expected_item_id"] = spot.expected_item_id
	if not spec.has("target_id"):
		spec["target_id"] = spot.spot_id
	return place_item(spot.get_placement_transform(), spec)


func inspect_item(
	item_id: String, source_transform: Transform3D, visual_spec: Dictionary = {}
) -> bool:
	if item_id.is_empty():
		_reject("empty_item_id")
		return false
	if _busy:
		_reject("interaction_busy")
		return false
	if is_holding():
		_reject("hands_full")
		return false
	if not is_instance_valid(_player):
		_resolve_player()
	if not is_instance_valid(_player):
		_reject("player_missing")
		return false
	_action_serial += 1
	var serial := _action_serial
	_busy = true
	_active_action = "inspect"
	var visual := _create_item_visual(item_id, visual_spec)
	_world_host().add_child(visual)
	var start_transform := source_transform
	start_transform.origin += source_transform.basis * _dict_vector3(
		visual_spec, "source_offset", Vector3(0.0, 0.42, 0.0)
	)
	visual.global_transform = start_transform
	var anchor := _get_anchor("inspect")
	visual.reparent(anchor, true)
	var inspect_transform := Transform3D(
		Basis.from_euler(Vector3(deg_to_rad(-12.0), 0.0, deg_to_rad(7.0))),
		Vector3.ZERO
	)
	var duration := maxf(float(visual_spec.get("inspect_duration", 0.72)), 0.36)
	_player.face_toward(source_transform.origin)
	_player.play_interaction_pose("inspect", duration, lock_player_during_actions)
	inspection_started.emit(item_id)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(visual, "transform", inspect_transform, duration * 0.34)
	_active_tween.tween_interval(duration * 0.34)
	_active_tween.tween_callback(_release_inspection_visual.bind(visual))
	_active_tween.tween_property(visual, "global_transform", start_transform, duration * 0.32)
	_active_tween.tween_callback(_complete_inspection.bind(serial, item_id, visual))
	_active_completion = _complete_inspection.bind(serial, item_id, visual)
	return true


func show_target_preview(
	spot: Lesson2InteractionSpot, required_item_id: String = "", preview_spec: Dictionary = {}
) -> bool:
	clear_target_preview()
	if not is_instance_valid(spot):
		return false
	_preview_spot = spot
	var expected := required_item_id
	if expected.is_empty():
		expected = spot.expected_item_id
	var valid := is_holding() and (expected.is_empty() or held_item_id == expected)
	spot.set_placement_preview(true, valid, preview_spec)
	return valid


func clear_target_preview() -> void:
	if is_instance_valid(_preview_spot):
		_preview_spot.set_placement_preview(false)
	_preview_spot = null


func reset_held_item(return_to_source: bool = true, animate: bool = true) -> void:
	if _busy:
		_finish_active_action_immediately()
	if not is_holding():
		held_item_id = ""
		_held_visual = null
		return
	var item_id := held_item_id
	var visual := _held_visual
	clear_target_preview()
	visual.reparent(_world_host(), true)
	held_item_id = ""
	_held_visual = null
	_held_spec = {}
	held_item_changed.emit("")
	item_reset.emit(item_id)
	if return_to_source and animate:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(visual, "global_transform", _held_source_transform, 0.24)
		tween.tween_callback(visual.queue_free)
	else:
		visual.queue_free()


func drop_held_item(drop_transform: Transform3D = Transform3D.IDENTITY) -> Node3D:
	if _busy:
		_finish_active_action_immediately()
	if not is_holding():
		return null
	var item_id := held_item_id
	var visual := _held_visual
	visual.reparent(_world_host(), true)
	if drop_transform == Transform3D.IDENTITY:
		var forward := -_player.body_visual.global_basis.z.normalized()
		drop_transform = Transform3D(
			Basis.IDENTITY, _player.global_position + forward * 0.9 + Vector3.UP * 0.3
		)
	visual.global_transform = drop_transform
	visual.set_meta("lesson2_item_id", item_id)
	visual.set_meta("lesson2_dropped", true)
	held_item_id = ""
	_held_visual = null
	_held_spec = {}
	held_item_changed.emit("")
	item_dropped.emit(item_id, visual)
	return visual


func get_placed_visuals(item_id: String = "") -> Array[Node3D]:
	var result: Array[Node3D] = []
	if item_id.is_empty():
		for visuals_variant in _placed_visuals.values():
			for visual_variant in visuals_variant:
				if is_instance_valid(visual_variant):
					result.append(visual_variant as Node3D)
		return result
	for visual_variant in _placed_visuals.get(item_id, []):
		if is_instance_valid(visual_variant):
			result.append(visual_variant as Node3D)
	return result


func clear_placed_visuals(item_prefix: String = "") -> void:
	for item_variant in _placed_visuals.keys():
		var item_id := str(item_variant)
		if not item_prefix.is_empty() and not item_id.begins_with(item_prefix):
			continue
		for visual_variant in _placed_visuals[item_variant]:
			if is_instance_valid(visual_variant):
				(visual_variant as Node3D).queue_free()
		_placed_visuals.erase(item_variant)


func _complete_pickup(serial: int) -> void:
	if serial != _action_serial or _active_action != "pickup":
		return
	if is_instance_valid(_held_visual):
		var anchor := _get_anchor(_hold_pose_for(_held_spec))
		if _held_visual.get_parent() != anchor:
			_held_visual.reparent(anchor, true)
		_held_visual.transform = _hold_transform(_held_spec)
	_busy = false
	_active_action = ""
	_active_tween = null
	_active_completion = Callable()
	item_picked_up.emit(held_item_id)


func _complete_place(
	serial: int,
	item_id: String,
	target_id: String,
	visual: Node3D,
	final_transform: Transform3D,
	placement_spec: Dictionary
) -> void:
	if serial != _action_serial or _active_action != "place":
		return
	if is_instance_valid(visual):
		visual.global_transform = final_transform
		visual.set_meta("lesson2_item_id", item_id)
		visual.set_meta("lesson2_target_id", target_id)
		if bool(placement_spec.get("keep_visual", true)):
			if not _placed_visuals.has(item_id):
				_placed_visuals[item_id] = []
			(_placed_visuals[item_id] as Array).append(visual)
		else:
			visual.queue_free()
	held_item_id = ""
	_held_visual = null
	_held_spec = {}
	_busy = false
	_active_action = ""
	_active_tween = null
	_active_completion = Callable()
	held_item_changed.emit("")
	item_placed.emit(item_id, target_id, visual)


func _complete_inspection(serial: int, item_id: String, visual: Node3D) -> void:
	if serial != _action_serial or _active_action != "inspect":
		return
	if is_instance_valid(visual):
		visual.queue_free()
	_busy = false
	_active_action = ""
	_active_tween = null
	_active_completion = Callable()
	inspection_finished.emit(item_id)


func _release_inspection_visual(visual: Node3D) -> void:
	if is_instance_valid(visual):
		visual.reparent(_world_host(), true)


func _finish_active_action_immediately() -> void:
	if not _busy:
		return
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	var completion := _active_completion
	_active_completion = Callable()
	if completion.is_valid():
		completion.call()


func _reject(reason: String) -> void:
	action_rejected.emit(reason)


func _resolve_player() -> void:
	var cursor := get_parent()
	while cursor != null:
		if cursor is PlayerController:
			_player = cursor as PlayerController
			return
		cursor = cursor.get_parent()


func _get_anchor(hold_pose: String) -> Node3D:
	if is_instance_valid(_player):
		return _player.get_hold_anchor(hold_pose)
	return self


func _world_host() -> Node:
	if get_tree().current_scene != null:
		return get_tree().current_scene
	if is_instance_valid(_player) and _player.get_parent() != null:
		return _player.get_parent()
	return self


func _hold_pose_for(spec: Dictionary) -> String:
	var pose := str(spec.get("hold_pose", "one_hand"))
	if pose in ["one_hand", "two_hand", "large", "tablet", "basket", "inspect", "crate"]:
		return pose
	return "one_hand"


func _hold_transform(spec: Dictionary) -> Transform3D:
	var pose := _hold_pose_for(spec)
	var default_rotation := Vector3.ZERO
	match pose:
		"tablet", "inspect": default_rotation = Vector3(deg_to_rad(-12.0), 0.0, deg_to_rad(7.0))
		"basket": default_rotation = Vector3(0.0, 0.0, deg_to_rad(-4.0))
		"large", "crate": default_rotation = Vector3(0.0, deg_to_rad(4.0), 0.0)
	var rotation := _dict_vector3(spec, "hold_rotation", default_rotation)
	var offset := _dict_vector3(spec, "hold_offset", Vector3.ZERO)
	return Transform3D(Basis.from_euler(rotation), offset)


func _create_item_visual(item_id: String, spec: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "Held_" + _safe_node_name(item_id)
	root.set_meta("lesson2_item_id", item_id)
	var model := Node3D.new()
	model.name = "Model"
	root.add_child(model)
	model.scale = _dict_vector3(spec, "visual_scale", Vector3.ONE)
	var primary := _dict_color(spec, "color", Color(0.63, 0.39, 0.18))
	var accent := _dict_color(spec, "accent_color", Color(0.86, 0.67, 0.3))
	var dark := primary.darkened(0.34)
	var primary_material := _material(primary, 0.82)
	var accent_material := _material(accent, 0.72)
	var dark_material := _material(dark, 0.9)
	match str(spec.get("shape", "bundle")):
		"basket": _build_basket(model, primary_material, accent_material, dark_material)
		"tablet": _build_tablet(model, primary_material, accent_material, dark_material)
		"crate": _build_crate(model, primary_material, accent_material, dark_material)
		"amphora": _build_amphora(model, primary_material, accent_material, dark_material)
		"tool": _build_tool(model, primary_material, accent_material, dark_material)
		"marker": _build_marker(model, primary_material, accent_material, dark_material)
		"mask": _build_mask(model, primary_material, accent_material, dark_material)
		"model": _build_city_model(model, primary_material, accent_material, dark_material)
		_: _build_bundle(model, primary_material, accent_material, dark_material)
	return root


func _build_basket(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_cylinder(parent, 0.25, 0.34, Vector3(0, 0, 0), primary)
	_add_cylinder(parent, 0.27, 0.055, Vector3(0, -0.16, 0), dark)
	for index in range(5):
		var angle := TAU * float(index) / 5.0
		_add_sphere(
			parent,
			0.105,
			Vector3(cos(angle) * 0.14, 0.16, sin(angle) * 0.14),
			accent
		)
	# Two restrained uprights read as a basket handle without a costly curve mesh.
	_add_cylinder(parent, 0.025, 0.48, Vector3(-0.22, 0.21, 0), dark)
	_add_cylinder(parent, 0.025, 0.48, Vector3(0.22, 0.21, 0), dark)
	_add_cylinder(
		parent, 0.025, 0.46, Vector3(0, 0.44, 0), dark, Vector3(0, 0, PI * 0.5)
	)


func _build_tablet(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_box(parent, Vector3(0.56, 0.07, 0.39), Vector3.ZERO, primary)
	_add_box(parent, Vector3(0.46, 0.025, 0.29), Vector3(0, 0.047, 0), accent)
	for row in range(3):
		_add_box(
			parent,
			Vector3(0.34 - row * 0.035, 0.014, 0.018),
			Vector3(-0.025, 0.066, -0.095 + row * 0.09),
			dark
		)


func _build_crate(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_box(parent, Vector3(0.62, 0.46, 0.5), Vector3.ZERO, primary)
	for x in [-0.27, 0.27]:
		_add_box(parent, Vector3(0.055, 0.52, 0.56), Vector3(x, 0, 0), dark)
	for y in [-0.19, 0.19]:
		_add_box(parent, Vector3(0.68, 0.055, 0.56), Vector3(0, y, 0), accent)


func _build_amphora(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_sphere(parent, 0.28, Vector3(0, -0.01, 0), primary, Vector3(1, 1.22, 1))
	_add_cylinder(parent, 0.105, 0.28, Vector3(0, 0.34, 0), primary)
	_add_cylinder(parent, 0.145, 0.055, Vector3(0, 0.49, 0), accent)
	_add_cylinder(parent, 0.075, 0.18, Vector3(0, -0.38, 0), dark)
	for side in [-1.0, 1.0]:
		_add_cylinder(
			parent,
			0.026,
			0.38,
			Vector3(side * 0.25, 0.24, 0),
			dark,
			Vector3(0, 0, side * deg_to_rad(24.0))
		)


func _build_tool(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_cylinder(
		parent, 0.045, 0.72, Vector3(0, 0, 0), primary, Vector3(0, 0, PI * 0.5)
	)
	_add_box(parent, Vector3(0.24, 0.16, 0.14), Vector3(0.34, 0, 0), dark)
	_add_box(parent, Vector3(0.08, 0.18, 0.16), Vector3(-0.34, 0, 0), accent)


func _build_marker(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_cylinder(parent, 0.2, 0.12, Vector3(0, -0.18, 0), dark)
	_add_cylinder(parent, 0.055, 0.55, Vector3(0, 0.12, 0), primary)
	_add_box(parent, Vector3(0.34, 0.28, 0.07), Vector3(0, 0.42, 0), accent)


func _build_mask(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_sphere(parent, 0.31, Vector3.ZERO, primary, Vector3(0.82, 1.08, 0.32))
	for x in [-0.11, 0.11]:
		_add_sphere(parent, 0.052, Vector3(x, 0.07, 0.095), dark, Vector3(1.2, 0.72, 0.35))
	_add_box(parent, Vector3(0.17, 0.035, 0.035), Vector3(0, -0.13, 0.105), accent)


func _build_city_model(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	_add_box(parent, Vector3(0.68, 0.09, 0.52), Vector3(0, -0.18, 0), dark)
	_add_box(parent, Vector3(0.26, 0.25, 0.2), Vector3(-0.18, -0.01, 0.07), primary)
	_add_box(parent, Vector3(0.22, 0.19, 0.18), Vector3(0.2, -0.04, -0.1), accent)
	for x in [-0.25, 0.25]:
		_add_cylinder(parent, 0.032, 0.28, Vector3(x, 0.0, -0.16), primary)


func _build_bundle(parent: Node3D, primary: Material, accent: Material, dark: Material) -> void:
	for index in range(3):
		_add_cylinder(
			parent,
			0.1,
			0.58,
			Vector3(0, (index - 1) * 0.13, 0),
			primary if index != 1 else accent,
			Vector3(0, 0, PI * 0.5)
		)
	_add_box(parent, Vector3(0.07, 0.48, 0.25), Vector3.ZERO, dark)


func _add_box(
	parent: Node3D,
	size: Vector3,
	position_value: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add_mesh(parent, mesh, position_value, material, rotation_value)


func _add_cylinder(
	parent: Node3D,
	radius: float,
	height: float,
	position_value: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	return _add_mesh(parent, mesh, position_value, material, rotation_value)


func _add_sphere(
	parent: Node3D,
	radius: float,
	position_value: Vector3,
	material: Material,
	scale_value: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var result := _add_mesh(parent, mesh, position_value, material)
	result.scale = scale_value
	return result


func _add_mesh(
	parent: Node3D,
	mesh: PrimitiveMesh,
	position_value: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position_value
	instance.rotation = rotation_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.08
	return material


func _dict_vector3(source: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = source.get(key, fallback)
	return value as Vector3 if value is Vector3 else fallback


func _dict_color(source: Dictionary, key: String, fallback: Color) -> Color:
	var value: Variant = source.get(key, fallback)
	return value as Color if value is Color else fallback


func _safe_node_name(value: String) -> String:
	var result := value.strip_edges().replace(" ", "_").replace("/", "_").replace(":", "_")
	return result if not result.is_empty() else "Item"
