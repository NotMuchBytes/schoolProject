extends Node

var _failed := false
var _level: Node3D
var _ui: Lesson2ActivityUI


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 35.0
	GameFlow.story_flags["lesson2_stage"] = "intro"
	var packed := load("res://scenes/levels/lesson2_level.tscn") as PackedScene
	_check(packed != null, "Lesson 2 scene loads")
	if packed == null:
		_finish()
		return
	_level = packed.instantiate() as Node3D
	add_child(_level)
	await _wait_frames(3)
	_ui = _level.get_node("Lesson2ActivityUI") as Lesson2ActivityUI
	_test_content_and_world()
	await _run_complete_route()
	_finish()


func _test_content_and_world() -> void:
	var lines := Lesson2Content.all_lines()
	var ids: Dictionary = {}
	var prefixes: Dictionary = {}
	var clean := lines.size() == 58
	for line_variant in lines:
		var line: Dictionary = line_variant
		var id := str(line.get("line_id", ""))
		clean = clean and id.begins_with("l2_") and not ids.has(id)
		clean = clean and str(line.get("audio_path", "")).is_empty()
		clean = clean and not str(line.get("text_ar", "")).is_empty()
		ids[id] = true
		prefixes[id.get_slice("_", 1)] = true
	_check(clean, "58 unique Arabic l2 lines have optional empty audio paths")
	for required in ["intro", "politics", "farm", "workshop", "trade", "society", "religion", "theatre", "ideas", "architecture", "sport", "jordan", "ending", "ambient"]:
		_check(prefixes.has(required), "dialogue coverage: " + required)
	var spots := get_tree().get_nodes_in_group("lesson2_spot").filter(func(node: Node): return _level.is_ancestor_of(node))
	_check(spots.size() == 63, "connected city exposes all 63 physical mission spots")
	for required_spot in ["politics_display", "farm_mill", "farm_press", "trade_dock_follow", "society_display", "theatre_stage", "arch_model", "sport_cp_3", "jordan_marker_tray", "jordan_qasr", "final_board"]:
		_check(_spot(required_spot) != null, "physical mission spot exists: " + required_spot)
	_check(_level.get_node_or_null("Lesson2CityEnvironment/GroundBody") != null, "continuous ground has collision")
	_check(_level.get_node_or_null("Lesson2CityEnvironment/TheatreStageBody") != null, "theatre stage has collision")
	_check(_level.get_node_or_null("Lesson2CityEnvironment/JordanArchiveBody") != null, "Jordan archive has collision")
	_check(_level.get_node_or_null("FallRespawn") != null, "fall-respawn protection is present")
	var held_system := _level.get_node_or_null("Player/HeldObjectSystem")
	_check(held_system != null and held_system.has_method("pickup_item") and held_system.has_method("place_item"), "reusable visible held-object system is active")
	var ambient_population := _level.get_node_or_null("AmbientPopulation")
	_check(ambient_population != null and ambient_population.get_child_count() == 6, "six moving ambient citizens populate the working districts")
	if ambient_population != null:
		for citizen in ambient_population.get_children():
			_check(bool(citizen.get("patrol_enabled")), "ambient citizen patrols: " + citizen.name)
			var authored_ids: PackedStringArray = citizen.get("lesson2_line_ids")
			_check(not authored_ids.is_empty() and authored_ids[0].begins_with("l2_ambient_"), "ambient citizen keeps a stable l2 voice ID: " + citizen.name)
	_check(not VoiceDirector.is_speech_enabled(), "Lesson 2 test runs with recorded speech disabled")
	var floor_hits := 0
	var floor_samples := 0
	var space := get_viewport().world_3d.direct_space_state
	for z in range(-76, 29, 4):
		floor_samples += 1
		var query := PhysicsRayQueryParameters3D.create(Vector3(0, 8, z), Vector3(0, -4, z), 1)
		if not space.intersect_ray(query).is_empty():
			floor_hits += 1
	for x in range(-32, 33, 8):
		floor_samples += 1
		var query := PhysicsRayQueryParameters3D.create(Vector3(x, 8, -24), Vector3(x, -4, -24), 1)
		if not space.intersect_ray(query).is_empty():
			floor_hits += 1
	_check(floor_hits == floor_samples, "all sampled main-route and cross-street points have physical ground")
	for boundary in ["WestWallCollisionBody", "EastWallCollisionBody", "NorthWallCollisionBody", "SouthWallCollisionBody"]:
		_check(_level.get_node_or_null("Lesson2CityEnvironment/" + boundary) != null, "visible boundary collision: " + boundary)


