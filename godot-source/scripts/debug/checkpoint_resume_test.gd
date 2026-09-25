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
	GameFlow.save_checkpoint(
		"lesson2",
		"res://scenes/levels/lesson2_level.tscn",
		{"lesson2_stage":"trade_npc"}
	)
	_check(GameFlow.has_checkpoint(), "major-mission checkpoint is persisted")
	_check(GameFlow.resume_checkpoint(), "resume request is accepted")
	for _frame in range(480):
		if GameFlow.current_chapter == "lesson2" and not GameFlow.is_transitioning():
			break
		await get_tree().process_frame
	var level := get_tree().current_scene
	_check(level != null and level.name == "Lesson2Level", "resume loads the Lesson 2 city")
	if level != null and level.name == "Lesson2Level":
		_check(str(level.get("_stage")) == "trade_npc", "resume restores the saved major mission")
		var merchant := level.get_node_or_null("Characters/Merchant")
		_check(merchant != null and bool(merchant.call("is_interaction_enabled")), "resume restores the correct mission NPC")
	GameFlow.clear_checkpoint()
	Engine.time_scale = 1.0
	print("CHECKPOINT_RESUME_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failed = true
		push_error("FAIL: " + message)
