class_name GameHUD
extends CanvasLayer

signal dialogue_finished

@onready var interaction_prompt: Label = $InteractionPrompt
@onready var objective_panel: PanelContainer = $ObjectivePanel
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/Speaker
@onready var dialogue_label: Label = $DialoguePanel/Margin/VBox/Dialogue
@onready var continue_row: HBoxContainer = $DialoguePanel/Margin/VBox/Footer
@onready var continue_hint: Label = $DialoguePanel/Margin/VBox/Footer/ContinueAction/ContinueHint
@onready var continue_indicator: Label = $DialoguePanel/Margin/VBox/Footer/ContinueAction/ContinueIndicator
@onready var mission_name_label: Label = $ObjectivePanel/Margin/VBox/MissionName
@onready var objective_label: Label = $ObjectivePanel/Margin/VBox/Objective
@onready var story_progress_label: Label = $ObjectivePanel/Margin/VBox/StoryProgress
@onready var story_progress_bar: ProgressBar = $ObjectivePanel/Margin/VBox/StoryProgressBar
@onready var completion_panel: PanelContainer = $CompletionPanel
@onready var completion_label: Label = $CompletionPanel/Margin/Message
@onready var cutscene_hint: Label = $CutsceneHint

var _dialogue_lines: PackedStringArray = PackedStringArray()
var _line_index: int = 0
var _completion_id: int = 0
var _cinematic_subtitle_active: bool = false
var _continue_tween: Tween
var _panel_tween: Tween
var _line_tween: Tween
var _objective_visible_before_dialogue: bool = false
var _journey_panel: PanelContainer
var _journey_location: Label
var _journey_step: Label
var _journey_count: Label
var _journey_bar: ProgressBar
var _journey_dots: HBoxContainer
var _journey_tween: Tween
var _completion_tween: Tween
var _completion_base_y: float = 42.0


func _ready() -> void:
	story_progress_bar.add_theme_stylebox_override(
		"background", _make_hud_style(Color(0.11, 0.12, 0.13, 0.9), Color.TRANSPARENT, 3)
	)
	story_progress_bar.add_theme_stylebox_override(
		"fill", _make_hud_style(Color(0.86, 0.64, 0.27, 1.0), Color.TRANSPARENT, 3)
	)
	_completion_base_y = completion_panel.position.y
	show_interaction_prompt(false)
	dialogue_panel.hide()
	completion_panel.hide()
	cutscene_hint.hide()
	_fit_dialogue_panel()
	get_viewport().size_changed.connect(_fit_dialogue_panel)
	_start_continue_animation()
	Dialogue.dialogue_started.connect(_on_dialogue_started)
	Dialogue.line_changed.connect(_on_dialogue_line_changed)
	Dialogue.dialogue_finished.connect(_on_dialogue_manager_finished)
	VoiceDirector.dialogue_voice_started.connect(_on_dialogue_voice_started)
	VoiceDirector.dialogue_voice_finished.connect(_on_dialogue_voice_finished)
	Objectives.objective_changed.connect(_on_objective_changed)
	Objectives.objective_cleared.connect(_on_objective_cleared)
	if not Objectives.objective_text.is_empty():
		_on_objective_changed(Objectives.mission_title, Objectives.objective_text)


func set_objective(objective: String) -> void:
	Objectives.set_objective(mission_name_label.text, objective)


func show_interaction_prompt(should_show: bool) -> void:
	interaction_prompt.visible = should_show and not is_dialogue_active()


func start_dialogue(speaker: String, lines: PackedStringArray) -> void:
	if lines.is_empty():
		return
	var entries: Array = []
	for dialogue_line in lines:
		entries.append({"speaker": speaker, "text": dialogue_line})
	Dialogue.start_dialogue("legacy", entries)


func advance_dialogue() -> void:
	Dialogue.advance()


func close_dialogue() -> void:
	Dialogue.finish_dialogue()


func is_dialogue_active() -> bool:
	return Dialogue.is_active()


