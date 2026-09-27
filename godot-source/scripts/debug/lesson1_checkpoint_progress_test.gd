extends Node

var _failures: PackedStringArray = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await _check_initial_teacher_marker()
	await _check_village_map_checkpoint()
	await _check_sparta_trainer_checkpoint()
	await _check_macedon_alexander_checkpoint()
	GameFlow.clear_checkpoint()
	GameFlow.reset_story()
	if _failures.is_empty():
		print("LESSON1_CHECKPOINT_PROGRESS_TEST: PASS")
		get_tree().quit()
		return
	for failure in _failures:
		push_error("LESSON1_CHECKPOINT_PROGRESS_TEST: " + failure)
	print("LESSON1_CHECKPOINT_PROGRESS_TEST: FAIL (%d problems)" % _failures.size())
	get_tree().quit(1)


func _check_initial_teacher_marker() -> void:
	GameFlow.reset_story()
	GameFlow.current_chapter = "village"
	GameFlow.story_flags = {
		"village_opening_seen": true,
		"village_stage": "teacher",
	}
	var level := (load("res://scenes/levels/main_level.tscn") as PackedScene).instantiate()
	add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	var teacher := level.get_node("Teacher") as Node3D
	var game_hud := level.get_node("GameHUD") as GameHUD
	_check(
		game_hud.get_quest_target() == teacher,
		"current teacher receives a visible quest marker"
	)
	_check(
		game_hud.quest_pointer.visible,
		"opening scene shows exactly one quest marker"
	)
	var roamers := level.get_node("AmbientVillagers").get_children()
	var visible_roamers := 0
	var roaming_only := 0
	var active_roamers := 0
	for roamer in roamers:
		if roamer.active_in_scene:
			active_roamers += 1
		if roamer.active_in_scene and roamer.visible and roamer.get_node("Visual/CharacterModel").visible:
			visible_roamers += 1
		if roamer.active_in_scene and roamer.patrol_enabled and not roamer.is_interaction_enabled():
			roaming_only += 1
	_check(active_roamers == 3 and visible_roamers == active_roamers, "only the staged village roamers are visibly rendered")
	_check(roaming_only == active_roamers, "ambient NPCs roam without becoming quest interactions")
	_check(not level.has_node("AthensCast"), "village does not load later-scene NPC casts")
	var latin_greek_font := load("res://assets/fonts/NotoSans-LatinGreek.ttf") as Font
	_check(
		latin_greek_font != null
		and latin_greek_font.has_char("A".unicode_at(0))
		and latin_greek_font.has_char("Ω".unicode_at(0)),
		"bundled fallback font covers English and Greek"
	)
	_check(_count_nodes_with_suffix(level, "RoofLip") == 0, "village has no intersecting roof-lip slabs")
	var progress_label := level.get_node("GameHUD/ObjectivePanel/Margin/VBox/StoryProgress") as Label
	_check(progress_label.visible and "٠ / ٣" in progress_label.text, "opening progress is visible")
	level.queue_free()
	await get_tree().process_frame


func _check_village_map_checkpoint() -> void:
	GameFlow.reset_story()
	GameFlow.current_chapter = "village"
	GameFlow.story_flags = {
		"village_opening_seen": true,
		"village_stage": "map",
	}
	var level := (load("res://scenes/levels/main_level.tscn") as PackedScene).instantiate()
	add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	var journey_label := level.get_node("GameHUD/ObjectivePanel/Margin/VBox/StoryProgress") as Label
	_check(level.get_node("HistoryMapTrigger").monitoring, "village map trigger is restored")
	_check(level.get_node("HistoryMapTrigger/MapMarker").visible, "village map marker is restored")
	_check(not level.get_node("Teacher").is_interaction_enabled(), "completed teacher stays unavailable")
	_check(Objectives.objective_text == "اقترب من خريطة المدن", "village objective resumes at the map")
	_check(journey_label.visible and "٢ / ٣" in journey_label.text, "Lesson 1 journey progress is visibly restored")
	_check((level.get_node("GameHUD") as GameHUD).get_quest_target() == null, "only the current village objective has a marker")
	var player_visual := level.get_node("Player/Visual") as Node3D
	_check(absf(absf(player_visual.rotation.y) - PI) < 0.01, "player begins facing into the story world")
	level.queue_free()
	await get_tree().process_frame


func _check_sparta_trainer_checkpoint() -> void:
	GameFlow.reset_story()
	GameFlow.current_chapter = "city_states"
	GameFlow.story_flags = {
		"athens_arrival_seen": true,
		"city_states_stage": "sparta_trainer",
	}
	var level := (load("res://scenes/levels/city_states_level.tscn") as PackedScene).instantiate()
	add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	var trainer := level.get_node("SpartaCast/SpartaTrainer")
	_check(not level.get_node("AthensStage").visible, "Athens is hidden after the Sparta checkpoint")
	_check(not level.get_node("AthensCast").visible, "Athens NPCs stay hidden in the Sparta scene")
	_check(level.get_node("SpartaStage").visible, "Sparta is restored")
	_check(level.get_node("SpartaCast").visible, "only the Sparta NPC cast is visible")
	_check(trainer.is_interaction_enabled(), "Spartan trainer interaction is restored")
	_check((level.get_node("GameHUD") as GameHUD).get_quest_target() == trainer, "Spartan trainer owns the quest marker")
	_check(Objectives.objective_text == "تحدث إلى المدرّب الإسبرطي", "Sparta objective resumes at the trainer")
	level.queue_free()
	await get_tree().process_frame


func _check_macedon_alexander_checkpoint() -> void:
	GameFlow.reset_story()
	GameFlow.current_chapter = "macedon"
	GameFlow.story_flags = {
		"macedon_arrival_seen": true,
		"macedon_stage": "alexander",
	}
	var level := (load("res://scenes/levels/macedon_level.tscn") as PackedScene).instantiate()
	add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	var officer := level.get_node("MacedonCast/Officer")
	var alexander := level.get_node("MacedonCast/Alexander")
	_check(not level.has_node("AthensCast") and not level.has_node("SpartaCast"), "Macedon loads only its own NPC cast")
	_check(not officer.is_interaction_enabled(), "completed Macedonian officer stays unavailable")
	_check(alexander.is_interaction_enabled(), "Alexander interaction is restored")
	_check((level.get_node("GameHUD") as GameHUD).get_quest_target() == alexander, "Alexander owns the quest marker")
	_check(Objectives.objective_text == "تحدث إلى الإسكندر عند خريطة الحملة", "Macedon objective resumes at Alexander")
	level.queue_free()
	await get_tree().process_frame


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		_failures.append(description)


func _count_nodes_with_suffix(node: Node, suffix: String) -> int:
	var count := 1 if str(node.name).ends_with(suffix) else 0
	for child in node.get_children():
		count += _count_nodes_with_suffix(child, suffix)
	return count
