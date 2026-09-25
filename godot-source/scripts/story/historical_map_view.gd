class_name HistoricalMapView
extends Control

## Cinematic presentation for the supplied authoritative historical map.
## The geography, labels, route, and successor territories are taken directly
## from the approved reference image; this script only adds camera and focus FX.

const REFERENCE_MAP: Texture2D = preload("res://assets/reference/alexander_empire_map.png")
const MAP_COLOR_SHADER: Shader = preload("res://shaders/historical_map_color.gdshader")
const GOLD := Color(1.0, 0.70, 0.28, 1.0)
const ROUTE_RED := Color(0.78, 0.045, 0.035, 1.0)
const CAMPAIGN_AMBER := Color(0.80, 0.43, 0.16, 0.48)
const ANTIGONUS_GREEN := Color(0.18, 0.52, 0.29, 0.70)
const PTOLEMY_PURPLE := Color(0.48, 0.22, 0.60, 0.70)
const SELEUCUS_CORAL := Color(0.89, 0.35, 0.40, 0.68)

var route_progress: float = 0.0:
	set(value):
		route_progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var division_stage: int = 0:
	set(value):
		division_stage = clampi(value, 0, 3)
		queue_redraw()

var hellenistic_blend: float = 0.0:
	set(value):
		hellenistic_blend = clampf(value, 0.0, 1.0)
		queue_redraw()

var atmosphere_darken: float = 0.0:
	set(value):
		atmosphere_darken = clampf(value, 0.0, 1.0)
		queue_redraw()

var confrontation_progress: float = 0.0:
	set(value):
		confrontation_progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var camera_center: Vector2 = Vector2(0.5, 0.5):
	set(value):
		camera_center = Vector2(clampf(value.x, 0.0, 1.0), clampf(value.y, 0.0, 1.0))
		queue_redraw()

var camera_zoom: float = 1.0:
	set(value):
		camera_zoom = clampf(value, 0.9, 2.15)
		queue_redraw()

var antigonus_blend: float = 0.0:
	set(value):
		antigonus_blend = clampf(value, 0.0, 1.0)
		queue_redraw()

var ptolemy_blend: float = 0.0:
	set(value):
		ptolemy_blend = clampf(value, 0.0, 1.0)
		queue_redraw()

var seleucus_blend: float = 0.0:
	set(value):
		seleucus_blend = clampf(value, 0.0, 1.0)
		queue_redraw()

var _active_tween: Tween
var _fast_forward_requested := false
var _mode := "campaign"
var _pulse_time := 0.0
var _map_material: ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_material = ShaderMaterial.new()
	_map_material.shader = MAP_COLOR_SHADER
	material = _map_material
	_update_map_shader()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta
	_update_map_shader()
	queue_redraw()


func reset_campaign() -> void:
	_mode = "campaign"
	route_progress = 0.0
	division_stage = 0
	hellenistic_blend = 0.0
	atmosphere_darken = 0.0
	confrontation_progress = 0.0
	antigonus_blend = 0.0
	ptolemy_blend = 0.0
	seleucus_blend = 0.0
	camera_center = Vector2(0.15, 0.29)
	camera_zoom = 1.72


func uses_reference_image() -> bool:
	return REFERENCE_MAP != null


func get_reference_image_path() -> String:
	return REFERENCE_MAP.resource_path


func animate_campaign_to(target_progress: float, duration: float = 2.2) -> void:
	await animate_campaign_stage(target_progress, camera_center, camera_zoom, duration)