func show_cinematic_subtitle(speaker: String, text: String) -> void:
	_cinematic_subtitle_active = true
	speaker_label.text = speaker
	dialogue_label.text = text
	continue_row.hide()
	_show_dialogue_panel()
	_animate_line_change()
	interaction_prompt.hide()


func hide_cinematic_subtitle() -> void:
	if not _cinematic_subtitle_active:
		return
	_cinematic_subtitle_active = false
	if not Dialogue.is_active():
		dialogue_panel.hide()
	continue_row.show()


func show_cutscene_hint(should_show: bool) -> void:
	cutscene_hint.visible = should_show


func show_objective_panel(should_show: bool) -> void:
	objective_panel.visible = should_show


func show_mission_complete(message: String, duration: float = 5.0) -> void:
	show_action_feedback(message, "checkpoint", duration)


## Compact, optional route context for longer chapters. It is hidden by default,
## so existing Lesson 1 scenes retain their current presentation until a story
## controller explicitly opts in.
func set_journey_progress(
	location_ar: String, step_label: String, completed: int, total: int
) -> void:
	var safe_total := maxi(total, 1)
	var safe_completed := clampi(completed, 0, safe_total)
	var location := location_ar if not location_ar.is_empty() else "المدينة"
	story_progress_label.text = "%s  ·  %s / %s" % [
		location, _to_arabic_digits(safe_completed), _to_arabic_digits(safe_total)
	]
	story_progress_label.tooltip_text = step_label
	story_progress_bar.max_value = float(safe_total)
	story_progress_bar.value = float(safe_completed)
	story_progress_label.show()
	story_progress_bar.show()


func clear_journey_progress() -> void:
	story_progress_label.hide()
	story_progress_bar.hide()


## Type-aware feedback retains the existing completion banner API while adding
## distinct, accessible treatment for correct, wrong, and checkpoint moments.
func show_action_feedback(
	message: String, feedback_type: String = "checkpoint", duration: float = 2.2
) -> void:
	_completion_id += 1
	var request_id := _completion_id
	completion_label.text = message
	_apply_action_feedback_style(feedback_type)
	if _completion_tween != null and _completion_tween.is_valid():
		_completion_tween.kill()
	completion_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	completion_panel.position.y = _completion_base_y - 10.0
	completion_panel.show()
	_completion_tween = create_tween().set_parallel(true)
	_completion_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_completion_tween.tween_property(completion_panel, "modulate:a", 1.0, 0.20)
	_completion_tween.tween_property(completion_panel, "position:y", _completion_base_y, 0.20)
	await get_tree().create_timer(duration).timeout
	if request_id == _completion_id:
		_completion_tween = create_tween().set_parallel(true)
		_completion_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_completion_tween.tween_property(completion_panel, "modulate:a", 0.0, 0.16)
		_completion_tween.tween_property(
			completion_panel, "position:y", _completion_base_y - 6.0, 0.16
		)
		await _completion_tween.finished
		if request_id == _completion_id:
			completion_panel.hide()
			completion_panel.modulate = Color.WHITE
			completion_panel.position.y = _completion_base_y


func _on_dialogue_started(_context_id: String) -> void:
	_cinematic_subtitle_active = false
	_objective_visible_before_dialogue = objective_panel.visible
	objective_panel.hide()
	continue_row.show()
	continue_hint.text = "متابعة"
	_show_dialogue_panel()
	interaction_prompt.hide()


func _on_dialogue_line_changed(speaker: String, text: String, _index: int, _count: int) -> void:
	speaker_label.text = speaker
	dialogue_label.text = text
	_animate_line_change()


func _on_dialogue_manager_finished(_context_id: String) -> void:
	dialogue_panel.hide()
	objective_panel.visible = (
		_objective_visible_before_dialogue and not Objectives.objective_text.is_empty()
	)
	_dialogue_lines = PackedStringArray()
	_line_index = 0
	continue_hint.text = "متابعة"
	dialogue_finished.emit()


