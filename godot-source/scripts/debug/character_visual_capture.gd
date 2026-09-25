extends Node

const SHOWCASE := preload("res://scenes/debug/character_visual_showcase.tscn")
const OUTPUT_DIR := "res://test_artifacts/characters"


func _ready() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var showcase := SHOWCASE.instantiate()
	add_child(showcase)
	var camera := showcase.get_node("Camera3D") as Camera3D
	await _wait_frames(45)
	await _save("civilian_row.png")
	await _capture_detail(camera, -2.6, "civilian_detail_left.png")
	await _capture_detail(camera, 3.9, "civilian_detail_right.png")
	_set_row_pose(showcase.get_node("CivilianRow"), &"Walk", 0.48)
	await _wait_frames(2)
	await _save("civilian_walk_pose.png")
	showcase.get_node("CivilianRow").hide()
	showcase.get_node("MilitaryRow").show()
	await _wait_frames(20)
	await _save("military_row.png")
	await _capture_detail(camera, -3.75, "military_detail_left.png")
	await _capture_detail(camera, 3.75, "military_detail_right.png")
	_set_row_pose(showcase.get_node("MilitaryRow"), &"Run", 0.31)
	await _wait_frames(2)
	await _save("military_run_pose.png")
	showcase.get_node("MilitaryRow").hide()
	showcase.get_node("AmbientRow").show()
	await _wait_frames(20)
	await _save("ambient_row.png")
	await _capture_detail(camera, 0.0, "ambient_detail.png")
	print("CHARACTER_VISUAL_CAPTURE: PASS")
	get_tree().quit(0)


func _save(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name))
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save character capture: " + path)


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame


func _capture_detail(camera: Camera3D, center_x: float, file_name: String) -> void:
	var original_position := camera.position
	var original_fov := camera.fov
	camera.position = Vector3(center_x, 2.25, 4.4)
	camera.fov = 44.0
	await _wait_frames(3)
	await _save(file_name)
	camera.position = original_position
	camera.fov = original_fov
	await _wait_frames(2)


func _set_row_pose(row: Node, animation_name: StringName, time: float) -> void:
	for character in row.get_children():
		var visual := character.get_node_or_null("Visual")
		if visual == null:
			continue
		visual.set_process(false)
		var player := _find_animation_player(visual)
		if player != null and player.has_animation(animation_name):
			player.play(animation_name)
			player.seek(time, true)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
