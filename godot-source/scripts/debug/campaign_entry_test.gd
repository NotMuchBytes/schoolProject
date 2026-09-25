extends Node

var _failed := false


func _ready() -> void:
	call_deferred("_detach_and_run")


func _detach_and_run() -> void:
	reparent(get_tree().root)
	await get_tree().process_frame
	_run()


func _run() -> void:
	Engine.time_scale = 20.0
	GameFlow.clear_checkpoint()
	var error := get_tree().change_scene_to_file("res://scenes/ui/chapter_select.tscn")
	_check(error == OK, "main menu scene opens")
	await get_tree().scene_changed
	var menu := get_tree().current_scene
	_check(menu != null and menu.name == "ChapterSelect", "project main scene is the campaign menu")
	if menu != null:
		_check(not menu.get_node("Center/Panel/Margin/VBox/DebugLessons").visible, "chapter selector is hidden from the normal player flow")
		_check(bool(menu.get_node("Center/Panel/Margin/VBox/Continue").disabled), "Continue is disabled without a checkpoint")
		menu.call("_on_new_game_pressed")
	for _frame in range(480):
		if GameFlow.current_chapter == "village" and not GameFlow.is_transitioning() and get_tree().current_scene != menu:
			break
		await get_tree().process_frame
	var village := get_tree().current_scene
	_check(village != null and village.name == "MainLevel", "New Game starts Lesson 1 normally")
	var checkpoint := GameFlow.get_checkpoint()
	_check(str(checkpoint.get("chapter_id", "")) == "village", "New Game creates a campaign checkpoint")
	GameFlow.clear_checkpoint()
	Engine.time_scale = 1.0
	print("CAMPAIGN_ENTRY_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failed = true
		push_error("FAIL: " + message)
