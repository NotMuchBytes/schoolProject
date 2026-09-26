extends Node

var _failed := false
var _level: Node3D
var _held: Lesson2HeldObjectSystem


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 8.0
	GameFlow.story_flags["lesson2_stage"] = "industry_task"
	var packed := load("res://scenes/levels/lesson2_level.tscn") as PackedScene
	_check(packed != null, "Lesson 2 scene loads for physical-interaction QA")
	if packed == null:
		_finish()
		return
	_level = packed.instantiate() as Node3D
	add_child(_level)
	await _wait_frames(5)
	_held = _level.get_node_or_null("Player/HeldObjectSystem") as Lesson2HeldObjectSystem
	_check(_held != null, "held-object system is attached to the player")
	if _held == null:
		_finish()
		return

	var wood := _spot("industry_wood")
	var ship := _spot("industry_ship")
	var tools := _spot("industry_tools")
	_level.call("_activate_spot", wood)
	await _wait_seconds(0.46)
	_check(_held.is_holding() and _held.held_item_id == "industry_wood", "pickup produces a visible held wood bundle")
	var environment := _level.get_node("Lesson2CityEnvironment")
	var apollo_display := environment.get_node_or_null("DeityDisplayApollo") as Node3D
	_check(apollo_display != null, "Apollo has a permanent central temple display")
	if apollo_display != null:
		var apollo_name := apollo_display.get_node_or_null("NameArabic") as Label3D
		var apollo_role := apollo_display.get_node_or_null("RoleArabic") as Label3D
		_check(apollo_name != null and apollo_name.text == "أبولو", "Apollo's Arabic name is clearly authored")
		_check(apollo_role != null and apollo_role.text == "إله الشمس", "Apollo's textbook role is clearly authored")
		_check(apollo_display.get_node_or_null("ApolloFigure/SunDisk") != null, "Apollo is visually identified by a sun emblem")
	_check(_level.get_node_or_null("GuidedJourneyRoute") == null, "ground route lines and arrows are removed")
	var primary_spots: Array[Lesson2InteractionSpot] = []
	for spot_variant in (_level.get("_spots") as Dictionary).values():
		var candidate := spot_variant as Lesson2InteractionSpot
		if candidate.is_primary_guidance():
			primary_spots.append(candidate)
	_check(primary_spots.size() == 1, "exactly one current interactable receives guidance")
	if primary_spots.size() == 1:
		_check(primary_spots[0].marker.visible and primary_spots[0].marker.text == "!", "current interactable uses the same exclamation marker as NPCs")
	var journey_label := _level.get_node_or_null(
		"GameHUD/ObjectivePanel/Margin/VBox/StoryProgress"
	) as Label
	_check(journey_label != null and journey_label.visible and not journey_label.text.is_empty(), "HUD visibly shows location and chapter progress without opening a menu")
	var source_visual := environment.call("get_mission_prop_anchor", "industry_wood") as Node3D
	_check(source_visual != null and not source_visual.visible, "portable source disappears physically instead of duplicating into inventory")
	var held_visual := _held.get_held_visual()
	_check(held_visual != null and "HoldAnchors" in str(held_visual.get_path()), "held visual is parented to an authored body anchor")
	_check(ship.is_placement_preview_visible(), "correct workshop station receives a placement preview")
	_check(not tools.is_placement_preview_visible(), "unrelated station is not covered by a giant marker")
	_check(not tools.marker.visible, "non-current interactables do not broadcast world markers")
	_check(held_visual == null or held_visual.find_children("*", "RigidBody3D", true, false).is_empty(), "carried item uses stable visual-only motion without rigid-body jitter")

	_level.call("_activate_spot", tools)
	_check(str(_level.get("_carried_item")) == "industry_wood" and _held.is_holding(), "wrong station gives a retry and never destroys the carried item")
	_level.call("_activate_spot", ship)
	await _wait_seconds(0.52)
	_check(not _held.is_holding() and str(_level.get("_carried_item")).is_empty(), "correct placement releases the item exactly once")
	var placed := _held.get_placed_visuals("industry_wood")
	_check(placed.size() == 1, "placed item remains visibly present at its workstation")
	if not placed.is_empty():
		var placed_visual := placed[0] as Node3D
		_check(str(placed_visual.get_meta("lesson2_target_id", "")) == "industry_ship", "placed visual records its snapped target")
		_check(placed_visual.global_position.distance_to(ship.global_position) < 1.5, "placed visual snaps within a forgiving target footprint")

	var metal := _spot("industry_metal")
	_level.call("_activate_spot", metal)
	await _wait_seconds(0.18)
	_level.call("_reset_task")
	await _wait_seconds(0.30)
	_check(not _held.is_holding() and str(_level.get("_carried_item")).is_empty(), "mission reset safely recovers an in-flight carried object")

	var clay := _spot("industry_clay")
	clay.set_interaction_enabled(true)
	var player := _level.get_node("Player") as PlayerController
	player.global_position = clay.global_position + Vector3(10.0, 0.0, 0.0)
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	player.snap_camera_after_teleport()
	clay.set_primary_guidance(true)
	await _wait_frames(3)
	_check(clay.marker.visible and clay.marker.text == "!", "current-objective guidance uses one clear exclamation marker")

	for action_id in ["farm_mill", "farm_press", "society_display", "theatre_stage", "arch_model", "jordan_map"]:
		_check(environment.call("get_mission_prop_anchor", action_id) != null, "animated world mechanism exists: " + action_id)
	await get_tree().physics_frame
	_check_ramp_profile(
		"trade quay",
		Vector3(13.25, 0, -12.5), Vector3(14.6, 0, -12.5), Vector3(15.95, 0, -12.5), 0.36
	)
	_check_ramp_profile(
		"architecture viewpoint",
		# Sample beside the builder's CharacterBody at the centre landing.
		Vector3(1.5, 0, -55.05), Vector3(1.5, 0, -56.55), Vector3(1.5, 0, -58.05), 0.70
	)
	_check_ramp_profile(
		"Jordan archive",
		Vector3(9.5, 0, -58.35), Vector3(9.5, 0, -59.7), Vector3(9.5, 0, -61.05), 0.50
	)
	var active_task_props := 0
	for citizen in _level.get_node("AmbientPopulation").get_children():
		if citizen.find_child("AmbientTaskProp", true, false) != null:
			active_task_props += 1
	_check(active_task_props >= 4, "ambient workers visibly carry, inspect, or use tools")
	var mesh_count := _level.find_children("*", "MeshInstance3D", true, false).size()
	print("LESSON2_QUALITY_VISIBLE_MESHES: ", mesh_count)
	_check(mesh_count <= 1800, "Lesson 2 visual density remains inside the alpha mesh-node budget")
	_finish()