func animate_campaign_stage(
	target_progress: float,
	focus: Vector2,
	zoom: float,
	duration: float = 2.4
) -> void:
	_fast_forward_requested = false
	_active_tween = create_tween().set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "route_progress", target_progress, duration)
	_active_tween.tween_property(self, "camera_center", focus, duration)
	_active_tween.tween_property(self, "camera_zoom", zoom, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		route_progress = target_progress
		camera_center = focus
		camera_zoom = zoom


func animate_camera_to(focus: Vector2, zoom: float, duration: float = 1.8) -> void:
	_fast_forward_requested = false
	_active_tween = create_tween().set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "camera_center", focus, duration)
	_active_tween.tween_property(self, "camera_zoom", zoom, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		camera_center = focus
		camera_zoom = zoom


func set_division(new_stage: int) -> void:
	_mode = "division"
	route_progress = 0.0
	hellenistic_blend = 0.0
	division_stage = new_stage
	antigonus_blend = 1.0 if division_stage >= 1 else 0.0
	ptolemy_blend = 1.0 if division_stage >= 2 else 0.0
	seleucus_blend = 1.0 if division_stage >= 3 else 0.0


func animate_division_to(new_stage: int, duration: float = 2.2) -> void:
	_mode = "division"
	division_stage = new_stage
	_fast_forward_requested = false
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	match division_stage:
		1:
			_active_tween.tween_property(self, "antigonus_blend", 1.0, duration)
		2:
			_active_tween.tween_property(self, "ptolemy_blend", 1.0, duration)
		3:
			_active_tween.tween_property(self, "seleucus_blend", 1.0, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		antigonus_blend = 1.0 if division_stage >= 1 else antigonus_blend
		ptolemy_blend = 1.0 if division_stage >= 2 else ptolemy_blend
		seleucus_blend = 1.0 if division_stage >= 3 else seleucus_blend


func animate_hellenistic_blend(duration: float = 2.8) -> void:
	_mode = "hellenistic"
	division_stage = 3
	antigonus_blend = 1.0
	ptolemy_blend = 1.0
	seleucus_blend = 1.0
	_fast_forward_requested = false
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "hellenistic_blend", 1.0, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		hellenistic_blend = 1.0


func animate_persian_confrontation(duration: float = 4.2) -> void:
	confrontation_progress = 0.0
	_fast_forward_requested = false
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "confrontation_progress", 1.0, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		confrontation_progress = 1.0


func animate_atmosphere_darken(target: float, duration: float = 1.4) -> void:
	_fast_forward_requested = false
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(self, "atmosphere_darken", target, duration)
	await _await_active_tween()
	if _fast_forward_requested:
		atmosphere_darken = target


func fast_forward_active_animation() -> void:
	_fast_forward_requested = true
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()


func get_campaign_route_points() -> Array[Vector2]:
	return _campaign_route().duplicate()


func _await_active_tween() -> void:
	while _active_tween != null and _active_tween.is_running() and not _fast_forward_requested:
		await get_tree().process_frame


func _update_map_shader() -> void:
	if _map_material == null:
		return
	_map_material.set_shader_parameter("campaign_mode", 1.0 if _mode == "campaign" else 0.0)
	_map_material.set_shader_parameter("route_progress", route_progress)
	_map_material.set_shader_parameter("antigonus_blend", antigonus_blend)
	_map_material.set_shader_parameter("ptolemy_blend", ptolemy_blend)
	_map_material.set_shader_parameter("seleucus_blend", seleucus_blend)


func _draw() -> void:
	if REFERENCE_MAP == null or size.x <= 1.0 or size.y <= 1.0:
		return
	var map_rect := _camera_map_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.012, 0.006, 1.0))
	draw_texture_rect(REFERENCE_MAP, map_rect, false)
	if _mode == "campaign" and route_progress > 0.001:
		_draw_campaign_route(map_rect)
	draw_rect(map_rect, Color(0.86, 0.62, 0.26, 0.75), false, 2.0)

	# The supplied image remains the visible map. These overlays only direct the
	# eye during the guided sequence and never replace or redraw its geography.
	if confrontation_progress > 0.001 and confrontation_progress < 1.0:
		_draw_focus_marker(Vector2(0.34, 0.35), Color(0.94, 0.24, 0.12, 1.0))

	if hellenistic_blend > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.38, 0.18, 0.30, 0.10 * hellenistic_blend))

	if atmosphere_darken > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.008, 0.016, 0.68 * atmosphere_darken))
		_draw_focus_marker(Vector2(0.455, 0.48), Color(1.0, 0.48, 0.18, 1.0), 1.35)

	_draw_vignette()


