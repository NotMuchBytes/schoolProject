extends Node

var _failures: int = 0
var _checks: int = 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	GameFlow.reset_story()
	GameFlow.story_flags["village_opening_seen"] = true
	await _audit_level(
		"Village",
		"res://scenes/levels/main_level.tscn",
		[
			Vector3(0, 0, 14), Vector3(0, 0, 3.2), Vector3(0, 0, -12),
			Vector3(0, 0.2, -16), Vector3(0, 1.5, -19), Vector3(0, 3.2, -23),
			Vector3(-29, 0, 15), Vector3(-29, 0, 3.2), Vector3(-29, 0, -21),
			Vector3(29, 0, 15), Vector3(29, 0, 3.2), Vector3(29, 0, -21)
		],
		[
			"VillageEnvironment/MediterraneanSea",
			"VillageEnvironment/DistrictGate_-1PierA",
			"VillageEnvironment/DistrictGate_1PierA",
			"VillageEnvironment/WestDistrictPlaza",
			"VillageEnvironment/EastDistrictPlaza",
			"VillageEnvironment/NorthernMountain00",
			"FallRespawn"
		]
	)
	await _audit_level(
		"City states",
		"res://scenes/levels/city_states_level.tscn",
		[
			Vector3(0, 0, 14), Vector3(0, 0, 0), Vector3(0, 0, -10),
			Vector3(-18, 0, 14), Vector3(18, 0, 14),
			Vector3(-18, 0, -18), Vector3(18, 0, -18),
			Vector3(70, 0, 14), Vector3(70, 0, 0), Vector3(70, 0, -10),
			Vector3(52, 0, 14), Vector3(88, 0, 14),
			Vector3(52, 0, -18), Vector3(88, 0, -18)
		],
		[
			"AthensStage/DistantAcropolisTemple",
			"AthensStage/AthensSideQuarter_-1_00Body",
			"AthensStage/AthenianVotiveMonumentLowerStep",
			"SpartaStage/DistantSpartaBarracks",
			"SpartaStage/SpartaEntryPath00",
			"SpartaStage/OuterTrainingRack_-1_North",
			"FallRespawn"
		]
	)
	await _audit_level(
		"Macedon",
		"res://scenes/levels/macedon_level.tscn",
		[
			Vector3(0, 0, 14), Vector3(0, 0, 4), Vector3(0, 0, -6.3),
			Vector3(-8, 0, 2), Vector3(8, 0, 2),
			Vector3(-18, 0, 14), Vector3(18, 0, 14),
			Vector3(-18, 0, -18), Vector3(18, 0, -18)
		],
		[
			"MacedonStage/NorthCampPalisade",
			"MacedonStage/DistantCommandHall",
			"MacedonStage/CampaignTent_-1_00",
			"MacedonStage/OuterCampaignTent_-1_00",
			"FallRespawn"
		]
	)
	if _failures == 0:
		print("WORLD_ENVIRONMENT_AUDIT: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		push_error("WORLD_ENVIRONMENT_AUDIT: FAIL (%d of %d checks)" % [_failures, _checks])
		get_tree().quit(1)


func _audit_level(
	label: String,
	scene_path: String,
	floor_points: Array,
	required_paths: Array
) -> void:
	var level := (load(scene_path) as PackedScene).instantiate() as Node3D
	add_child(level)
	for _frame in range(8):
		await get_tree().physics_frame
	for path_variant in required_paths:
		var node_path := NodePath(str(path_variant))
		_check(level.get_node_or_null(node_path) != null, "%s has %s" % [label, node_path])
	if label == "City states":
		_audit_npc_patrol_support(level, label + " (Athens)")
	elif label == "Macedon":
		_audit_macedon_tents(level)
	for point_index in range(floor_points.size()):
		if label == "City states" and point_index == 7:
			level.call("_activate_sparta")
			for _frame in range(3):
				await get_tree().physics_frame
		var point_variant: Variant = floor_points[point_index]
		var point: Vector3 = point_variant
		_check(_has_floor(level, point), "%s floor supports %s" % [label, point])
	_audit_npc_patrol_support(
		level,
		label + " (Sparta)" if label == "City states" else label
	)
	var mesh_count := _count_meshes(level)
	_check(mesh_count < 2600, "%s visible scenery stays within mesh budget (%d)" % [label, mesh_count])
	level.queue_free()
	await get_tree().process_frame
	await get_tree().physics_frame


func _audit_macedon_tents(level: Node3D) -> void:
	for tent_path in [
		"MacedonStage/WestCanopy",
		"MacedonStage/OuterCampaignTent_-1_00",
		"MacedonStage/CampaignTent_-1_00",
	]:
		var tent := level.get_node_or_null(tent_path) as Node3D
		_check(tent != null, "Macedon tent exists for shape audit: " + tent_path)
		if tent == null:
			continue
		var west := tent.get_node_or_null("CanvasWest") as Node3D
		var east := tent.get_node_or_null("CanvasEast") as Node3D
		_check(west != null and east != null and west.rotation.z > 0.2 and east.rotation.z < -0.2, "Macedon tent roofs slope down from one central ridge")
		_check(tent.get_node_or_null("FrontGable") is MeshInstance3D and tent.get_node_or_null("RearGable") is MeshInstance3D, "Macedon tent uses triangular canvas ends")
		_check(tent.get_node_or_null("Entrance") != null, "Macedon tent has a readable entrance")


func _audit_npc_patrol_support(level: Node3D, label: String) -> void:
	var moving_npcs: Array[NPCController] = []
	_collect_moving_npcs(level, moving_npcs)
	var visible_count := 0
	for npc in moving_npcs:
		if npc.is_visible_in_tree():
			visible_count += 1
	_check(
		visible_count <= 10,
		"%s simultaneous character population stays within budget (%d)" % [label, visible_count]
	)
	for npc in moving_npcs:
		if not npc.patrol_enabled or npc.patrol_offsets.is_empty():
			continue
		for waypoint_index in npc.patrol_offsets.size():
			var waypoint := npc.global_position + npc.patrol_offsets[waypoint_index]
			_check(
				_has_floor(level, waypoint),
				"%s supports %s patrol waypoint %d" % [label, npc.name, waypoint_index]
			)


func _collect_moving_npcs(node: Node, output: Array[NPCController]) -> void:
	if node is NPCController and (node as Node3D).is_visible_in_tree():
		output.append(node as NPCController)
	for child in node.get_children():
		_collect_moving_npcs(child, output)


func _has_floor(level: Node3D, point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		point + Vector3.UP * 5.0,
		point + Vector3.DOWN * 5.0,
		1
	)
	var player := level.get_node_or_null("Player") as CollisionObject3D
	if player != null:
		query.exclude = [player.get_rid()]
	query.collide_with_areas = false
	return not level.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _count_meshes(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).is_visible_in_tree():
		count = 1
	for child in node.get_children():
		count += _count_meshes(child)
	return count


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		print("PASS: ", message)
		return
	_failures += 1
	push_error("FAIL: " + message)