func _spot(id: String) -> Lesson2InteractionSpot:
	return _level.get("_spots").get(id) as Lesson2InteractionSpot


func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _wait_frames(count: int) -> void:
	for _frame in range(count):
		await get_tree().process_frame


func _check_ramp_profile(label: String, bottom: Vector3, middle: Vector3, top: Vector3, expected_rise: float) -> void:
	var bottom_height := _floor_height(bottom)
	var middle_height := _floor_height(middle)
	var top_height := _floor_height(top)
	var continuous := (
		bottom_height > -10.0
		and middle_height > bottom_height + 0.08
		and top_height > middle_height + 0.08
		and absf(top_height - expected_rise) < 0.16
	)
	_check(continuous, "%s has a continuous walkable collision ramp (%.2f -> %.2f -> %.2f)" % [label, bottom_height, middle_height, top_height])


func _floor_height(position_value: Vector3) -> float:
	var query := PhysicsRayQueryParameters3D.create(
		position_value + Vector3.UP * 3.0,
		position_value + Vector3.DOWN * 1.0
	)
	query.collide_with_areas = false
	var hit := _level.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return -100.0
	var hit_position: Vector3 = hit.get("position", Vector3.DOWN * 100.0)
	return hit_position.y


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failed = true
		push_error("FAIL: " + message)


func _finish() -> void:
	Engine.time_scale = 1.0
	print("LESSON2_INTERACTION_QUALITY_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)