func _draw_historical_regions(map_rect: Rect2) -> void:
	var asia_minor := _map_polygon(map_rect, [
		Vector2(0.125, 0.19), Vector2(0.19, 0.19), Vector2(0.23, 0.17),
		Vector2(0.32, 0.19), Vector2(0.345, 0.27), Vector2(0.34, 0.32),
		Vector2(0.29, 0.37), Vector2(0.23, 0.39), Vector2(0.17, 0.34),
		Vector2(0.14, 0.29)
	])
	var egypt := _map_polygon(map_rect, [
		Vector2(0.0, 0.52), Vector2(0.03, 0.50), Vector2(0.065, 0.55),
		Vector2(0.14, 0.55), Vector2(0.205, 0.55), Vector2(0.225, 0.59),
		Vector2(0.215, 0.65), Vector2(0.25, 0.70), Vector2(0.275, 0.84),
		Vector2(0.32, 1.0), Vector2(0.0, 1.0)
	])
	var ptolemaic_levant := _map_polygon(map_rect, [
		Vector2(0.235, 0.34), Vector2(0.275, 0.34), Vector2(0.31, 0.37),
		Vector2(0.33, 0.47), Vector2(0.31, 0.55), Vector2(0.275, 0.60),
		Vector2(0.235, 0.56), Vector2(0.225, 0.46)
	])
	var northern_levant := _map_polygon(map_rect, [
		Vector2(0.275, 0.30), Vector2(0.345, 0.28), Vector2(0.39, 0.33),
		Vector2(0.42, 0.42), Vector2(0.39, 0.52), Vector2(0.345, 0.57),
		Vector2(0.31, 0.51), Vector2(0.32, 0.41)
	])
	var mesopotamia := _map_polygon(map_rect, [
		Vector2(0.34, 0.25), Vector2(0.43, 0.25), Vector2(0.50, 0.31),
		Vector2(0.56, 0.40), Vector2(0.53, 0.52), Vector2(0.48, 0.60),
		Vector2(0.42, 0.57), Vector2(0.37, 0.51), Vector2(0.35, 0.40)
	])
	var persia := _map_polygon(map_rect, [
		Vector2(0.50, 0.34), Vector2(0.57, 0.30), Vector2(0.64, 0.22),
		Vector2(0.72, 0.20), Vector2(0.78, 0.24), Vector2(0.84, 0.20),
		Vector2(0.91, 0.18), Vector2(0.97, 0.21), Vector2(1.0, 0.42),
		Vector2(0.94, 0.50), Vector2(0.90, 0.70), Vector2(0.84, 0.73),
		Vector2(0.78, 0.70), Vector2(0.72, 0.66), Vector2(0.65, 0.72),
		Vector2(0.59, 0.68), Vector2(0.53, 0.61), Vector2(0.48, 0.55)
	])

	if _mode == "campaign":
		_draw_region(asia_minor, CAMPAIGN_AMBER, _progress_between(0.02, 0.22))
		_draw_region(egypt, CAMPAIGN_AMBER, _progress_between(0.24, 0.40))
		_draw_region(ptolemaic_levant, CAMPAIGN_AMBER, _progress_between(0.16, 0.34))
		_draw_region(northern_levant, CAMPAIGN_AMBER, _progress_between(0.38, 0.52))
		_draw_region(mesopotamia, CAMPAIGN_AMBER, _progress_between(0.42, 0.66))
		_draw_region(persia, CAMPAIGN_AMBER, _progress_between(0.55, 0.92))
	else:
		_draw_region(asia_minor, ANTIGONUS_GREEN, antigonus_blend)
		_draw_region(egypt, PTOLEMY_PURPLE, ptolemy_blend)
		_draw_region(ptolemaic_levant, PTOLEMY_PURPLE, ptolemy_blend)
		_draw_region(northern_levant, SELEUCUS_CORAL, seleucus_blend)
		_draw_region(mesopotamia, SELEUCUS_CORAL, seleucus_blend)
		_draw_region(persia, SELEUCUS_CORAL, seleucus_blend)


func _draw_region(points: PackedVector2Array, base_color: Color, blend: float) -> void:
	if blend <= 0.001:
		return
	var fill := base_color
	fill.a *= clampf(blend, 0.0, 1.0)
	draw_colored_polygon(points, fill)
	var border := Color(base_color.r * 0.62, base_color.g * 0.62, base_color.b * 0.62, 0.9 * blend)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, border, 2.0, true)


func _draw_campaign_route(map_rect: Rect2) -> void:
	var route := _campaign_route()
	var scaled := clampf(route_progress, 0.0, 1.0) * float(route.size() - 1)
	var whole_segments := int(floor(scaled))
	var visible := PackedVector2Array()
	for index in range(whole_segments + 1):
		visible.append(_map_point_in_rect(map_rect, route[index]))
	if whole_segments < route.size() - 1:
		var partial := route[whole_segments].lerp(route[whole_segments + 1], scaled - whole_segments)
		visible.append(_map_point_in_rect(map_rect, partial))
	if visible.size() < 2:
		return
	draw_polyline(visible, Color(0.11, 0.025, 0.018, 0.90), 8.0, true)
	draw_polyline(visible, ROUTE_RED, 4.5, true)
	draw_polyline(visible, Color(1.0, 0.54, 0.24, 0.78), 1.2, true)

	for waypoint_index in range(0, mini(whole_segments + 1, route.size()), 2):
		var waypoint := _map_point_in_rect(map_rect, route[waypoint_index])
		draw_circle(waypoint, 5.0, Color(0.08, 0.02, 0.015, 0.96))
		draw_circle(waypoint, 2.5, Color(1.0, 0.72, 0.35, 1.0))
	for arrow_index in range(3, mini(whole_segments + 1, route.size()), 4):
		_draw_arrowhead(
			_map_point_in_rect(map_rect, route[arrow_index - 1]),
			_map_point_in_rect(map_rect, route[arrow_index])
		)
	_draw_focus_marker(_route_position(route_progress), GOLD)


