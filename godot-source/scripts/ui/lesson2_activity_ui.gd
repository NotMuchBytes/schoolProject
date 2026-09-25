class_name Lesson2ActivityUI
extends CanvasLayer

signal choice_made(choice_id: String)
signal ending_action(action_id: String)

var _shade: ColorRect
var _panel: PanelContainer
var _title: Label
var _body: Label
var _choices: VBoxContainer
var _activity_badge: Label
var _choice_progress: Label
var _choice_instruction: Label
var _feedback_panel: PanelContainer
var _feedback_icon: Label
var _feedback: Label
var _journal_panel: PanelContainer
var _journal_body: Label
var _journal_tabs: OptionButton
var _journal_counter: Label
var _ending_panel: PanelContainer
var _journal_open := false
var _panel_tween: Tween
var _feedback_tween: Tween
var _journal_tween: Tween
var _ending_tween: Tween

const JOURNAL_PAGES := [
	["١ — السياسة (ص ١٢)", "الملكية كانت النظام الغالب، ثم ظهرت الديمقراطية في أثينا، والحكم العسكري في إسبرطة، والحكم الاستبدادي في بعض المدن."],
	["٢ — الزراعة والصناعة والتجارة (ص ١٢–١٣)", "الحبوب والزيتون والعنب؛ مطاحن ومعاصر وتربية أغنام وأبقار. ازدهرت الصناعة لتوافر المعادن والأخشاب، والمنافسة الفينيقية، وانتشار الأسواق. التجارة داخلية وخارجية عبر البحر والمستعمرات."],
	["٣ — المجتمع (ص ١٣)", "بحسب الدرس: الطبقة الحاكمة، التجار والأثرياء، العامة، العبيد. نعرض هذا التقسيم وصفاً تاريخياً، لا حكماً على قيمة الناس. ويذكر الدرس حقوق المرأة في الملكية والميراث والتعليم."],
	["٤ — الدين (ص ١٤)", "اعتقد اليونان بآلهة تتحكم في قوى الطبيعة، وصوروها وبنوا المعابد. يذكر الدرس زيوس وأبولو وأثينا."],
	["٥ — المسرح (ص ١٤)", "التراجيديا نهاية حزينة، والكوميديا نهاية سعيدة. عناصر المسرح: الجوقة، الأوركسترا، خشبة المسرح، الممثلون."],
	["٦ — الفلسفة والتاريخ (ص ١٤)", "أفلاطون: الجمهورية والقوانين. أرسطو: السياسة. هيرودوتس: الحروب الفارسية، ووصفه الدرس بأبي التاريخ."],
	["٧ — العمارة والنحت (ص ١٥)", "مدينة محاطة بسور، وساحة مركزية تضم المعبد والمسرح، ومبانٍ منتظمة. استخدم النحاتون الرخام والبرونز."],
	["٨ — الرياضة (ص ١٥)", "من الرياضات المذكورة: الجري والمصارعة والملاكمة وسباق الخيل والسباحة ورمي الرمح والقرص. أقيمت الألعاب في أولمبيا كل أربع سنوات."],
	["٩ — التأثير في الأردن (ص ١٦)", "يربط الدرس الأردن بالحملة سنة ٣٣٢ ق.م، ثم البطالمة. ربّة عمون/عمّان ثم فيلادلفيا، وبيلا/طبقة فحل، جدارا/أم قيس، جراسا/جرش، حسبان/حشبون. قصر العبد من القرن الثاني ق.م جنوب عراق الأمير غرب عمّان."],
	["مراجعة (ص ١٧)", "راجع الأنظمة السياسية، أسباب ازدهار الصناعة، طبقات المجتمع، عناصر المسرح، سمات المدينة، وأسماء المواقع الأردنية. يمكنك فتح هذا السجل في أي وقت بالزر J."]
]


func _ready() -> void:
	layer = 30
	_build_activity_panel()
	_build_journal()
	_build_ending()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_J:
		toggle_journal()
		get_viewport().set_input_as_handled()


func show_choice(title: String, body: String, options: Array) -> void:
	_title.text = title
	_body.text = body
	_activity_badge.text = "نشاط تفاعلي"
	_choice_instruction.text = "اختر الإجابة، ثم تابع رحلتك في المدينة"
	_choice_progress.text = "%d خيارات" % options.size()
	_feedback.text = ""
	_feedback_panel.hide()
	for child in _choices.get_children():
		child.queue_free()
	for option_variant in options:
		var option: Dictionary = option_variant
		var button := Button.new()
		button.custom_minimum_size = Vector2(520, 46)
		button.text = str(option.get("label", ""))
		button.text_direction = Control.TEXT_DIRECTION_RTL
		button.add_theme_font_size_override("font_size", 18)
		_style_action_button(button)
		button.pressed.connect(_on_choice_pressed.bind(str(option.get("id", ""))))
		_choices.add_child(button)
	_shade.show()
	_panel.show()
	_animate_panel_in(_panel, "activity")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().process_frame
	if _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).grab_focus()


