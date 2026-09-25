extends SceneTree

const SHOWCASE := "res://scenes/debug/character_visual_showcase.tscn"

const EXPECTED_PROFILES := {
	"CivilianRow/PlayerMessenger": "player_messenger",
	"CivilianRow/Teacher": "teacher_elder",
	"CivilianRow/TempleAttendant": "temple_attendant",
	"CivilianRow/AthenianCitizen": "athenian_citizen",
	"CivilianRow/AthenianElder": "athenian_elder",
	"MilitaryRow/SpartanTrainer": "spartan_trainer",
	"MilitaryRow/SpartanHopliteA": "spartan_hoplite",
	"MilitaryRow/SpartanHopliteB": "spartan_hoplite",
	"MilitaryRow/MacedonianOfficer": "macedonian_officer",
	"MilitaryRow/Alexander": "alexander",
	"MilitaryRow/MacedonianSoldier": "macedonian_soldier",
	"AmbientRow/VillagerYouth": "villager_youth",
	"AmbientRow/VillagerMerchant": "villager_merchant",
	"AmbientRow/VillagerCivic": "villager_civic",
}

const EXPECTED_DETAILS := {
	"CivilianRow/PlayerMessenger": ["MessengerStrapInlay", "PouchFlap", "WaistBuckle"],
	"CivilianRow/Teacher": ["ScholarScroll", "ScholarMantleBorder", "ScholarClasp"],
	"CivilianRow/TempleAttendant": ["HeadFillet", "TempleMedallion", "TempleCollar"],
	"CivilianRow/AthenianCitizen": ["HeadFillet", "CivicBrooch", "CivicMantleChain"],
	"CivilianRow/AthenianElder": ["ScholarScroll", "AgeLineR", "ScholarClasp"],
	"MilitaryRow/SpartanTrainer": ["CuirassCollar", "ShieldBoss", "CommandMantleClasp"],
	"MilitaryRow/SpartanHopliteA": ["CuirassPanelL", "HelmetDome", "ShieldBoss"],
	"MilitaryRow/SpartanHopliteB": ["CuirassPanelR", "ShortBeard", "CuirassWaistSeal"],
	"MilitaryRow/MacedonianOfficer": ["CuirassAbdomenBand", "ShieldBoss", "CommandRankBar"],
	"MilitaryRow/Alexander": ["CuirassLowerTrim", "DiademSeal", "RoyalSunDisk"],
	"MilitaryRow/MacedonianSoldier": ["CuirassCollar", "HelmetDome", "CuirassWaistSeal"],
	"AmbientRow/VillagerYouth": ["PouchFlap", "YouthShoulderToggle", "WaistBuckle"],
	"AmbientRow/VillagerMerchant": ["MessengerStrapInlay", "ScholarScroll", "MerchantSeal"],
	"AmbientRow/VillagerCivic": ["CivicBrooch", "CivicMantleChain", "WaistBuckle"],
}

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run_audit")


func _run_audit() -> void:
	var packed := load(SHOWCASE) as PackedScene
	_check(packed != null, "showcase scene loads")
	if packed == null:
		_finish()
		return
	var showcase := packed.instantiate()
	root.add_child(showcase)
	for frame in 4:
		await process_frame

	for node_path in EXPECTED_PROFILES:
		var character := showcase.get_node_or_null(node_path)
		_check(character != null, "%s exists" % node_path)
		if character == null:
			continue
		var visual := character.get_node_or_null("Visual") as GeneratedCharacterVisual
		_check(visual != null, "%s has GeneratedCharacterVisual" % node_path)
		if visual == null:
			continue
		_check(
			absf(wrapf(visual.rotation.y, -PI, PI)) < 0.01,
			"%s uses the canonical forward-facing visual axis" % node_path
		)
		_check(
			visual.get_appearance_profile_name() == EXPECTED_PROFILES[node_path],
			"%s resolves profile %s" % [node_path, EXPECTED_PROFILES[node_path]]
		)
		var animation_player := _find_animation_player(visual)
		_check(animation_player != null, "%s has AnimationPlayer" % node_path)
		if animation_player != null:
			for required_animation in [&"Idle", &"Walk", &"Run"]:
				_check(
					animation_player.has_animation(required_animation),
					"%s retains %s" % [node_path, required_animation]
				)
		var role_detail_count := _count_primitive_meshes(visual)
		_check(
			role_detail_count <= 40,
			"%s stays within the 40-piece role-detail budget" % node_path
		)
		for detail_name in EXPECTED_DETAILS[node_path]:
			var detail := _find_descendant(visual, detail_name) as Node3D
			_check(detail != null, "%s includes %s" % [node_path, detail_name])
			if detail != null:
				_check(
					detail.get_parent() is BoneAttachment3D,
					"%s keeps %s bone-attached" % [node_path, detail_name]
				)
				_check(
					_is_finite_transform(detail.transform),
					"%s gives %s a finite local transform" % [node_path, detail_name]
				)
		visual.set_conversation_state(true, 1)
		visual.set_conversation_state(false, 2)
		visual.clear_conversation_state()

	_finish()


func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _find_descendant(node: Node, target_name: String) -> Node:
	if str(node.name) == target_name:
		return node
	for child in node.get_children():
		var found := _find_descendant(child, target_name)
		if found != null:
			return found
	return null


func _is_finite_transform(value: Transform3D) -> bool:
	var samples := [
		value.origin.x, value.origin.y, value.origin.z,
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
	]
	for sample in samples:
		if is_nan(sample) or is_inf(sample):
			return false
	return true


func _count_primitive_meshes(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh is PrimitiveMesh:
		count += 1
	for child in node.get_children():
		count += _count_primitive_meshes(child)
	return count


func _finish() -> void:
	if _failures.is_empty():
		print("CHARACTER_ASSET_AUDIT: PASS (%d profiles, rigs and details)" % EXPECTED_PROFILES.size())
		quit()
		return
	for failure in _failures:
		push_error("CHARACTER_ASSET_AUDIT: " + failure)
	print("CHARACTER_ASSET_AUDIT: FAIL (%d problems)" % _failures.size())
	quit(1)
