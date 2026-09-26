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
	var teacher_marker := level.get_node("Teacher/QuestBeacon") as Node3D
	_check(
		teacher_marker.visible and teacher_marker.scale.length_squared() > 0.5,
		"current teacher receives a visible quest marker"
	)
	_check(_count_visible_story_markers(level) == 1, "opening scene shows exactly one quest marker")
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
	_check(_count_visible_story_markers(level) == 1, "only the current village objective has a marker")
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
	_check(level.get_node("SpartaStage").visible, "Sparta is restored")
	_check(trainer.is_interaction_enabled(), "Spartan trainer interaction is restored")
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
	_check(not officer.is_interaction_enabled(), "completed Macedonian officer stays unavailable")
	_check(alexander.is_interaction_enabled(), "Alexander interaction is restored")
	_check(Objectives.objective_text == "تحدث إلى الإسكندر عند خريطة الحملة", "Macedon objective resumes at Alexander")
	level.queue_free()
	await get_tree().process_frame


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		_failures.append(description)


func _count_visible_story_markers(node: Node) -> int:
	var count := 0
	if (
		node.name == &"QuestBeacon"
		and node is Node3D
		and node.visible
		and node.scale.length_squared() > 0.5
	):
		count += 1
	elif node is Label3D and node.name == &"MapMarker" and node.visible:
		count += 1
	for child in node.get_children():
		count += _count_visible_story_markers(child)
	return count


func _count_nodes_with_suffix(node: Node, suffix: String) -> int:
	var count := 1 if str(node.name).ends_with(suffix) else 0
	for child in node.get_children():
		count += _count_nodes_with_suffix(child, suffix)
	return count