func _on_dialogue_voice_started(_line_id: String, _speaker_id: String, _duration: float) -> void:
	continue_hint.text = "تخطي الصوت"


func _on_dialogue_voice_finished(_line_id: String, _skipped: bool) -> void:
	continue_hint.text = "متابعة"


func _on_objective_changed(mission_title: String, objective: String) -> void:
	mission_name_label.text = mission_title
	objective_label.text = objective
	objective_panel.show()


func _on_objective_cleared() -> void:
	objective_panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	# E remains on the existing interaction action. These extra keys make the
	# dialogue footer truthful without changing player or story-controller input.
	if not Dialogue.is_active():
		return
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	var key := key_event.keycode if key_event.keycode != 0 else key_event.physical_keycode
	if key in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		Dialogue.advance()
		get_viewport().set_input_as_handled()


func _show_dialogue_panel() -> void:
	var was_visible := dialogue_panel.visible
	dialogue_panel.show()
	if was_visible:
		return
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	dialogue_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_panel_tween = create_tween()
	_panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_panel_tween.tween_property(dialogue_panel, "modulate:a", 1.0, 0.18)


func _animate_line_change() -> void:
	# The complete Arabic string is always rendered at once so contextual letter
	# shaping is never broken by a character-by-character typewriter effect.
	if _line_tween != null and _line_tween.is_valid():
		_line_tween.kill()
	dialogue_label.modulate = Color(1.0, 1.0, 1.0, 0.56)
	speaker_label.modulate = Color(1.0, 1.0, 1.0, 0.72)
	_line_tween = create_tween().set_parallel(true)
	_line_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_line_tween.tween_property(dialogue_label, "modulate:a", 1.0, 0.14)
	_line_tween.tween_property(speaker_label, "modulate:a", 1.0, 0.14)


func _start_continue_animation() -> void:
	if _continue_tween != null and _continue_tween.is_valid():
		_continue_tween.kill()
	continue_indicator.modulate = Color(1.0, 1.0, 1.0, 0.48)
	_continue_tween = create_tween().set_loops()
	_continue_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_continue_tween.tween_property(continue_indicator, "modulate:a", 1.0, 0.62)
	_continue_tween.tween_property(continue_indicator, "modulate:a", 0.48, 0.62)


func _build_journey_panel() -> void:
	_journey_panel = PanelContainer.new()
	_journey_panel.name = "JourneyProgressPanel"
	# The project-wide Arabic locale mirrors auto-layout controls. Keep this
	# outer shell explicitly LTR and pin it to the physical top-left; the text
	# containers inside remain RTL. This prevents it from landing underneath the
	# objective panel on the physical top-right in Web exports.
	_journey_panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	_journey_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_journey_panel.add_theme_stylebox_override(
		"panel",
		_make_hud_style(Color(0.025, 0.04, 0.06, 0.92), Color(0.68, 0.53, 0.26, 0.9), 8)
	)
	add_child(_journey_panel)
	_journey_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_journey_panel.position = Vector2(22.0, 22.0)
	_journey_panel.size = Vector2(306.0, 122.0)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_bottom", 10)
	_journey_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.layout_direction = Control.LAYOUT_DIRECTION_RTL
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)

	var top_row := HBoxContainer.new()
	top_row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_theme_constant_override("separation", 8)
	column.add_child(top_row)
	_journey_location = Label.new()
	_journey_location.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_journey_location.text_direction = Control.TEXT_DIRECTION_RTL
	_journey_location.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_journey_location.add_theme_color_override("font_color", Color(1.0, 0.83, 0.45))
	_journey_location.add_theme_font_size_override("font_size", 17)
	top_row.add_child(_journey_location)
	_journey_count = Label.new()
	_journey_count.text_direction = Control.TEXT_DIRECTION_RTL
	_journey_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_journey_count.add_theme_color_override("font_color", Color(0.83, 0.79, 0.67))
	_journey_count.add_theme_font_size_override("font_size", 13)
	top_row.add_child(_journey_count)

	_journey_step = Label.new()
	_journey_step.text_direction = Control.TEXT_DIRECTION_RTL
	_journey_step.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_journey_step.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_journey_step.max_lines_visible = 2
	_journey_step.add_theme_color_override("font_color", Color(0.96, 0.95, 0.9))
	_journey_step.add_theme_font_size_override("font_size", 14)
	column.add_child(_journey_step)

	_journey_bar = ProgressBar.new()
	_journey_bar.custom_minimum_size = Vector2(0.0, 7.0)
	_journey_bar.show_percentage = false
	_journey_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_journey_bar.add_theme_stylebox_override(
		"background", _make_hud_style(Color(0.11, 0.12, 0.13, 0.9), Color.TRANSPARENT, 4)
	)
	_journey_bar.add_theme_stylebox_override(
		"fill", _make_hud_style(Color(0.86, 0.64, 0.27, 1.0), Color.TRANSPARENT, 4)
	)
	column.add_child(_journey_bar)

	_journey_dots = HBoxContainer.new()
	_journey_dots.layout_direction = Control.LAYOUT_DIRECTION_RTL
	_journey_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	_journey_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_journey_dots.add_theme_constant_override("separation", 4)
	column.add_child(_journey_dots)
	_journey_panel.hide()