func _draw_arrowhead(previous: Vector2, tip: Vector2) -> void:
	var direction := (tip - previous).normalized()
	if direction.length_squared() < 0.01:
		return
	var side := Vector2(-direction.y, direction.x)
	var arrow := PackedVector2Array([
		tip,
		tip - direction * 15.0 + side * 7.0,
		tip - direction * 15.0 - side * 7.0
	])
	draw_colored_polygon(arrow, ROUTE_RED)


func _map_polygon(map_rect: Rect2, normalized_points: Array[Vector2]) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in normalized_points:
		result.append(_map_point_in_rect(map_rect, point))
	return result


func _map_point_in_rect(map_rect: Rect2, normalized_position: Vector2) -> Vector2:
	return map_rect.position + normalized_position * map_rect.size


func _progress_between(start: float, finish: float) -> float:
	return smoothstep(start, finish, route_progress)


func _camera_map_rect() -> Rect2:
	var texture_size := REFERENCE_MAP.get_size()
	var fit_scale := minf(size.x / texture_size.x, size.y / texture_size.y)
	var fitted_size := texture_size * fit_scale
	var zoomed_size := fitted_size * camera_zoom
	var position := size * 0.5 - Vector2(
		camera_center.x * zoomed_size.x,
		camera_center.y * zoomed_size.y
	)
	return Rect2(position, zoomed_size)


func _map_point(normalized_position: Vector2) -> Vector2:
	var map_rect := _camera_map_rect()
	return map_rect.position + normalized_position * map_rect.size


func _draw_focus_marker(normalized_position: Vector2, color: Color, scale: float = 1.0) -> void:
	var center := _map_point(normalized_position)
	var pulse := (10.0 + sin(_pulse_time * 3.5) * 3.0) * scale
	draw_circle(center, pulse * 1.7, Color(color.r, color.g, color.b, 0.12))
	draw_arc(center, pulse, 0.0, TAU, 36, Color(color.r, color.g, color.b, 0.92), 2.4)
	draw_circle(center, 3.5 * scale, Color(1.0, 0.88, 0.54, 0.96))


func _draw_vignette() -> void:
	var edge := minf(size.x, size.y) * 0.045
	var shade := Color(0.0, 0.0, 0.0, 0.22)
	draw_rect(Rect2(0.0, 0.0, size.x, edge), shade)
	draw_rect(Rect2(0.0, size.y - edge, size.x, edge), shade)
	draw_rect(Rect2(0.0, 0.0, edge, size.y), shade)
	draw_rect(Rect2(size.x - edge, 0.0, edge, size.y), shade)


func _route_position(progress: float) -> Vector2:
	var route := _campaign_route()
	if route.is_empty():
		return Vector2(0.5, 0.5)
	var scaled := clampf(progress, 0.0, 1.0) * float(route.size() - 1)
	var index := mini(int(floor(scaled)), route.size() - 1)
	var next_index := mini(index + 1, route.size() - 1)
	return route[index].lerp(route[next_index], scaled - float(index))


func _campaign_route() -> Array[Vector2]:
	# Waypoints are aligned to the supplied block-map geography.
	return [
		Vector2(0.105, 0.255), Vector2(0.16, 0.245), Vector2(0.22, 0.255),
		Vector2(0.275, 0.30), Vector2(0.305, 0.37), Vector2(0.295, 0.47),
		Vector2(0.265, 0.56), Vector2(0.215, 0.585), Vector2(0.145, 0.61),
		Vector2(0.20, 0.64), Vector2(0.265, 0.58), Vector2(0.305, 0.47),
		Vector2(0.335, 0.40), Vector2(0.385, 0.42), Vector2(0.455, 0.46),
		Vector2(0.52, 0.49), Vector2(0.585, 0.45), Vector2(0.65, 0.43),
		Vector2(0.72, 0.38), Vector2(0.79, 0.35), Vector2(0.86, 0.39),
		Vector2(0.905, 0.48), Vector2(0.925, 0.61), Vector2(0.88, 0.68),
		Vector2(0.81, 0.70), Vector2(0.73, 0.66), Vector2(0.65, 0.62),
		Vector2(0.585, 0.58), Vector2(0.52, 0.53), Vector2(0.455, 0.48)
	]