func show_feedback(text: String, correct: bool) -> void:
	_feedback.text = text
	_feedback_icon.text = "✓" if correct else "↺"
	_feedback_panel.show()
	_feedback.add_theme_color_override(
		"font_color", Color(0.48, 0.9, 0.58) if correct else Color(1.0, 0.72, 0.35)
	)
	_feedback_icon.add_theme_color_override(
		"font_color", Color(0.48, 0.9, 0.58) if correct else Color(1.0, 0.72, 0.35)
	)
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_panel.modulate = Color(1, 1, 1, 0)
	_feedback_panel.position.y = 6.0
	_feedback_tween = create_tween().set_parallel(true)
	_feedback_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(_feedback_panel, "modulate:a", 1.0, 0.18)
	_feedback_tween.tween_property(_feedback_panel, "position:y", 0.0, 0.18)


func hide_choice() -> void:
	_panel.hide()
	if not _journal_open and not _ending_panel.visible:
		_shade.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func toggle_journal() -> void:
	if _ending_panel.visible or _panel.visible:
		return
	_journal_open = not _journal_open
	_journal_panel.visible = _journal_open
	_shade.visible = _journal_open
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _journal_open else Input.MOUSE_MODE_CAPTURED
	if _journal_open:
		_animate_panel_in(_journal_panel, "journal")


func show_ending() -> void:
	_panel.hide()
	_journal_panel.hide()
	_journal_open = false
	_shade.show()
	_ending_panel.show()
	_animate_panel_in(_ending_panel, "ending")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func hide_ending() -> void:
	_ending_panel.hide()
	_shade.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_modal_open() -> bool:
	return _panel.visible or _journal_open or _ending_panel.visible


func _on_choice_pressed(choice_id: String) -> void:
	choice_made.emit(choice_id)


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.05, 0.97)
	style.border_color = Color(0.84, 0.66, 0.31, 0.96)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.58)
	style.shadow_size = 14
	return style


func _make_button_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _style_action_button(button: BaseButton) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.08, 0.105, 0.13, 0.98), Color(0.40, 0.35, 0.24, 0.9)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.15, 0.18, 0.20, 1.0), Color(0.95, 0.70, 0.27, 1.0)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.20, 0.16, 0.09, 1.0), Color(1.0, 0.81, 0.43, 1.0)))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.12, 0.14, 0.17, 1.0), Color(0.42, 0.72, 0.90, 1.0)))
	button.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.84, 0.46))
	button.mouse_entered.connect(_animate_button_hover.bind(button, true))
	button.mouse_exited.connect(_animate_button_hover.bind(button, false))


func _animate_button_hover(button: Control, hovered: bool) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", Color(1.06, 1.04, 0.96, 1.0) if hovered else Color.WHITE, 0.12)


func _animate_panel_in(panel: Control, channel: String) -> void:
	var existing: Tween
	match channel:
		"activity": existing = _panel_tween
		"journal": existing = _journal_tween
		_: existing = _ending_tween
	if existing != null and existing.is_valid():
		existing.kill()
	panel.modulate = Color(1, 1, 1, 0)
	panel.scale = Vector2(0.965, 0.965)
	panel.pivot_offset = panel.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.20)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.20)
	match channel:
		"activity": _panel_tween = tween
		"journal": _journal_tween = tween
		_: _ending_tween = tween


func _build_activity_panel() -> void:
	_shade = ColorRect.new()
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.color = Color(0.005, 0.008, 0.016, 0.68)
	add_child(_shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(700, 470)
	_panel.add_theme_stylebox_override("panel", _make_panel_style())
	center.add_child(_panel)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 30)
	_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.layout_direction = Control.LAYOUT_DIRECTION_RTL
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var status_row := HBoxContainer.new()
	status_row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	status_row.add_theme_constant_override("separation", 10)
	column.add_child(status_row)
	_activity_badge = Label.new()
	_activity_badge.text_direction = Control.TEXT_DIRECTION_RTL
	_activity_badge.add_theme_font_size_override("font_size", 14)
	_activity_badge.add_theme_color_override("font_color", Color(1.0, 0.82, 0.42))
	status_row.add_child(_activity_badge)
	_choice_progress = Label.new()
	_choice_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_choice_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_choice_progress.add_theme_font_size_override("font_size", 13)
	_choice_progress.add_theme_color_override("font_color", Color(0.66, 0.76, 0.82))
	status_row.add_child(_choice_progress)
	_title = Label.new()
	_title.text_direction = Control.TEXT_DIRECTION_RTL
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 27)
	_title.add_theme_color_override("font_color", Color(1, 0.82, 0.42))
	column.add_child(_title)
	_body = Label.new()
	_body.text_direction = Control.TEXT_DIRECTION_RTL
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size", 18)
	column.add_child(_body)
	_choice_instruction = Label.new()
	_choice_instruction.text_direction = Control.TEXT_DIRECTION_RTL
	_choice_instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_choice_instruction.add_theme_font_size_override("font_size", 14)
	_choice_instruction.add_theme_color_override("font_color", Color(0.70, 0.74, 0.76))
	column.add_child(_choice_instruction)
	_choices = VBoxContainer.new()
	_choices.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices.add_theme_constant_override("separation", 8)
	column.add_child(_choices)
	_feedback_panel = PanelContainer.new()
	_feedback_panel.add_theme_stylebox_override("panel", _make_button_style(Color(0.055, 0.07, 0.075, 0.96), Color(0.36, 0.39, 0.34, 0.9)))
	column.add_child(_feedback_panel)
	var feedback_row := HBoxContainer.new()
	feedback_row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	feedback_row.add_theme_constant_override("separation", 10)
	_feedback_panel.add_child(feedback_row)
	_feedback_icon = Label.new()
	_feedback_icon.add_theme_font_size_override("font_size", 21)
	feedback_row.add_child(_feedback_icon)
	_feedback = Label.new()
	_feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_feedback.text_direction = Control.TEXT_DIRECTION_RTL
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.add_theme_font_size_override("font_size", 16)
	feedback_row.add_child(_feedback)
	_feedback_panel.hide()
	_panel.hide()
	_shade.hide()


