extends Node

const OUTPUT_DIR := "res://test_artifacts"

var _failed: bool = false
var _map: HistoricalMapView


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.012, 0.018, 0.03, 1.0)
	add_child(backdrop)
	_map = HistoricalMapView.new()
	_map.name = "MapView"
	_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map.offset_left = 24.0
	_map.offset_top = 24.0
	_map.offset_right = -24.0
	_map.offset_bottom = -24.0
	_map.clip_contents = true
	add_child(_map)
	for _frame in range(5):
		await get_tree().process_frame

	var route := _map.get_campaign_route_points()
	_check(_map.uses_reference_image(), "authoritative reference image is rendered")
	_check(
		_map.get_reference_image_path() == "res://assets/reference/alexander_empire_map.png",
		"correct supplied map asset is used"
	)
	_check(route.size() >= 20, "campaign route has detailed waypoints")
	_check(route[7].x < route[12].x, "Egypt occurs before Babylon/Persia in route order")
	_check(route[-1].distance_to(Vector2(0.455, 0.48)) < 0.01, "campaign route returns to Babylon")

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_map.reset_campaign()
	_map.camera_center = Vector2(0.38, 0.48)
	_map.camera_zoom = 1.10
	_map.route_progress = 0.46
	await _wait_frames(8)
	await _capture("historical_campaign_mid.png")

	_map.route_progress = 1.0
	_map.camera_center = Vector2(0.47, 0.50)
	_map.camera_zoom = 1.62
	_map.atmosphere_darken = 0.78
	await _wait_frames(8)
	await _capture("historical_babylon.png")
	_check(_map.atmosphere_darken > 0.7, "Babylon death focus darkens the reference map")

	_map.atmosphere_darken = 0.0
	_map.camera_center = Vector2(0.5, 0.52)
	_map.camera_zoom = 1.0
	_map.set_division(3)
	await _wait_frames(14)
	await _capture("historical_successors.png")
	_check(_map.antigonus_blend == 1.0 and _map.ptolemy_blend == 1.0 and _map.seleucus_blend == 1.0, "all successor regions reveal")

	print("HISTORICAL_MAP_VISUAL_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)


func _capture(file_name: String) -> void:
	# The dummy headless renderer has no readable viewport texture. Assertions still
	# run there; screenshots are produced by the OpenGL visual-QA invocation.
	if DisplayServer.get_name() == "headless":
		print("SKIP: screenshot capture unavailable with the headless display server")
		return
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name)))
	_check(error == OK, "saved " + file_name)


func _wait_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().process_frame


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
		return
	_failed = true
	push_error("FAIL: " + message)