func _rebuild_journey_dots(completed: int, total: int) -> void:
	for child in _journey_dots.get_children():
		_journey_dots.remove_child(child)
		child.queue_free()
	_journey_dots.visible = total <= 12
	if not _journey_dots.visible:
		return
	for index in total:
		var dot := Label.new()
		dot.text = "●" if index < completed else "○"
		dot.text_direction = Control.TEXT_DIRECTION_LTR
		dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dot.add_theme_font_size_override("font_size", 11 if index != completed else 13)
		dot.add_theme_color_override(
			"font_color",
			Color(0.94, 0.72, 0.32, 1.0)
			if index < completed
			else Color(0.62, 0.63, 0.61, 0.62)
		)
		_journey_dots.add_child(dot)


func _apply_action_feedback_style(feedback_type: String) -> void:
	var background := Color(0.08, 0.12, 0.11, 0.96)
	var border := Color(0.9, 0.73, 0.3, 1.0)
	var foreground := Color(1.0, 0.88, 0.48, 1.0)
	match feedback_type.to_lower():
		"correct", "success":
			background = Color(0.035, 0.13, 0.095, 0.96)
			border = Color(0.35, 0.86, 0.55, 1.0)
			foreground = Color(0.7, 1.0, 0.79, 1.0)
		"wrong", "error":
			background = Color(0.16, 0.07, 0.055, 0.97)
			border = Color(0.95, 0.47, 0.31, 1.0)
			foreground = Color(1.0, 0.76, 0.63, 1.0)
		"checkpoint", "objective":
			pass
	completion_panel.add_theme_stylebox_override(
		"panel", _make_hud_style(background, border, 10)
	)
	completion_label.add_theme_color_override("font_color", foreground)


func _make_hud_style(
	background: Color, border: Color, corner_radius: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1 if border.a > 0.0 else 0)
	style.set_corner_radius_all(corner_radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 8
	return style


func _to_arabic_digits(value: int) -> String:
	var result := str(value)
	var western := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var arabic := ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
	for index in western.size():
		result = result.replace(western[index], arabic[index])
	return result


func _fit_dialogue_panel() -> void:
	# Keep a cinematic width at 1280p while retaining safe margins on narrower
	# aspect ratios supported by the project's canvas-item stretch mode.
	var viewport_width := get_viewport().get_visible_rect().size.x
	var half_width := minf(455.0, viewport_width * 0.43)
	dialogue_panel.offset_left = -half_width
	dialogue_panel.offset_right = half_width
	if _journey_panel != null:
		_journey_panel.size.x = minf(306.0, maxf(240.0, viewport_width * 0.42))
