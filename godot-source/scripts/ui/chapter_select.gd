extends Control


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Center/Panel/Margin/VBox/Continue.disabled = not GameFlow.has_checkpoint()
	$Center/Panel/Margin/VBox/NewGame.grab_focus()
	$Center/Panel/Margin/VBox/DebugLessons.hide()


func _on_new_game_pressed() -> void:
	GameFlow.start_new_game()


func _on_continue_pressed() -> void:
	if not GameFlow.resume_checkpoint():
		$Center/Panel/Margin/VBox/Continue.disabled = true


func _on_debug_toggle_pressed() -> void:
	$Center/Panel/Margin/VBox/DebugLessons.visible = not $Center/Panel/Margin/VBox/DebugLessons.visible


func _on_lesson_2_pressed() -> void:
	GameFlow.reset_story()
	GameFlow.story_flags["lesson2_stage"] = "intro"
	GameFlow.transition_to_scene(
		"res://scenes/levels/lesson2_level.tscn",
		"lesson2",
		"الدرس الثاني",
		"الحياة العامة في الحضارة اليونانية"
	)


func _on_lesson_1_pressed() -> void:
	GameFlow.reset_story()
	GameFlow.transition_to_scene("res://scenes/levels/main_level.tscn", "village", "اختبار الفصل الأول")


func _on_quit_pressed() -> void:
	get_tree().quit()
