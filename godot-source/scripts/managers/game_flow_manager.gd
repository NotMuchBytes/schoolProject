extends Node

signal chapter_changed(chapter_id: String)
signal transition_started(scene_path: String)
signal transition_finished(scene_path: String)

var current_chapter: String = "village"
var story_flags: Dictionary = {}

var _transitioning: bool = false
var _overlay: CanvasLayer
var _fade_rect: ColorRect
var _chapter_panel: PanelContainer
var _chapter_title: Label
var _chapter_subtitle: Label

const CHECKPOINT_PATH := "user://history_checkpoint.cfg"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_transition_overlay()


func reset_story() -> void:
	current_chapter = "village"
	story_flags.clear()


func start_new_game() -> void:
	clear_checkpoint()
	reset_story()
	transition_to_scene(
		"res://scenes/levels/main_level.tscn",
		"village",
		"العالم اليوناني",
		"بداية الرحلة التاريخية"
	)


func save_checkpoint(chapter_id: String, scene_path: String, extra: Dictionary = {}) -> void:
	var config := ConfigFile.new()
	config.set_value("campaign", "chapter_id", chapter_id)
	config.set_value("campaign", "scene_path", scene_path)
	config.set_value("campaign", "extra", extra.duplicate(true))
	config.save(CHECKPOINT_PATH)


func get_checkpoint() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(CHECKPOINT_PATH) != OK:
		return {}
	return {
		"chapter_id": str(config.get_value("campaign", "chapter_id", "")),
		"scene_path": str(config.get_value("campaign", "scene_path", "")),
		"extra": config.get_value("campaign", "extra", {}),
	}


func has_checkpoint() -> bool:
	var checkpoint := get_checkpoint()
	return not str(checkpoint.get("scene_path", "")).is_empty()


func clear_checkpoint() -> void:
	if FileAccess.file_exists(CHECKPOINT_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CHECKPOINT_PATH))