func _run_complete_route() -> void:
	await _talk("Guide", "politics_npc")
	await _talk("CivicGuide", "politics_task")
	for id in ["politics_monarchy", "politics_athens", "politics_sparta", "politics_despotism"]:
		_activate(id)
		_check(str(_level.get("_carried_item")) == id, "civic tablet is visibly carried: " + id)
		_activate("politics_display")
	_check(_npc_enabled("Farmer"), "politics collection unlocks agriculture")
	_check_checkpoint("farm_npc")

	await _talk("Farmer", "farm_task")
	for pair in [["farm_grain", "farm_mill"], ["farm_olives", "farm_press"], ["farm_grapes", "farm_market_delivery"]]:
		_activate(pair[0])
		_activate(pair[1])
	_check(str(_level.get("_carried_item")) == "farm_finished_goods", "processed farm goods remain physically carried for market delivery")
	_activate("farm_market_delivery")
	await _finish_optional_reveal()
	_check(_npc_enabled("Artisan"), "product-to-market farm route unlocks industry")

	await _talk("Artisan", "industry_task")
	for pair in [["industry_wood", "industry_ship"], ["industry_metal", "industry_tools"], ["industry_clay", "industry_pottery"]]:
		_activate(pair[0])
		_activate(pair[1])
	_check(_npc_enabled("Merchant"), "material-to-product activity unlocks trade")

	await _talk("Merchant", "trade_task")
	for pair in [["trade_local_crate", "trade_market_drop"], ["trade_external_crate", "trade_harbour_drop"]]:
		_activate(pair[0])
		_activate(pair[1])
	_activate("trade_dock_follow")
	_check(_npc_enabled("Scribe"), "market-and-harbour delivery unlocks society")

	await _talk("Scribe", "society_task")
	for id in ["society_official", "society_merchant", "society_common", "society_enslaved", "society_women_rights", "society_display"]:
		_activate(id)
	_check(_npc_enabled("TempleGuide"), "society record reconstruction unlocks beliefs")

	await _talk("TempleGuide", "beliefs_task")
	for pair in [["belief_zeus", "belief_zeus_plinth"], ["belief_apollo", "belief_apollo_plinth"], ["belief_athena", "belief_athena_plinth"]]:
		_activate(pair[0])
		_activate(pair[1])
	_check(_npc_enabled("TheatreDirector"), "temple symbol placement unlocks theatre")

	await _talk("TheatreDirector", "theatre_task")
	for id in ["theatre_actor_a", "theatre_actor_b", "theatre_chorus", "theatre_orchestra", "theatre_stage"]:
		_activate(id)
	await _advance_active_cutscene("theatre rehearsal cinematic completes")
	await _wait_until(func(): return bool((_ui.get("_panel") as Control).visible), "theatre classification appears")
	_ui.choice_made.emit("correct")
	await _wait_until(func(): return _npc_enabled("LibraryGuide"), "theatre rehearsal unlocks ideas")

	await _talk("LibraryGuide", "ideas_task")
	for pair in [["ideas_plato", "ideas_plato_desk"], ["ideas_aristotle", "ideas_aristotle_desk"], ["ideas_herodotus", "ideas_herodotus_desk"]]:
		_activate(pair[0])
		_activate(pair[1])
	_check(_npc_enabled("Builder"), "philosophy/history matching unlocks architecture")

	await _talk("Builder", "architecture_task")
	for id in ["arch_wall", "arch_agora", "arch_temple", "arch_theatre"]:
		_activate(id)
		_activate("arch_model")
	await _finish_optional_reveal()
	_activate("arch_sculpture")
	_check(_npc_enabled("Coach"), "city-model construction unlocks sport")

	await _talk("Coach", "sport_task")
	_activate("sport_start")
	await _wait_until(func(): return bool((_ui.get("_panel") as Control).visible), "sport choice appears")
	var choices := _ui.get("_choices") as VBoxContainer
	var has_accessible_skip := false
	for button in choices.get_children():
		has_accessible_skip = has_accessible_skip or "مبسّط" in str(button.text)
	_check(has_accessible_skip, "sport activity offers an accessible simplified completion")
	_ui.choice_made.emit("run")
	await _wait_until(func(): return bool(_spot("sport_cp_1").interaction_enabled), "race starts after its visible signal")
	for index in range(1, 4):
		_level.call("_on_spot_proximity_changed", _spot("sport_cp_%d" % index), true)
		await get_tree().process_frame
	_check(_npc_enabled("JordanGuide"), "three-checkpoint run unlocks Jordan heritage")

	await _talk("JordanGuide", "jordan_task")
	for id in ["jordan_amman", "jordan_pella", "jordan_gadara", "jordan_gerasa", "jordan_heshbon"]:
		_activate("jordan_marker_tray")
		_check(str(_level.get("_carried_item")) == id, "Jordan marker is physically carried: " + id)
		_activate(id)
	_activate("jordan_qasr")
	for marker_name in ["Amman", "Pella", "Gadara", "Gerasa", "Heshbon"]:
		var map_marker := _level.get_node_or_null("Lesson2CityEnvironment/JordanMap" + marker_name) as MeshInstance3D
		_check(map_marker != null and map_marker.visible, "Jordan location remains illuminated: " + marker_name)
	_check(str(_level.get("_stage")) == "final_board", "Jordan heritage route returns player to the final board")
	_check(bool(_spot("final_board").interaction_enabled), "final emblem board is interactive")
	_activate("final_board")
	await _advance_active_cutscene("final city highlight cinematic completes")
	await _wait_until(func(): return str(_level.get("_stage")) == "complete", "Lesson 2 reaches its ending")
	_check(_ui.is_modal_open(), "Lesson 2 ending menu is visible")
	_check_checkpoint("complete")
	_ui.ending_action.emit("explore")
	await get_tree().process_frame
	_check(not _ui.is_modal_open(), "ending allows free exploration without restarting")
	_check(bool((_level.get_node("Player") as PlayerController).get("_controls_enabled")), "free exploration restores player controls")


