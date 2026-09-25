extends Node

const OUTPUT_DIR := "res://test_artifacts/lesson2"


func _ready() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	GameFlow.story_flags["lesson2_stage"] = "intro"
	var level := (load("res://scenes/levels/lesson2_level.tscn") as PackedScene).instantiate()
	add_child(level)
	await _wait_frames(45)
	await _save("01_city_gate_and_square.png")
	_set_player_view(level, Vector3(-7, 0.08, 5), PI * 0.5)
	await _wait_frames(25)
	await _save("02_farm_livestock_and_processing.png")
	_set_player_view(level, Vector3(12, 0.08, -7), -PI * 0.5)
	await _wait_frames(25)
	await _save("03_market_harbour_and_boats.png")
	level.call("_begin_beliefs")
	_set_player_view(level, Vector3(0, 0.08, -25), 0.0)
	await _wait_frames(25)
	await _save("04_temple_apollo_and_objective_marker.png")
	var apollo_camera := _set_free_view(Vector3(0, 4.6, -24.0), Vector3(0, 1.6, -32.0))
	await _wait_frames(20)
	await _save("04b_apollo_name_role_and_sun.png")
	apollo_camera.queue_free()
	_set_player_view(level, Vector3(-4, 0.08, -47), PI * 0.5)
	await _wait_frames(25)
	await _save("05_theatre_and_library.png")
	# Use a high, wide establishing view so the evidence frame contains both the
	# running yard and Jordan archive instead of being blocked by the model court.
	var district_camera := _set_free_view(Vector3(0, 12.0, -52.0), Vector3(0, 0.6, -69.0))
	await _wait_frames(25)
	await _save("06_sport_and_jordan_archive.png")
	district_camera.queue_free()
	level.call("_show_all_emblems")
	_set_player_view(level, Vector3(0, 0.08, 16), 0.0)
	await _wait_frames(25)
	await _save("07_final_emblem_board.png")
	level.call("_begin_industry")
	var spots: Dictionary = level.get("_spots")
	level.call("_activate_spot", spots.get("industry_wood"))
	_set_player_view(level, Vector3(12, 0.08, -2.8), PI)
	await _wait_frames(35)
	await _save("08_visible_held_object.png")
	level.call("_activate_spot", spots.get("industry_ship"))
	# Reframe the completed station and let the transient pickup banner clear so
	# this shot verifies the snapped world object rather than the prior carry UI.
	_set_player_view(level, Vector3(8.5, 0.08, -5.5), -0.55)
	await get_tree().create_timer(2.4).timeout
	var placement_camera := _set_free_view(Vector3(7.4, 3.5, -4.6), Vector3(11, 0.9, -9))
	await _wait_frames(20)
	await _save("09_snapped_workshop_placement.png")
	placement_camera.queue_free()
	var activity_ui := level.get_node("Lesson2ActivityUI") as Lesson2ActivityUI
	activity_ui.show_choice(
		"مراجعة المسار",
		"أي موضع يعبّر عن دور أبولو كما يورده الدرس؟",
		[
			{"id":"apollo", "label":"أبولو — إله الشمس"},
			{"id":"athena", "label":"أثينا — إلهة الحكمة"},
			{"id":"zeus", "label":"زيوس — الإله الرئيس"},
		]
	)
	await _wait_frames(20)
	await _save("10_polished_activity_panel.png")
	print("LESSON2_VISUAL_CAPTURE: PASS")
	get_tree().quit(0)


func _set_player_view(level: Node, position_value: Vector3, yaw: float) -> void:
	var player := level.get_node("Player") as PlayerController
	player.global_position = position_value
	player.velocity = Vector3.ZERO
	player.camera_pivot.rotation.y = yaw
	player.set("_target_camera_yaw", yaw)
	player.snap_camera_after_teleport()
	player.camera.current = true


func _set_free_view(position_value: Vector3, target: Vector3) -> Camera3D:
	var camera := Camera3D.new()
	camera.fov = 67.0
	add_child(camera)
	camera.global_position = position_value
	camera.look_at(target, Vector3.UP)
	camera.current = true
	return camera


func _save(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name))
	var result := image.save_png(path)
	if result != OK:
		push_error("Could not save " + path)


func _wait_frames(count: int) -> void:
	for _frame in range(count):
		await get_tree().process_frame