func resume_checkpoint() -> bool:
	var checkpoint := get_checkpoint()
	var scene_path := str(checkpoint.get("scene_path", ""))
	var chapter_id := str(checkpoint.get("chapter_id", ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		return false
	reset_story()
	var extra: Dictionary = checkpoint.get("extra", {})
	for key in extra.keys():
		story_flags[str(key)] = extra[key]
	transition_to_scene(scene_path, chapter_id, "متابعة الرحلة", _checkpoint_subtitle(chapter_id, extra))
	return true


func set_flag(flag_name: String, value: Variant = true) -> void:
	story_flags[flag_name] = value


func has_flag(flag_name: String) -> bool:
	return bool(story_flags.get(flag_name, false))


## Persists an in-chapter story step, not just the scene boundary. This keeps
## Continue useful after the player has already spoken to one or more characters.
func save_story_progress(
	stage_key: String, stage_value: String, scene_path: String = ""
) -> void:
	story_flags[stage_key] = stage_value
	var resolved_scene_path := scene_path
	if resolved_scene_path.is_empty() and get_tree().current_scene != null:
		resolved_scene_path = get_tree().current_scene.scene_file_path
	if current_chapter == "menu" or resolved_scene_path.is_empty():
		return
	save_checkpoint(current_chapter, resolved_scene_path, story_flags)


func transition_to_scene(
	scene_path: String,
	chapter_id: String,
	title: String = "",
	subtitle: String = ""
) -> void:
	if _transitioning:
		return
	_transitioning = true
	# A transition can also be triggered immediately after a skipped line. Stop
	# every voice channel before changing scenes so no recording leaks into the
	# next chapter.
	VoiceDirector.stop_all_voice()
	transition_started.emit(scene_path)
	await _fade_to(1.0, 0.45)
	if not title.is_empty():
		_show_chapter_card(title, subtitle)
	var change_error := get_tree().change_scene_to_file(scene_path)
	if change_error != OK:
		push_error("Could not change story scene to %s (error %s)." % [scene_path, change_error])
		_hide_chapter_card()
		await _fade_to(0.0, 0.25)
		_transitioning = false
		return
	current_chapter = chapter_id
	if chapter_id != "menu":
		save_checkpoint(chapter_id, scene_path, story_flags)
	chapter_changed.emit(current_chapter)
	await get_tree().process_frame
	if not title.is_empty():
		await get_tree().create_timer(1.45, true, false, true).timeout
		_hide_chapter_card()
	await _fade_to(0.0, 0.55)
	_transitioning = false
	transition_finished.emit(scene_path)


func play_local_transition(
	title: String,
	subtitle: String = "",
	hold_time: float = 1.2,
	midpoint_action: Callable = Callable()
) -> void:
	if _transitioning:
		return
	_transitioning = true
	await _fade_to(1.0, 0.35)
	_show_chapter_card(title, subtitle)
	if midpoint_action.is_valid():
		midpoint_action.call()
	await get_tree().create_timer(hold_time, true, false, true).timeout
	_hide_chapter_card()
	await _fade_to(0.0, 0.45)
	_transitioning = false


func is_transitioning() -> bool:
	return _transitioning


func _build_transition_overlay() -> void:
	_overlay = CanvasLayer.new()
	_overlay.name = "StoryTransitionOverlay"
	_overlay.layer = 100
	add_child(_overlay)

	_fade_rect = ColorRect.new()
	_fade_rect.name = "Fade"
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0.012, 0.018, 0.03, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_fade_rect)

	_chapter_panel = PanelContainer.new()
	_chapter_panel.name = "ChapterCard"
	_chapter_panel.set_anchors_preset(Control.PRESET_CENTER)
	_chapter_panel.position = Vector2(-360.0, -105.0)
	_chapter_panel.size = Vector2(720.0, 210.0)
	_chapter_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.035, 0.055, 0.96)
	panel_style.border_color = Color(0.78, 0.63, 0.31, 0.92)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0, 0, 0, 0.55)
	panel_style.shadow_size = 14
	_chapter_panel.add_theme_stylebox_override("panel", panel_style)
	_overlay.add_child(_chapter_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 24)
	_chapter_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	_chapter_title = Label.new()
	_chapter_title.layout_direction = Control.LAYOUT_DIRECTION_RTL
	_chapter_title.text_direction = Control.TEXT_DIRECTION_RTL
	_chapter_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chapter_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.46))
	_chapter_title.add_theme_font_size_override("font_size", 34)
	column.add_child(_chapter_title)

	_chapter_subtitle = Label.new()
	_chapter_subtitle.layout_direction = Control.LAYOUT_DIRECTION_RTL
	_chapter_subtitle.text_direction = Control.TEXT_DIRECTION_RTL
	_chapter_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chapter_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_chapter_subtitle.add_theme_color_override("font_color", Color(0.88, 0.89, 0.9))
	_chapter_subtitle.add_theme_font_size_override("font_size", 20)
	column.add_child(_chapter_subtitle)
	_chapter_panel.hide()


func _show_chapter_card(title: String, subtitle: String) -> void:
	_chapter_title.text = title
	_chapter_subtitle.text = subtitle
	_chapter_subtitle.visible = not subtitle.is_empty()
	_chapter_panel.show()


func _hide_chapter_card() -> void:
	_chapter_panel.hide()


func _fade_to(target_alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", target_alpha, duration)
	await tween.finished


func _checkpoint_subtitle(chapter_id: String, extra: Dictionary) -> String:
	if chapter_id == "lesson2":
		return "الحياة العامة — %s" % str(extra.get("lesson2_stage", "intro"))
	match chapter_id:
		"village": return "القرية والمعبد"
		"city_states": return "أثينا وإسبرطة"
		"macedon": return "مقدونيا والإسكندر"
		"historical_map": return "الحملة والإرث الهلنستي"
		_: return ""