func _build_journal() -> void:
	_journal_panel = PanelContainer.new()
	_journal_panel.set_anchors_preset(Control.PRESET_CENTER)
	_journal_panel.position = Vector2(-470, -300)
	_journal_panel.size = Vector2(940, 600)
	_journal_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_journal_panel)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 26)
	_journal_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.layout_direction = Control.LAYOUT_DIRECTION_RTL
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var title := Label.new()
	title.text = "سجل التعلم — الدرس الثاني"
	title.text_direction = Control.TEXT_DIRECTION_RTL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.82, 0.42))
	column.add_child(title)
	_journal_tabs = OptionButton.new()
	for page in JOURNAL_PAGES:
		_journal_tabs.add_item(str(page[0]))
	_journal_tabs.item_selected.connect(_on_journal_page_selected)
	_style_action_button(_journal_tabs)
	column.add_child(_journal_tabs)
	_journal_counter = Label.new()
	_journal_counter.text_direction = Control.TEXT_DIRECTION_RTL
	_journal_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_journal_counter.add_theme_font_size_override("font_size", 13)
	_journal_counter.add_theme_color_override("font_color", Color(0.72, 0.70, 0.62))
	column.add_child(_journal_counter)
	_journal_body = Label.new()
	_journal_body.text = str(JOURNAL_PAGES[0][1])
	_journal_body.text_direction = Control.TEXT_DIRECTION_RTL
	_journal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_journal_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_journal_body.custom_minimum_size = Vector2(0, 360)
	_journal_body.add_theme_font_size_override("font_size", 20)
	column.add_child(_journal_body)
	var close := Button.new()
	close.text = "إغلاق السجل  (J)"
	close.text_direction = Control.TEXT_DIRECTION_RTL
	_style_action_button(close)
	close.pressed.connect(toggle_journal)
	column.add_child(close)
	_on_journal_page_selected(0)
	_journal_panel.hide()


func _build_ending() -> void:
	_ending_panel = PanelContainer.new()
	_ending_panel.set_anchors_preset(Control.PRESET_CENTER)
	_ending_panel.position = Vector2(-350, -230)
	_ending_panel.size = Vector2(700, 460)
	_ending_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_ending_panel)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 34)
	_ending_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.layout_direction = Control.LAYOUT_DIRECTION_RTL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	for text in ["اكتمل سجل الحياة العامة", "أنهيت الدرس الثاني: السياسة والاقتصاد والمجتمع والثقافة والرياضة والتأثير في الأردن."]:
		var label := Label.new()
		label.text = text
		label.text_direction = Control.TEXT_DIRECTION_RTL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 30 if column.get_child_count() == 0 else 19)
		column.add_child(label)
	for action in [["explore", "متابعة الاستكشاف الحر"], ["menu", "العودة إلى القائمة الرئيسية"], ["replay", "إعادة الفصل الثاني"], ["quit", "خروج"]]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(420, 48)
		button.text = action[1]
		button.text_direction = Control.TEXT_DIRECTION_RTL
		_style_action_button(button)
		button.pressed.connect(func(): ending_action.emit(action[0]))
		column.add_child(button)
	_ending_panel.hide()


func _on_journal_page_selected(index: int) -> void:
	var safe_index := clampi(index, 0, JOURNAL_PAGES.size() - 1)
	_journal_body.text = str(JOURNAL_PAGES[safe_index][1])
	_journal_counter.text = "صفحة %d من %d" % [safe_index + 1, JOURNAL_PAGES.size()]
