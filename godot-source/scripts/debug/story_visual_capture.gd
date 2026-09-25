extends Node

const OUTPUT_DIR := "res://test_artifacts"


func _ready() -> void:
	call_deferred("_capture_story_scenes")


func _capture_story_scenes() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	GameFlow.story_flags["village_opening_seen"] = true
	var village: Node = (load("res://scenes/levels/main_level.tscn") as PackedScene).instantiate()
	add_child(village)
	await _wait_frames(35)
	await _save_viewport("village_inland.png")
	_set_player_view(village, Vector3(0, 0.08, 3.2), -PI * 0.5)
	await _wait_frames(20)
	await _save_viewport("village_east_district.png")
	_set_player_view(village, Vector3(0, 0.08, 3.2), PI * 0.5)
	await _wait_frames(20)
	await _save_viewport("village_west_district.png")
	_set_player_view(village, Vector3(0, 0.08, 14.0), PI)
	await _wait_frames(25)
	await _save_viewport("village_coast.png")
	_set_player_view(village, Vector3(0, 3.35, -23.0), PI)
	await _wait_frames(25)
	await _save_viewport("village_temple_outlook.png")
	# Keep the chase camera clear of the open workshop canopy while still framing
	# the expanded western street from within its playable route.
	_set_player_view(village, Vector3(-24.0, 0.08, 1.0), -PI * 0.5)
	await _wait_frames(20)
	await _save_viewport("village_west_playable_district.png")
	_set_player_view(village, Vector3(18.0, 0.08, 3.2), -PI * 0.5)
	await _wait_frames(20)
	await _save_viewport("village_east_playable_district.png")
	village.queue_free()
	await _wait_frames(5)

	var city: Node = (load("res://scenes/levels/city_states_level.tscn") as PackedScene).instantiate()
	add_child(city)
	await _wait_frames(40)
	var city_cutscene: Node = city.get_node("CutsceneController")
	city_cutscene.set("_skip_requested", true)
	await _wait_frames(12)
	_hide_dialogue_panel(city)
	await _save_viewport("athens_stage.png")
	_set_player_view(city, Vector3(0, 0.08, 3.0), -PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(city)
	await _save_viewport("athens_east_quarter.png")
	# This offset shows the outer quarter without placing the camera behind the
	# West Potters House roof when the longer gameplay boom settles.
	_set_player_view(city, Vector3(-18.0, 0.08, 10.5), -PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(city)
	await _save_viewport("athens_outer_quarter.png")
	city.call("_activate_sparta")
	await _wait_frames(35)
	_hide_dialogue_panel(city)
	await _save_viewport("sparta_stage.png")
	_set_player_view(city, Vector3(70, 0.08, 3.0), PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(city)
	await _save_viewport("sparta_west_compound.png")
	_set_player_view(city, Vector3(87.0, 0.08, 13.0), PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(city)
	await _save_viewport("sparta_outer_compound.png")
	city.queue_free()
	await _wait_frames(5)

	var macedon: Node = (load("res://scenes/levels/macedon_level.tscn") as PackedScene).instantiate()
	add_child(macedon)
	await _wait_frames(40)
	var macedon_cutscene: Node = macedon.get_node("CutsceneController")
	macedon_cutscene.set("_skip_requested", true)
	await _wait_frames(12)
	_hide_dialogue_panel(macedon)
	await _save_viewport("macedon_stage.png")
	_set_player_view(macedon, Vector3(0, 0.08, 3.0), -PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(macedon)
	await _save_viewport("macedon_east_camp.png")
	_set_player_view(macedon, Vector3(-18.0, 0.08, 12.0), -PI * 0.5)
	await _wait_frames(18)
	_hide_dialogue_panel(macedon)
	await _save_viewport("macedon_outer_camp.png")
	macedon.queue_free()
	await _wait_frames(5)

	var historical_map: Node = (load("res://scenes/story/historical_map.tscn") as PackedScene).instantiate()
	add_child(historical_map)
	await _wait_frames(10)
	var map_view := historical_map.get_node("MapFrame/Margin/MapView") as HistoricalMapView
	map_view.camera_center = Vector2(0.5, 0.5)
	map_view.camera_zoom = 1.0
	map_view.set_division(3)
	historical_map.get_node("DivisionLegend").hide()
	historical_map.get_node("Header/Margin/VBox/ChapterTitle").text = "ما بعد الإسكندر"
	historical_map.get_node("Header/Margin/VBox/ChapterSubtitle").text = "انقسام الإمبراطورية بين كبار القادة"
	await _wait_frames(6)
	await _save_viewport("successor_map.png")
	map_view.hellenistic_blend = 1.0
	historical_map.get_node("DivisionLegend").hide()
	historical_map.get_node("Header/Margin/VBox/ChapterTitle").text = "الحضارة الهلنستية"
	await _wait_frames(6)
	await _save_viewport("hellenistic_map.png")

	print("STORY_VISUAL_CAPTURE: PASS")
	get_tree().quit(0)


func _save_viewport(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name))
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save visual capture: " + path)


func _wait_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame


func _hide_dialogue_panel(level: Node) -> void:
	var hud := level.get_node_or_null("GameHUD")
	if hud == null:
		return
	var dialogue_panel := hud.get_node_or_null("DialoguePanel") as Control
	if dialogue_panel != null:
		dialogue_panel.hide()


func _set_player_view(level: Node, position_value: Vector3, yaw: float) -> void:
	var player := level.get_node("Player") as PlayerController
	player.global_position = position_value
	player.velocity = Vector3.ZERO
	player.camera_pivot.rotation.y = yaw
	player.set("_target_camera_yaw", yaw)
