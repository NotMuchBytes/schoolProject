extends Node

const CAPTURE_PATH := "res://test_artifacts/dialogue_ui_long_arabic.png"
const LONG_ARABIC_LINE := (
	"في أرض اليونان، تلتقي الجبال بالبحر، وتنتشر الجزر حول السواحل؛ "
	+ "ولهذا نشأت مدن مستقلة لكل واحدة منها عاداتها وطريقتها في إدارة شؤونها."
)


func _ready() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate() as GameHUD
	add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame
	Dialogue.start_dialogue(
		"dialogue_ui_visual_test",
		[
			{"speaker": "المعلّم", "text": LONG_ARABIC_LINE},
			{"speaker": "الرسول", "text": "فهمت. سأتابع الطريق الآن."},
		]
	)
	for _frame in range(8):
		await get_tree().process_frame

	var panel := hud.get_node("DialoguePanel") as PanelContainer
	var dialogue := hud.get_node("DialoguePanel/Margin/VBox/Dialogue") as Label
	var viewport_rect := get_viewport().get_visible_rect()
	var panel_rect := panel.get_global_rect()
	var wrapped_line_count := dialogue.get_line_count()
	var failed := false
	if dialogue.text_direction != Control.TEXT_DIRECTION_RTL:
		push_error("Dialogue UI test: Arabic text direction is not RTL.")
		failed = true
	if dialogue.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		push_error("Dialogue UI test: smart word wrapping is disabled.")
		failed = true
	if wrapped_line_count < 2:
		push_error("Dialogue UI test: long Arabic sample did not wrap.")
		failed = true
	if not viewport_rect.encloses(panel_rect):
		push_error("Dialogue UI test: dialogue panel exceeds the viewport safe area.")
		failed = true

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_PATH.get_base_dir()))
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(ProjectSettings.globalize_path(CAPTURE_PATH))
	if save_error != OK:
		push_error("Dialogue UI test: could not save visual capture.")
		failed = true

	var enter_event := InputEventKey.new()
	enter_event.keycode = KEY_ENTER
	enter_event.pressed = true
	hud._unhandled_input(enter_event)
	await get_tree().process_frame
	if dialogue.text != "فهمت. سأتابع الطريق الآن.":
		push_error("Dialogue UI test: Enter did not advance to the next line.")
		failed = true

	var space_event := InputEventKey.new()
	space_event.keycode = KEY_SPACE
	space_event.pressed = true
	hud._unhandled_input(space_event)
	await get_tree().process_frame
	if Dialogue.is_active() or panel.visible:
		push_error("Dialogue UI test: Space did not finish and close dialogue.")
		failed = true

	print(
		"DIALOGUE_UI_VISUAL_TEST: ",
		"FAIL" if failed else "PASS",
		" | wrapped lines=", wrapped_line_count,
		" | panel=", panel_rect.size
	)
	get_tree().quit(1 if failed else 0)
