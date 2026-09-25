extends Control

@onready var map_view: HistoricalMapView = $MapFrame/Margin/MapView
@onready var chapter_title: Label = $Header/Margin/VBox/ChapterTitle
@onready var chapter_subtitle: Label = $Header/Margin/VBox/ChapterSubtitle
@onready var timeline_label: Label = $TimelineLabel
@onready var narration_panel: PanelContainer = $NarrationPanel
@onready var narration_speaker: Label = $NarrationPanel/Margin/VBox/Speaker
@onready var narration_text: Label = $NarrationPanel/Margin/VBox/Text
@onready var division_legend: PanelContainer = $DivisionLegend
@onready var ending_overlay: ColorRect = $EndingOverlay
@onready var continue_button: Button = $EndingOverlay/Center/EndingPanel/Margin/VBox/Buttons/ContinueButton
@onready var replay_button: Button = $EndingOverlay/Center/EndingPanel/Margin/VBox/Buttons/ReplayButton

var _advance_requested: bool = false
var _skip_all_requested: bool = false
var _ending_visible: bool = false
var _auto_continue_pending: bool = false


func _ready() -> void:
	GameFlow.current_chapter = "historical_map"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Objectives.clear_objective()
	division_legend.hide()
	ending_overlay.hide()
	map_view.reset_campaign()
	AudioDirector.stop_ambient()
	AudioDirector.play_music("alexander_campaign_theme")
	call_deferred("_run_complete_map_story")


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if _ending_visible:
		if key_event.keycode == KEY_R:
			_on_replay_pressed()
		return
	if key_event.keycode == KEY_ESCAPE:
		_skip_all_requested = true
		_advance_requested = true
		VoiceDirector.stop_narrator(true)
		map_view.fast_forward_active_animation()
		get_viewport().set_input_as_handled()
	elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_E]:
		if VoiceDirector.stop_narrator(true):
			get_viewport().set_input_as_handled()
			return
		_advance_requested = true
		map_view.fast_forward_active_animation()
		get_viewport().set_input_as_handled()


func _run_complete_map_story() -> void:
	await _run_campaign_sequence()
	if _skip_all_requested:
		_show_ending()
		return
	await _run_division_sequence()
	if _skip_all_requested:
		_show_ending()
		return
	await _run_hellenistic_epilogue()
	_show_ending()


func _run_campaign_sequence() -> void:
	chapter_title.text = "حملة الإسكندر الأكبر"
	chapter_subtitle.text = "من اليونان إلى أقاليم الإمبراطورية الفارسية"
	timeline_label.text = "مسار الحملة  ٠ / ٥"
	var lines := VoiceCatalog.normalize_entries("campaign_narration", StoryContent.campaign_narration())

	_show_narration(lines[0])
	AudioDirector.play_sfx("map_route_greece_asia_minor")
	await map_view.animate_campaign_stage(0.19, Vector2(0.21, 0.30), 1.58, 3.4)
	await _wait_for_reading(4.5)
	if _skip_all_requested:
		return

	timeline_label.text = "مسار الحملة  ١ / ٥"
	_show_narration(lines[1])
	AudioDirector.play_sfx("persian_confrontation")
	await map_view.animate_campaign_stage(0.29, Vector2(0.33, 0.37), 1.48, 3.5)
	await map_view.animate_persian_confrontation(4.2)
	await _wait_for_reading(4.8)
	if _skip_all_requested:
		return

	map_view.confrontation_progress = 0.0
	timeline_label.text = "مسار الحملة  ٢ / ٥"
	_show_narration(lines[2])
	AudioDirector.play_sfx("map_route_egypt")
	await map_view.animate_campaign_stage(0.46, Vector2(0.22, 0.62), 1.48, 3.6)
	await _wait_for_reading(4.8)
	if _skip_all_requested:
		return

	timeline_label.text = "مسار الحملة  ٣ / ٥"
	_show_narration(lines[3])
	AudioDirector.play_sfx("map_route_east")
	await map_view.animate_campaign_stage(0.86, Vector2(0.64, 0.49), 1.16, 4.2)
	await _wait_for_reading(5.0)
	if _skip_all_requested:
		return

	timeline_label.text = "مسار الحملة  ٤ / ٥"
	_show_narration(lines[4])
	await map_view.animate_campaign_stage(0.94, Vector2(0.83, 0.52), 1.34, 3.6)
	await _wait_for_reading(4.8)
	if _skip_all_requested:
		return
	await map_view.animate_campaign_stage(1.0, Vector2(0.455, 0.48), 1.62, 3.0)

	timeline_label.text = "مسار الحملة  ٥ / ٥"
	chapter_title.text = "بابل"
	chapter_subtitle.text = "وفاة الإسكندر المقدوني في بابل"
	AudioDirector.play_music("babylon_low_atmosphere")
	await map_view.animate_atmosphere_darken(0.78, 2.4)
	_show_narration(lines[5])
	await _wait_for_reading(5.5)
	if _skip_all_requested:
		return
	_show_narration(lines[6])
	await _wait_for_reading(5.5)


