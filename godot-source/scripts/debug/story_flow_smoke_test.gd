extends Node

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_detach_and_run")


func _detach_and_run() -> void:
	reparent(get_tree().root)
	await get_tree().process_frame
	_run()


func _run() -> void:
	Engine.time_scale = 18.0
	GameFlow.reset_story()
	await _open_scene("res://scenes/levels/main_level.tscn")
	await _wait_frames(8)
	await _wait_until_cutscene_finishes(180)
	var village := get_tree().current_scene
	_check(village != null and village.name == "MainLevel", "Village scene loads")
	_check(Objectives.objective_text == "تحدث إلى المعلّم", "Village opening restores first objective")
	_check_appearance(village.get_node("Player"), "player_messenger", "Player uses messenger appearance")
	_check_appearance(village.get_node("Teacher"), "teacher_elder", "Teacher uses elder appearance")
	_check_appearance(village.get_node("TempleRecipient"), "temple_attendant", "Temple NPC uses civic temple appearance")

	village.call("on_npc_interaction_requested", village.get_node("Teacher"))
	_check(Dialogue.is_active(), "Teacher dialogue starts")
	_check_conversation_presentation(village, true, "Conversation camera and control lock engage")
	await _finish_dialogue()
	_check_conversation_presentation(village, false, "Gameplay camera and controls restore")
	_check(Objectives.objective_text == "أوصل الرسالة إلى المعبد", "Teacher advances delivery objective")
	village.call("on_npc_interaction_requested", village.get_node("TempleRecipient"))
	_check(Dialogue.is_active(), "Temple dialogue starts")
	await _finish_dialogue()
	_check(Objectives.objective_text == "اقترب من خريطة المدن", "Temple dialogue unlocks map objective")
	village.call("_on_history_map_entered", village.get_node("Player"))
	await _wait_for_chapter("city_states", 240)

	var city_states := get_tree().current_scene
	_check(city_states != null and city_states.name == "CityStatesLevel", "Athens/Sparta scene transition works")
	_check_appearance(city_states.get_node("AthensCast/AthensCitizen"), "athenian_citizen", "Athens citizen has civic appearance")
	_check_appearance(city_states.get_node("SpartaCast/SpartaTrainer"), "spartan_trainer", "Sparta trainer has military appearance")
	await _wait_until_cutscene_finishes(180)
	city_states.call("_on_athens_observation_entered", city_states.get_node("Player"))
	await _wait_for_state(city_states, 2, 240)
	_check(Objectives.objective_text == "تحدث إلى المواطن الأثيني", "Athens debate unlocks citizen")
	city_states.call("on_npc_interaction_requested", city_states.get_node("AthensCast/AthensCitizen"))
	await _finish_dialogue()
	await _wait_for_state(city_states, 3, 240)
	_check(Objectives.objective_text == "شاهد تدريبات إسبرطة", "Athens conversation transitions to Sparta")
	city_states.call("_on_sparta_observation_entered", city_states.get_node("Player"))
	await _wait_for_state(city_states, 5, 240)
	_check(Objectives.objective_text == "تحدث إلى المدرّب الإسبرطي", "Sparta training unlocks trainer")
	city_states.call("on_npc_interaction_requested", city_states.get_node("SpartaCast/SpartaTrainer"))
	await _finish_dialogue()
	await _wait_for_chapter("macedon", 360)

	var macedon := get_tree().current_scene
	_check(macedon != null and macedon.name == "MacedonLevel", "Conflict cutscene reaches Macedon")
	_check_appearance(macedon.get_node("MacedonCast/Officer"), "macedonian_officer", "Macedonian officer has command appearance")
	_check_appearance(macedon.get_node("MacedonCast/Alexander"), "alexander", "Alexander has unique royal-campaign appearance")
	await _wait_until_cutscene_finishes(180)
	macedon.call("on_npc_interaction_requested", macedon.get_node("MacedonCast/Officer"))
	await _finish_dialogue()
	_check(Objectives.objective_text == "تحدث إلى الإسكندر عند خريطة الحملة", "Officer unlocks Alexander")
	macedon.call("on_npc_interaction_requested", macedon.get_node("MacedonCast/Alexander"))
	await _finish_dialogue()
	_check(Objectives.objective_text == "اقترب من خريطة الحملة", "Alexander unlocks campaign map")
	macedon.call("_on_campaign_map_entered", macedon.get_node("Player"))
	await _wait_for_chapter("historical_map", 240)

	var historical_map := get_tree().current_scene
	_check(historical_map != null and historical_map.name == "HistoricalMap", "Campaign map scene transition works")
	var ending_reached := false
	# Keep a generous wall-clock margin for renderer-dependent tween cadence.
	for _frame in range(1800):
		if is_instance_valid(historical_map) and bool(historical_map.get("_ending_visible")):
			ending_reached = true
			break
		# MP3 playback intentionally follows wall-clock time and is not accelerated
		# by Engine.time_scale. This progression test advances narration explicitly;
		# the dedicated voice-system test validates real streams and durations.
		VoiceDirector.stop_narrator(true)
		if is_instance_valid(historical_map):
			historical_map.set("_advance_requested", true)
		await get_tree().process_frame
	if not ending_reached and is_instance_valid(historical_map):
		var map_view := historical_map.get_node_or_null("MapFrame/Margin/MapView")
		if map_view != null:
			print("MAP_TIMEOUT_STATE: route=", map_view.get("route_progress"),
				" division=", map_view.get("division_stage"),
				" blend=", map_view.get("hellenistic_blend"))
	_check(ending_reached, "Campaign, division, Hellenistic epilogue, and ending complete")
	await _wait_for_chapter("lesson2", 360)
	var lesson2 := get_tree().current_scene
	_check(lesson2 != null and lesson2.name == "Lesson2Level", "Lesson 1 ending continues directly into Lesson 2")
	if lesson2 != null and lesson2.name == "Lesson2Level":
		_check(str(lesson2.get("_stage")) == "intro", "Continuous campaign begins Lesson 2 at its introduction")
		var guide := lesson2.get_node_or_null("Characters/Guide")
		_check(guide != null and bool(guide.call("is_interaction_enabled")), "Lesson 2 guide is ready without a menu break")

	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("STORY_FLOW_SMOKE_TEST: PASS (complete route)")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error("STORY_FLOW_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func _open_scene(scene_path: String) -> void:
	var error := get_tree().change_scene_to_file(scene_path)
	_check(error == OK, "Scene opens: " + scene_path)
	await get_tree().scene_changed


func _finish_dialogue() -> void:
	for _line in range(16):
		if not Dialogue.is_active():
			break
		var press := InputEventAction.new()
		press.action = "interact"
		press.pressed = true
		Input.parse_input_event(press)
		var release := InputEventAction.new()
		release.action = "interact"
		release.pressed = false
		Input.parse_input_event(release)
		await get_tree().process_frame
	for _frame in range(90):
		if not Dialogue.is_active():
			var scene_cutscene := get_tree().current_scene.get_node_or_null("CutsceneController")
			if scene_cutscene == null or not scene_cutscene.is_active():
				break
		await get_tree().process_frame
	await _wait_frames(5)


func _wait_until_cutscene_finishes(max_frames: int) -> void:
	for _frame in range(max_frames):
		if get_tree().current_scene == null:
			await get_tree().process_frame
			continue
		var scene_cutscene := get_tree().current_scene.get_node_or_null("CutsceneController")
		if scene_cutscene == null or not scene_cutscene.is_active():
			return
		# Voice duration is wall-clock based and uncapped headless frames can be much
		# shorter than rendered frames. Advance authored shots explicitly here; real
		# MP3 loading, duration, and playback are covered by voice_system_test.gd.
		VoiceDirector.stop_narrator(true)
		scene_cutscene.set("_advance_shot_requested", true)
		await get_tree().process_frame
	_check(false, "Cutscene finishes within expected time")


func _wait_for_chapter(chapter_id: String, max_frames: int) -> void:
	for _frame in range(max_frames):
		if GameFlow.current_chapter == chapter_id and not GameFlow.is_transitioning():
			return
		await get_tree().process_frame
	_check(false, "Chapter transition reaches " + chapter_id)


func _wait_for_state(scene: Node, expected_state: int, max_frames: int) -> void:
	for _frame in range(max_frames):
		if not is_instance_valid(scene):
			break
		if int(scene.get("_state")) == expected_state:
			return
		await get_tree().process_frame
	_check(false, "Scene reaches state %d" % expected_state)


func _wait_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		_failures.append(description)
		print("FAIL: " + description)


func _check_appearance(character: Node, expected_profile: String, description: String) -> void:
	var visual := character.get_node_or_null("Visual")
	_check(
		visual != null
		and visual.has_method("get_appearance_profile_name")
		and str(visual.call("get_appearance_profile_name")) == expected_profile,
		description
	)


func _check_conversation_presentation(scene: Node, expected_active: bool, description: String) -> void:
	var scene_player := scene.get_node_or_null("Player") as PlayerController
	var scene_cutscene := scene.get_node_or_null("CutsceneController") as CutsceneController
	var presentation_matches := scene_player != null and scene_cutscene != null
	if presentation_matches and expected_active:
		var cinematic_camera := scene_cutscene.get("_cinematic_camera") as Camera3D
		presentation_matches = (
			scene_cutscene.is_active()
			and not bool(scene_player.get("_controls_enabled"))
			and cinematic_camera != null
			and cinematic_camera.current
		)
	elif presentation_matches:
		presentation_matches = (
			not scene_cutscene.is_active()
			and bool(scene_player.get("_controls_enabled"))
			and scene_player.get_gameplay_camera().current
		)
	_check(presentation_matches, description)