func _talk(npc_name: String, expected_stage: String) -> void:
	var npc := _level.get_node("Characters/" + npc_name)
	_level.call("on_npc_interaction_requested", npc)
	await get_tree().process_frame
	_check(Dialogue.is_active(), npc_name + " dialogue starts")
	for _line in range(24):
		if not Dialogue.is_active():
			break
		Dialogue.advance()
		await get_tree().process_frame
	await _wait_until(func(): return not Dialogue.is_active() and not bool(_level.get("cutscene").call("is_active")), npc_name + " conversation restores control")
	_check(str(_level.get("_stage")) == expected_stage, npc_name + " advances to " + expected_stage)


func _activate(id: String) -> void:
	var spot := _spot(id)
	_check(spot != null, "activity target exists: " + id)
	if spot != null:
		_check(spot.interaction_enabled, "activity target is enabled: " + id)
		_level.call("_activate_spot", spot)


func _advance_active_cutscene(message: String) -> void:
	await _wait_until(func(): return bool(_level.get("cutscene").call("is_active")), message + " (starts)")
	for _frame in range(300):
		var active := bool(_level.get("cutscene").call("is_active"))
		if not active:
			_check(true, message)
			return
		VoiceDirector.stop_narrator(true)
		_level.get("cutscene").set("_advance_shot_requested", true)
		await get_tree().process_frame
	_check(false, message)


func _finish_optional_reveal() -> void:
	if not bool(_level.get("cutscene").call("is_active")):
		return
	await _advance_active_cutscene("short mission reveal completes")


func _check_checkpoint(expected_stage: String) -> void:
	var checkpoint := GameFlow.get_checkpoint()
	_check(str(checkpoint.get("chapter_id", "")) == "lesson2", "checkpoint stores Lesson 2 chapter")
	var flags: Dictionary = checkpoint.get("extra", {})
	_check(str(flags.get("lesson2_stage", "")) == expected_stage, "checkpoint stores mission stage " + expected_stage)


func _wait_until(predicate: Callable, message: String) -> void:
	for _frame in range(360):
		if predicate.call():
			return
		await get_tree().process_frame
	_check(false, message)


func _wait_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame


func _spot(id: String) -> Lesson2InteractionSpot:
	return _level.get("_spots").get(id) as Lesson2InteractionSpot


func _npc_enabled(name_value: String) -> bool:
	return bool(_level.get_node("Characters/" + name_value).call("is_interaction_enabled"))


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failed = true
		push_error("FAIL: " + message)


func _finish() -> void:
	Engine.time_scale = 1.0
	print("LESSON2_FLOW_SMOKE_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)