func _run_division_sequence() -> void:
	await map_view.animate_atmosphere_darken(0.0, 1.2)
	await map_view.animate_camera_to(Vector2(0.5, 0.52), 1.0, 2.0)
	map_view.set_division(0)
	division_legend.show()
	chapter_title.text = "ما بعد الإسكندر"
	chapter_subtitle.text = "انقسام الإمبراطورية بين كبار القادة"
	timeline_label.text = "تقسيم الإمبراطورية"
	AudioDirector.play_music("successor_kingdoms_theme")
	var lines := VoiceCatalog.normalize_entries("division_narration", StoryContent.division_narration())

	_show_narration(lines[0])
	await _wait_for_reading(5.5)
	if _skip_all_requested:
		return

	await map_view.animate_division_to(1, 2.2)
	$DivisionLegend/Margin/VBox/Antigonus.modulate = Color(1, 1, 1, 1)
	_show_narration(lines[1])
	AudioDirector.play_sfx("successor_region_reveal")
	await _wait_for_reading(5.5)
	if _skip_all_requested:
		return

	await map_view.animate_division_to(2, 2.2)
	$DivisionLegend/Margin/VBox/Ptolemy.modulate = Color(1, 1, 1, 1)
	_show_narration(lines[2])
	AudioDirector.play_sfx("successor_region_reveal")
	await _wait_for_reading(6.0)
	if _skip_all_requested:
		return

	await map_view.animate_division_to(3, 2.4)
	$DivisionLegend/Margin/VBox/Seleucus.modulate = Color(1, 1, 1, 1)
	_show_narration(lines[3])
	AudioDirector.play_sfx("successor_region_reveal")
	await _wait_for_reading(6.0)
	if _skip_all_requested:
		return

	_show_narration(lines[4])
	await _wait_for_reading(5.5)


func _run_hellenistic_epilogue() -> void:
	chapter_title.text = "الحضارة الهلنستية"
	chapter_subtitle.text = "حين التقت الثقافة اليونانية بثقافات الشرق"
	timeline_label.text = "إرثٌ تجاوز حدود الممالك"
	division_legend.hide()
	AudioDirector.play_music("hellenistic_epilogue_theme")
	await map_view.animate_hellenistic_blend(4.0)
	var lines := VoiceCatalog.normalize_entries("hellenistic_narration", StoryContent.hellenistic_narration())
	for entry_variant in lines:
		if _skip_all_requested:
			return
		_show_narration(entry_variant)
		await _wait_for_reading(7.0)


func _show_narration(entry_variant: Variant) -> void:
	var entry: Dictionary = entry_variant
	narration_speaker.text = str(entry.get("speaker", "الراوي"))
	narration_text.text = str(entry.get("text", ""))
	VoiceDirector.play_narrator_entry(entry)
	narration_panel.show()


func _wait_for_reading(duration: float) -> void:
	_advance_requested = false
	var elapsed := 0.0
	while (
		(elapsed < duration or VoiceDirector.is_narrator_playing())
		and not _advance_requested
		and not _skip_all_requested
	):
		var delta := get_process_delta_time()
		if delta <= 0.0:
			delta = 0.016
		elapsed += delta
		await get_tree().process_frame


func _show_ending() -> void:
	if _ending_visible:
		return
	_ending_visible = true
	map_view.fast_forward_active_animation()
	VoiceDirector.stop_narrator(false)
	map_view.set_division(3)
	map_view.hellenistic_blend = 1.0
	narration_panel.hide()
	division_legend.hide()
	timeline_label.hide()
	ending_overlay.show()
	continue_button.grab_focus()
	AudioDirector.play_music("journey_end_theme")
	_auto_continue_pending = true
	call_deferred("_auto_continue_to_lesson2")


func _auto_continue_to_lesson2() -> void:
	# The old ending remains visible long enough to read, then the campaign
	# continues without presenting a menu break between the two chapters.
	await get_tree().create_timer(4.0, true, false, false).timeout
	if _auto_continue_pending and _ending_visible and not GameFlow.is_transitioning():
		_on_continue_pressed()


func _on_replay_pressed() -> void:
	_auto_continue_pending = false
	if GameFlow.is_transitioning():
		return
	GameFlow.reset_story()
	GameFlow.transition_to_scene(
		"res://scenes/levels/main_level.tscn",
		"village",
		"العالم اليوناني",
		"بداية رحلة جديدة"
	)


func _on_continue_pressed() -> void:
	_auto_continue_pending = false
	if GameFlow.is_transitioning():
		return
	GameFlow.transition_to_scene(
		"res://scenes/levels/lesson2_level.tscn",
		"lesson2",
		"الدرس الثاني",
		"الحياة العامة في الحضارة اليونانية"
	)


func _on_menu_pressed() -> void:
	_auto_continue_pending = false
	if GameFlow.is_transitioning():
		return
	GameFlow.transition_to_scene("res://scenes/ui/chapter_select.tscn", "menu")


func _on_quit_pressed() -> void:
	_auto_continue_pending = false
	get_tree().quit()
