extends StoryLevelController

const CHAPTER_TITLE := "الحياة العامة في الحضارة اليونانية"
const LESSON2_SCENE := "res://scenes/levels/lesson2_level.tscn"

@onready var activity_ui: Lesson2ActivityUI = $Lesson2ActivityUI

var _npcs: Dictionary = {}
var _spots: Dictionary = {}
var _nearby_spots: Array[Lesson2InteractionSpot] = []
var _stage := "intro"
var _items: Dictionary = {}
var _carried_item := ""
var _emblems: Dictionary = {}
var _sport_checkpoint := 0
var _sport_started_msec := 0
var _activity_running := false
var _held_system: Node
var _last_progress_msec := 0
var _guidance_level := 0
var _reveal_running := false
var _journey_refresh_time := 0.0
var _journey_target_key := ""
var _journey_ui_index := -1
var _primary_guidance_spot: Lesson2InteractionSpot

const JORDAN_ORDER = [
	"jordan_amman", "jordan_pella", "jordan_gadara", "jordan_gerasa", "jordan_heshbon",
]


func _ready() -> void:
	GameFlow.current_chapter = "lesson2"
	AudioDirector.play_music("lesson2_city_theme")
	AudioDirector.play_ambient("lesson2_city_ambience")
	_npcs = {
		"guide": $Characters/Guide,
		"politics": $Characters/CivicGuide,
		"farm": $Characters/Farmer,
		"industry": $Characters/Artisan,
		"trade": $Characters/Merchant,
		"society": $Characters/Scribe,
		"beliefs": $Characters/TempleGuide,
		"theatre": $Characters/TheatreDirector,
		"ideas": $Characters/LibraryGuide,
		"architecture": $Characters/Builder,
		"sport": $Characters/Coach,
		"jordan": $Characters/JordanGuide,
	}
	for npc_variant in _npcs.values():
		(npc_variant as Node).call("set_interaction_enabled", false)
	activity_ui.ending_action.connect(_on_ending_action)
	super._ready()
	await get_tree().process_frame
	for spot_node in get_tree().get_nodes_in_group("lesson2_spot"):
		if not is_ancestor_of(spot_node):
			continue
		var spot := spot_node as Lesson2InteractionSpot
		_spots[spot.spot_id] = spot
		spot.proximity_changed.connect(_on_spot_proximity_changed)
		spot.set_interaction_enabled(false)
	_setup_physical_interactions()
	_setup_journey_guidance()
	_mark_progress()
	var checkpoint_stage := str(GameFlow.story_flags.get("lesson2_stage", "intro"))
	_restore_emblems_for_stage(checkpoint_stage)
	_start_from_checkpoint(checkpoint_stage)


func _process(delta: float) -> void:
	_journey_refresh_time -= delta
	if _journey_refresh_time <= 0.0:
		_refresh_journey_guidance(false)
	if not _stage.ends_with("_task") or Dialogue.is_active() or cutscene == null or cutscene.is_active():
		return
	var idle_seconds := float(Time.get_ticks_msec() - _last_progress_msec) / 1000.0
	var requested_level := 2 if idle_seconds >= 52.0 else 1 if idle_seconds >= 26.0 else 0
	if requested_level == _guidance_level:
		return
	_guidance_level = requested_level
	for spot_variant in _spots.values():
		var spot := spot_variant as Lesson2InteractionSpot
		if spot.interaction_enabled and spot.has_method("set_guidance_level"):
			spot.call("set_guidance_level", _guidance_level)
	if _guidance_level == 2:
		_feedback("ظهرت إشارة أوضح قرب الهدف التالي؛ اتبعها عندما تكون مستعداً.")


func _start_from_checkpoint(stage_name: String) -> void:
	_stage = stage_name
	match stage_name:
		"politics_npc": _set_active_npc("politics", "اتجه إلى دليل الساحة")
		"politics_task": _begin_politics()
		"farm_npc": _set_active_npc("farm", "اتجه إلى المزارع في الحقول الغربية")
		"farm_task": _begin_farm()
		"industry_npc": _set_active_npc("industry", "تحدث إلى الحرفي في حي الورش")
		"industry_task": _begin_industry()
		"trade_npc": _set_active_npc("trade", "تحدث إلى التاجر عند السوق")
		"trade_task": _begin_trade()
		"society_npc": _set_active_npc("society", "اتجه إلى كاتب السجل")
		"society_task": _begin_society()
		"beliefs_npc": _set_active_npc("beliefs", "اتجه إلى دليل المعبد")
		"beliefs_task": _begin_beliefs()
		"theatre_npc": _set_active_npc("theatre", "اتجه إلى مشرف المسرح")
		"theatre_task": _begin_theatre()
		"ideas_npc": _set_active_npc("ideas", "اتجه إلى دليل المكتبة")
		"ideas_task": _begin_ideas()
		"architecture_npc": _set_active_npc("architecture", "اتجه إلى البنّاء")
		"architecture_task": _begin_architecture()
		"sport_npc": _set_active_npc("sport", "اتجه إلى المدرب")
		"sport_task": _begin_sport()
		"jordan_npc": _set_active_npc("jordan", "اتجه إلى دليل الآثار")
		"jordan_task": _begin_jordan()
		"final_board": _begin_final_board()
		"complete": _begin_final_board()
		_:
			_checkpoint("intro")
			_set_active_npc("guide", "تحدث إلى دليل المدينة لفتح سجل الحياة العامة")


func on_npc_interaction_requested(npc: Node) -> void:
	if _activity_running:
		return
	var context_id := ""
	var entries: Array = []
	if npc == _npcs["guide"]:
		context_id = "l2_intro"
		entries = Lesson2Content.entries("l2_intro_")
	elif npc == _npcs["politics"]:
		context_id = "l2_politics"
		entries = Lesson2Content.entries("l2_politics_")
	elif npc == _npcs["farm"]:
		context_id = "l2_farm"
		entries = Lesson2Content.entries("l2_farm_")
	elif npc == _npcs["industry"]:
		context_id = "l2_workshop"
		entries = Lesson2Content.entries("l2_workshop_")
	elif npc == _npcs["trade"]:
		context_id = "l2_trade"
		entries = Lesson2Content.entries("l2_trade_")
	elif npc == _npcs["society"]:
		context_id = "l2_society"
		entries = Lesson2Content.entries("l2_society_")
	elif npc == _npcs["beliefs"]:
		context_id = "l2_religion"
		entries = Lesson2Content.entries("l2_religion_")
	elif npc == _npcs["theatre"]:
		context_id = "l2_theatre"
		entries = [Lesson2Content.entry("l2_theatre_001"), Lesson2Content.entry("l2_theatre_002"), Lesson2Content.entry("l2_theatre_003")]
	elif npc == _npcs["ideas"]:
		context_id = "l2_ideas"
		entries = Lesson2Content.entries("l2_ideas_")
	elif npc == _npcs["architecture"]:
		context_id = "l2_architecture"
		entries = Lesson2Content.entries("l2_architecture_")
	elif npc == _npcs["sport"]:
		context_id = "l2_sport"
		entries = Lesson2Content.entries("l2_sport_")
	elif npc == _npcs["jordan"]:
		context_id = "l2_jordan"
		entries = Lesson2Content.entries("l2_jordan_")
	if not context_id.is_empty():
		set_npc_available(npc, false, false)
		start_conversation(npc as Node3D, context_id, entries)


func on_story_conversation_finished(context_id: String, _npc: Node3D) -> void:
	match context_id:
		"l2_intro":
			_checkpoint("politics_npc")
			_set_active_npc("politics", "اتجه إلى دليل الساحة")
		"l2_politics": _begin_politics()
		"l2_farm": _begin_farm()
		"l2_workshop": _begin_industry()
		"l2_trade": _begin_trade()
		"l2_society": _begin_society()
		"l2_religion": _begin_beliefs()
		"l2_theatre": _begin_theatre()
		"l2_ideas": _begin_ideas()
		"l2_architecture": _begin_architecture()
		"l2_sport": _begin_sport()
		"l2_jordan": _begin_jordan()


func _on_player_interact_pressed() -> void:
	if Dialogue.is_active():
		Dialogue.advance()
		return
	if activity_ui.is_modal_open() or _activity_running or cutscene.is_active() or GameFlow.is_transitioning():
		return
	var spot := _nearest_spot()
	if spot != null:
		_activate_spot(spot)
		return
	super._on_player_interact_pressed()


func _activate_spot(spot: Lesson2InteractionSpot) -> void:
	var id := spot.spot_id
	if id.begins_with("politics_"):
		_handle_politics(id)
	elif id.begins_with("farm_"):
		_handle_farm(id)
	elif id.begins_with("industry_"):
		_handle_industry(id)
	elif id.begins_with("trade_"):
		_handle_trade(id)
	elif id.begins_with("society_"):
		_handle_society(id)
	elif id.begins_with("belief_"):
		_handle_beliefs(id)
	elif id.begins_with("theatre_"):
		_handle_theatre(id)
	elif id.begins_with("ideas_"):
		_handle_ideas(id)
	elif id.begins_with("arch_"):
		_handle_architecture(id)
	elif id == "sport_start":
		_show_sport_start()
	elif id.begins_with("jordan_"):
		_handle_jordan(id)
	elif id == "final_board":
		_run_final_sequence()


func _begin_politics() -> void:
	_checkpoint("politics_task")
	_reset_task()
	_enable_many(["politics_monarchy", "politics_athens", "politics_sparta", "politics_despotism"])
	set_objective(CHAPTER_TITLE, "افحص ألواح أنظمة الحكم، واحمل كل لوح إلى العرض المدني  •  ٠ / ٤")
	_play_reveal("l2_agora_reveal", Vector3(15, 7.2, 24), Vector3(0, 0.8, 12), 2.6)


func _handle_politics(id: String) -> void:
	if id == "politics_display":
		if not _carried_item.begins_with("politics_"):
			_feedback("احمل لوحاً مدنياً أولاً، ثم ضعه في هذا العرض.", "wrong")
			return
		var placed_id := _carried_item
		var slot := _items.size()
		_place_carried_at(id, Vector3(-0.9 + slot * 0.6, 0.95, 0.1), "tablet")
		_items[placed_id] = true
		_set_spot_enabled(id, false)
		_mark_progress()
		var placed_count := _count_prefix("politics_")
		if placed_count == 4:
			_award_emblem("Politics", "شعار السياسة")
			_react_npc("politics", "acknowledge")
			_checkpoint("farm_npc")
			_set_active_npc("farm", "اتجه إلى المزارع في الحقول الغربية")
		else:
			set_objective(CHAPTER_TITLE, "أكمل وضع ألواح الحكم في العرض المدني  •  %d / ٤" % placed_count)
		return
	if id in ["politics_monarchy", "politics_athens", "politics_sparta", "politics_despotism"]:
		if not _pick_up_from_spot(id, "tablet"):
			return
		_set_spot_enabled("politics_display", true)
		set_objective(CHAPTER_TITLE, "احمل اللوح إلى العرض المدني في وسط الساحة")


func _begin_farm() -> void:
	_checkpoint("farm_task")
	_reset_task()
	_enable_many(["farm_grain", "farm_olives", "farm_grapes"])
	set_objective(CHAPTER_TITLE, "احصد محصولاً، ثم احمله إلى محطة معالجته  •  ٠ / ٣")


func _handle_farm(id: String) -> void:
	if id in ["farm_grain", "farm_olives", "farm_grapes"]:
		if not _pick_up_from_spot(id, "harvest"):
			return
		var target: String = str({"farm_grain":"farm_mill", "farm_olives":"farm_press", "farm_grapes":"farm_market_delivery"}[id])
		_set_spot_enabled(target, true)
		set_objective(CHAPTER_TITLE, {
			"farm_grain":"احمل الحبوب إلى حجر المطحنة.",
			"farm_olives":"احمل سلة الزيتون إلى المعصرة.",
			"farm_grapes":"احمل العنب إلى سلة السوق.",
		}[id])
	elif id == "farm_market_delivery" and _carried_item == "farm_finished_goods":
		_place_carried_at(id, Vector3(0.35, 0.65, 0), "basket")
		_set_spot_enabled(id, false)
		_react_npc("farm", "acknowledge")
		_checkpoint("industry_npc")
		_set_active_npc("industry", "انتقل إلى الحرفي في حي الورش")
	elif id in ["farm_mill", "farm_press", "farm_market_delivery"]:
		var expected: String = str({"farm_mill":"farm_grain", "farm_press":"farm_olives", "farm_market_delivery":"farm_grapes"}[id])
		if _carried_item != expected:
			_feedback("هذا المحصول يحتاج إلى محطة أخرى؛ احتفظ به وحاول مجدداً.", "wrong")
			return
		_place_carried_at(id, Vector3(0, 0.75, 0), "harvest")
		_items[expected] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
		if id == "farm_press":
			_play_reveal("l2_olive_press_reveal", Vector3(-8, 4.2, -1), Vector3(-15, 0.8, -5), 2.2)
		_mark_progress()
		var count := _count_prefix("farm_")
		if count < 3:
			set_objective(CHAPTER_TITLE, "تابع حصاد المحاصيل ومعالجتها  •  %d / ٣" % count)
		else:
			_pick_up_virtual_item("farm_finished_goods", _spots[id].global_transform, "basket")
			_set_spot_enabled("farm_market_delivery", true)
			set_objective(CHAPTER_TITLE, "احمل سلة المنتجات النهائية إلى السوق")


func _begin_industry() -> void:
	_checkpoint("industry_task")
	_reset_task()
	_enable_many(["industry_wood", "industry_metal", "industry_clay", "industry_ship", "industry_tools", "industry_pottery"])
	set_objective(CHAPTER_TITLE, "طابق الخشب والمعدن والطين مع محطات الصناعة  •  ٠ / ٣")


func _handle_industry(id: String) -> void:
	var expected := {"industry_ship":"industry_wood", "industry_tools":"industry_metal", "industry_pottery":"industry_clay"}
	if id in ["industry_wood", "industry_metal", "industry_clay"]:
		if not _pick_up_from_spot(id, "material"):
			return
		_feedback("تحمل الآن: %s" % _material_name(id))
	elif expected.has(id):
		if _carried_item != expected[id]:
			_feedback("هذه المادة لا تناسب المحطة؛ جرّب محطة أخرى", "wrong")
			return
		_place_carried_at(id, Vector3(0, 0.8, 0), "material")
		_items[id] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("industry", "receive")
		_mark_progress()
		var count := _items.size()
		set_objective(CHAPTER_TITLE, "أكمل طلبات الورشة  •  %d / ٣" % count)
		if count == 3:
			_checkpoint("trade_npc")
			_set_active_npc("trade", "اتبع السلع إلى التاجر في السوق")


func _begin_trade() -> void:
	_checkpoint("trade_task")
	_reset_task()
	_enable_many(["trade_local_crate", "trade_external_crate", "trade_market_drop", "trade_harbour_drop"])
	set_objective(CHAPTER_TITLE, "وجّه صندوق السوق المحلي وصندوق المرفأ إلى وجهتيهما")
	_play_reveal("l2_harbour_reveal", Vector3(33, 6.5, 4), Vector3(22, 0.5, -7), 2.7)


func _handle_trade(id: String) -> void:
	var expected := {"trade_market_drop":"trade_local_crate", "trade_harbour_drop":"trade_external_crate"}
	if id in ["trade_local_crate", "trade_external_crate"]:
		if not _pick_up_from_spot(id, "crate"):
			return
		_feedback("حملت %s" % ("بضاعة السوق المحلي" if id.ends_with("local_crate") else "بضاعة التجارة الخارجية"))
	elif expected.has(id):
		if _carried_item != expected[id]:
			_feedback("ليست هذه وجهة الصندوق", "wrong")
			return
		_place_carried_at(id, Vector3(0, 0.65, 0), "crate")
		_items[id] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("trade", "receive")
		_mark_progress()
		if _items.size() == 2:
			_set_spot_enabled("trade_dock_follow", true)
			set_objective(CHAPTER_TITLE, "اتبع الشحنة البحرية حتى نهاية الرصيف")
	elif id == "trade_dock_follow":
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("trade", "approve")
		_mark_progress()
		_award_emblem("Economy", "شعار الاقتصاد")
		_checkpoint("society_npc")
		_set_active_npc("society", "اتجه إلى كاتب السجل في الفناء الشرقي")


func _begin_society() -> void:
	_checkpoint("society_task")
	_reset_task()
	_enable_many(["society_official", "society_merchant", "society_common", "society_enslaved", "society_women_rights"])
	set_objective(CHAPTER_TITLE, "اجمع سجلات المجتمع ووثيقة حقوق المرأة  •  ٠ / ٥")


func _handle_society(id: String) -> void:
	if id == "society_display":
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("society", "acknowledge")
		_mark_progress()
		_award_emblem("Society", "شعار المجتمع")
		_checkpoint("beliefs_npc")
		_set_active_npc("beliefs", "اتجه إلى دليل المعبد")
		return
	if _items.has(id):
		return
	_inspect_at_spot(id, "tablet")
	_items[id] = true
	_set_spot_enabled(id, false)
	_mark_progress()
	_feedback("فحصت الوثيقة وأضفتها إلى سجل المجتمع", "correct")
	var count := _items.size()
	set_objective(CHAPTER_TITLE, "اجمع سجلات المجتمع  •  %d / ٥" % count)
	if count == 5:
		_set_spot_enabled("society_display", true)
		set_objective(CHAPTER_TITLE, "أعد بناء سجل المجتمع في الفناء")


func _begin_beliefs() -> void:
	_checkpoint("beliefs_task")
	_reset_task()
	_enable_many(["belief_zeus", "belief_apollo", "belief_athena", "belief_zeus_plinth", "belief_apollo_plinth", "belief_athena_plinth"])
	set_objective(CHAPTER_TITLE, "أعد رموز زيوس وأبولو وأثينا إلى مواضعها  •  ٠ / ٣")


func _handle_beliefs(id: String) -> void:
	var expected := {"belief_zeus_plinth":"belief_zeus", "belief_apollo_plinth":"belief_apollo", "belief_athena_plinth":"belief_athena"}
	if id in ["belief_zeus", "belief_apollo", "belief_athena"]:
		if not _pick_up_from_spot(id, "symbol"):
			return
		_feedback("وجدت %s" % _belief_name(id))
	elif expected.has(id):
		if _carried_item != expected[id]:
			_feedback("الرمز لا يطابق هذا الموضع", "wrong")
			return
		_place_carried_at(id, Vector3(0, 1.05, 0), "symbol")
		_items[id] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("beliefs", "acknowledge")
		_mark_progress()
		var count := _items.size()
		set_objective(CHAPTER_TITLE, "أعد رموز المعبد  •  %d / ٣" % count)
		if count == 3:
			_award_emblem("Beliefs", "شعار المعتقدات")
			_checkpoint("theatre_npc")
			_set_active_npc("theatre", "اتجه إلى مشرف المسرح")


func _begin_theatre() -> void:
	_checkpoint("theatre_task")
	_reset_task()
	_enable_many(["theatre_actor_a", "theatre_actor_b", "theatre_chorus", "theatre_orchestra"])
	set_objective(CHAPTER_TITLE, "اعثر على الممثلين، وانقل قناع الجوقة، ثم جهّز الأوركسترا  •  ٠ / ٥")


func _handle_theatre(id: String) -> void:
	if _items.has(id):
		return
	if id in ["theatre_actor_a", "theatre_actor_b"]:
		_items[id] = true
		_set_spot_enabled(id, false)
		var actor_key := "ActorTragedy" if id.ends_with("a") else "ActorComedy"
		var actor := $Characters.get_node_or_null(actor_key)
		if actor != null and actor.has_method("play_mission_reaction"):
			actor.call("play_mission_reaction", player, "greet")
		_inspect_at_spot(id, "mask")
	elif id == "theatre_chorus":
		if not _pick_up_from_spot(id, "mask"):
			return
		_set_spot_enabled("theatre_stage", true)
		set_objective(CHAPTER_TITLE, "احمل قناع الجوقة وضعه على خشبة المسرح")
		return
	elif id == "theatre_stage":
		if _carried_item != "theatre_chorus":
			_feedback("أحضر قناع الجوقة إلى الخشبة أولاً.", "wrong")
			return
		_place_carried_at(id, Vector3(0, 1.15, 0), "mask")
		_items["theatre_chorus"] = true
		_items[id] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
	elif id == "theatre_orchestra":
		_items[id] = true
		_set_spot_enabled(id, false)
		_inspect_at_spot(id, "prop")
		_play_world_action(id)
	_mark_progress()
	_feedback("أصبح جزء جديد من العرض جاهزاً", "correct")
	var count := _items.size()
	set_objective(CHAPTER_TITLE, "جهّز الممثلين وعناصر المسرح  •  %d / ٥" % count)
	if count == 5:
		_run_theatre_rehearsal()


func _run_theatre_rehearsal() -> void:
	_activity_running = true
	var tragedy := Lesson2Content.entry("l2_stage_tragedy_001")
	var comedy := Lesson2Content.entry("l2_stage_comedy_001")
	var summary := Lesson2Content.entry("l2_theatre_004")
	var tragedy_actor := $Characters/ActorTragedy as NPCController
	var comedy_actor := $Characters/ActorComedy as NPCController
	tragedy_actor.begin_conversation(player)
	comedy_actor.begin_conversation(player)
	tragedy_actor.set_conversation_speaking(true, 0, "talk_emphasis")
	comedy_actor.set_conversation_speaking(true, 1, "talk_response")
	cutscene.play_shots("l2_theatre_rehearsal", [
		_make_shot(tragedy, Vector3(-20, 4, -48), tragedy_actor.global_position + Vector3.UP * 1.2),
		_make_shot(comedy, Vector3(-8, 3.4, -49), comedy_actor.global_position + Vector3.UP * 1.2),
		_make_shot(summary, Vector3(-14, 5, -43), Vector3(-14, 0.8, -53)),
	], true)
	await cutscene.cutscene_finished
	tragedy_actor.end_conversation()
	comedy_actor.end_conversation()
	player.set_controls_enabled(false)
	activity_ui.show_choice("نهاية المشهدين", "المشهد الأول انتهى بحزن، والثاني انتهى بسعادة. كيف نصنفهما؟", [{"id":"correct", "label":"الأول تراجيديا، والثاني كوميديا"}, {"id":"wrong", "label":"الأول كوميديا، والثاني تراجيديا"}])
	while true:
		var choice: String = await activity_ui.choice_made
		if choice == "correct":
			break
		activity_ui.show_feedback("راقب طبيعة النهاية في كل مشهد وحاول مجدداً.", false)
	activity_ui.hide_choice()
	player.set_controls_enabled(true)
	_activity_running = false
	_checkpoint("ideas_npc")
	_set_active_npc("ideas", "اتجه إلى دليل المكتبة")


func _begin_ideas() -> void:
	_checkpoint("ideas_task")
	_reset_task()
	_enable_many(["ideas_plato", "ideas_aristotle", "ideas_herodotus", "ideas_plato_desk", "ideas_aristotle_desk", "ideas_herodotus_desk"])
	set_objective(CHAPTER_TITLE, "انقل ألواح أفلاطون وأرسطو وهيرودوتس إلى مكاتبها")
	_play_reveal("l2_philosophers_reveal", Vector3(25, 5.8, -42), Vector3(15, 1.1, -48), 2.4)


func _handle_ideas(id: String) -> void:
	var expected := {"ideas_plato_desk":"ideas_plato", "ideas_aristotle_desk":"ideas_aristotle", "ideas_herodotus_desk":"ideas_herodotus"}
	if id in ["ideas_plato", "ideas_aristotle", "ideas_herodotus"]:
		if not _pick_up_from_spot(id, "tablet"):
			return
		_feedback("حملت %s" % _thinker_name(id))
	elif expected.has(id):
		if _carried_item != expected[id]:
			_feedback("هذا العمل لا يطابق صاحب اللوح", "wrong")
			return
		_place_carried_at(id, Vector3(0, 1.0, 0), "tablet")
		_items[id] = true
		_set_spot_enabled(id, false)
		_play_world_action(id)
		_react_npc("ideas", "acknowledge")
		_mark_progress()
		var count := _items.size()
		set_objective(CHAPTER_TITLE, "رتّب ألواح المفكرين  •  %d / ٣" % count)
		if count == 3:
			_checkpoint("architecture_npc")
			_set_active_npc("architecture", "اتجه إلى البنّاء عند منصة المدينة")


func _begin_architecture() -> void:
	_checkpoint("architecture_task")
	_reset_task()
	_enable_many(["arch_wall", "arch_agora", "arch_temple", "arch_theatre"])
	set_objective(CHAPTER_TITLE, "احمل قطع السور والساحة والمعبد والمسرح، وثبّتها في نموذج المدينة  •  ٠ / ٤")


func _handle_architecture(id: String) -> void:
	if id in ["arch_wall", "arch_agora", "arch_temple", "arch_theatre"]:
		if not _pick_up_from_spot(id, "model_piece"):
			return
		_set_spot_enabled("arch_model", true)
		set_objective(CHAPTER_TITLE, "ثبّت القطعة التي تحملها في نموذج المدينة")
	elif id == "arch_model":
		if not _carried_item.begins_with("arch_") or _carried_item == "arch_model":
			_feedback("اختر قطعة من معرض البناء أولاً.", "wrong")
			return
		var piece_id := _carried_item
		var slot := _items.size()
		var offsets := [Vector3(-1.2, 0.75, -0.3), Vector3(-0.35, 0.8, 0.35), Vector3(0.45, 0.85, -0.25), Vector3(1.2, 0.78, 0.35)]
		_place_carried_at(id, offsets[mini(slot, offsets.size() - 1)], "model_piece")
		_items[piece_id] = true
		_set_spot_enabled(id, false)
		_mark_progress()
		var count := _items.size()
		if count == 4:
			_play_world_action(id)
			_set_spot_enabled("arch_sculpture", true)
			_react_npc("architecture", "acknowledge")
			_play_reveal("l2_city_model_reveal", Vector3(7, 5.4, -57), Vector3(0, 1, -59), 2.5)
			set_objective(CHAPTER_TITLE, "افحص الرخام والبرونز في معرض النحت")
		else:
			set_objective(CHAPTER_TITLE, "أكمل نموذج المدينة  •  %d / ٤" % count)
	elif id == "arch_sculpture":
		_set_spot_enabled(id, false)
		_inspect_at_spot(id, "sculpture")
		_mark_progress()
		_award_emblem("Culture", "شعار الثقافة والفنون")
		_checkpoint("sport_npc")
		_set_active_npc("sport", "اتجه إلى المدرب في ساحة الرياضة")


func _begin_sport() -> void:
	_checkpoint("sport_task")
	_reset_task()
	_set_spot_enabled("sport_start", true)
	set_objective(CHAPTER_TITLE, "ابدأ سباق الجري القصير")


func _show_sport_start() -> void:
	_activity_running = true
	player.set_controls_enabled(false)
	activity_ui.show_choice("سباق الجري", "اعبر العلامات الثلاث. لن تفشل المهمة إن احتجت إلى الإكمال المبسّط.", [{"id":"run", "label":"ابدأ السباق"}, {"id":"skip", "label":"إكمال مبسّط ومتاح"}])
	var choice: String = await activity_ui.choice_made
	activity_ui.hide_choice()
	player.set_controls_enabled(true)
	_activity_running = false
	_set_spot_enabled("sport_start", false)
	if choice == "skip":
		_complete_sport()
	else:
		player.set_controls_enabled(false)
		_feedback("استعد... ثم انطلق عند الإشارة")
		AudioDirector.play_sfx("lesson2_race_ready")
		await get_tree().create_timer(0.8).timeout
		player.set_controls_enabled(true)
		_feedback("انطلق!")
		AudioDirector.play_sfx("lesson2_race_start")
		_sport_started_msec = Time.get_ticks_msec()
		_sport_checkpoint = 1
		_set_spot_enabled("sport_cp_1", true)
		set_objective(CHAPTER_TITLE, "السباق: اعبر العلامة ١ / ٣")


func _complete_sport() -> void:
	for id in ["sport_cp_1", "sport_cp_2", "sport_cp_3"]:
		_set_spot_enabled(id, false)
	_award_emblem("Sport", "")
	AudioDirector.play_sfx("lesson2_race_finish")
	if _sport_started_msec > 0:
		var elapsed := float(Time.get_ticks_msec() - _sport_started_msec) / 1000.0
		hud.show_action_feedback("أكملت المسار في %.1f ثانية وحصلت على شعار الرياضة" % elapsed, "correct", 4.0)
	else:
		hud.show_action_feedback("اكتمل التدريب المبسّط — حصلت على شعار الرياضة", "correct", 4.0)
	_sport_started_msec = 0
	_checkpoint("jordan_npc")
	_set_active_npc("jordan", "اتجه إلى دليل الآثار في جناح الأردن")


func _begin_jordan() -> void:
	_checkpoint("jordan_task")
	_reset_task()
	if _spots.has("jordan_marker_tray"):
		_set_spot_enabled("jordan_marker_tray", true)
	else:
		# Compatibility fallback for old saved/editor copies of the environment.
		_enable_many(JORDAN_ORDER)
	set_objective(CHAPTER_TITLE, "خذ علامة من صندوق الآثار، ثم ضعها على موضعها في سجل الأردن  •  ٠ / ٥")
	_play_reveal("l2_jordan_map_reveal", Vector3(27, 6.2, -63), Vector3(16, 1, -66), 2.6)


func _handle_jordan(id: String) -> void:
	if id == "jordan_marker_tray":
		var next_id := _next_jordan_id()
		if next_id.is_empty():
			_set_spot_enabled(id, false)
			return
		if not _pick_up_virtual_item(next_id, _spots[id].global_transform, "map_marker"):
			return
		_set_spot_enabled(id, false)
		_set_spot_enabled(next_id, true)
		_play_world_action(id)
		set_objective(CHAPTER_TITLE, "احمل علامة %s إلى موضعها المضيء على السجل" % _jordan_place_name(next_id))
		return
	if id == "jordan_qasr":
		_set_spot_enabled(id, false)
		_award_emblem("Heritage", "شعار التراث")
		_checkpoint("final_board")
		_begin_final_board()
		return
	if not JORDAN_ORDER.has(id):
		return
	if _spots.has("jordan_marker_tray") and _carried_item != id:
		_feedback("خذ علامة %s من صندوق الآثار أولاً." % _jordan_place_name(id), "wrong")
		return
	if _carried_item == id:
		_place_carried_at(id, Vector3(0, 0.25, 0), "map_marker")
	elif not _spots.has("jordan_marker_tray"):
		_inspect_at_spot(id, "map_marker")
	_items[id] = true
	_set_spot_enabled(id, false)
	_reveal_jordan_marker(id)
	_play_world_action("jordan_map")
	_mark_progress()
	var count := _items.size()
	set_objective(CHAPTER_TITLE, "ضع علامات المدن على السجل  •  %d / ٥" % count)
	if count == 5:
		_set_spot_enabled("jordan_qasr", true)
		set_objective(CHAPTER_TITLE, "اختم السجل عند قصر العبد في عراق الأمير")
	else:
		_set_spot_enabled("jordan_marker_tray", true)


func _reveal_jordan_marker(id: String) -> void:
	var suffixes := {
		"jordan_amman":"Amman", "jordan_pella":"Pella", "jordan_gadara":"Gadara",
		"jordan_gerasa":"Gerasa", "jordan_heshbon":"Heshbon",
	}
	var facts := {
		"jordan_amman":"ربّة عمون / عمّان، ثم ارتبطت باسم فيلادلفيا.",
		"jordan_pella":"طبقة فحل عُرفت تاريخياً باسم بيلا.",
		"jordan_gadara":"أم قيس عُرفت تاريخياً باسم جدارا.",
		"jordan_gerasa":"جرش عُرفت تاريخياً باسم جراسا.",
		"jordan_heshbon":"حسبان عُرفت تاريخياً باسم حشبون.",
	}
	if not suffixes.has(id):
		return
	var base_name := "JordanMap" + str(suffixes[id])
	var marker := $Lesson2CityEnvironment.get_node_or_null(base_name) as MeshInstance3D
	var label := $Lesson2CityEnvironment.get_node_or_null(base_name + "Label") as Label3D
	if marker != null:
		marker.visible = true
	if label != null:
		label.visible = true
	_feedback(str(facts.get(id, "أضأت موقعاً على سجل الأردن")), "correct")


func _begin_final_board() -> void:
	_checkpoint("final_board")
	for id in ["Politics", "Economy", "Society", "Beliefs", "Culture", "Sport", "Heritage"]:
		_emblems[id] = true
	_hide_board_emblems()
	_set_spot_enabled("final_board", true)
	set_objective(CHAPTER_TITLE, "عد إلى الساحة وضع شعارات الرحلة على اللوحة النهائية")


func _run_final_sequence() -> void:
	_set_spot_enabled("final_board", false)
	_activity_running = true
	var ending := Lesson2Content.entries("l2_ending_")
	cutscene.shot_started.connect(_on_final_shot_started)
	cutscene.play_shots("l2_complete_city", [
		_make_visual_shot(Vector3(0, 9, 24), Vector3(0, 0, 12), 1.35),
		_make_visual_shot(Vector3(-29, 7, 5), Vector3(-16, 0, -3), 1.35),
		_make_visual_shot(Vector3(28, 7, -20), Vector3(15, 0, -26), 1.35),
		_make_visual_shot(Vector3(11, 8, -29), Vector3(0, 1, -39), 1.35),
		_make_visual_shot(Vector3(-25, 7, -47), Vector3(-14, 0, -52), 1.35),
		_make_visual_shot(Vector3(-25, 6, -67), Vector3(-15, 0, -70), 1.35),
		_make_visual_shot(Vector3(25, 8, -62), Vector3(16, 1, -69), 1.35),
		_make_shot(ending[0], Vector3(0, 11, 2), Vector3(0, 0, -25)),
		_make_shot(ending[1], Vector3(0, 13, -18), Vector3(0, 0, -30)),
	], true)
	await cutscene.cutscene_finished
	if cutscene.shot_started.is_connected(_on_final_shot_started):
		cutscene.shot_started.disconnect(_on_final_shot_started)
	_activity_running = false
	_checkpoint("complete")
	Objectives.clear_objective()
	player.set_controls_enabled(false)
	activity_ui.show_ending()


func _collect_once(id: String, message: String) -> void:
	if _items.has(id):
		return
	_items[id] = true
	_set_spot_enabled(id, false)
	_feedback(message)


func _setup_physical_interactions() -> void:
	_held_system = player.get_node_or_null("HeldObjectSystem")
	if _held_system == null:
		_held_system = player.get_node_or_null("Lesson2HeldObjectSystem")
	if _held_system == null:
		for script_path in [
			"res://scripts/interaction/lesson2_held_object_system.gd",
			"res://scripts/interaction/held_object_system.gd",
		]:
			if not ResourceLoader.exists(script_path):
				continue
			var held_script := load(script_path) as Script
			if held_script != null:
				_held_system = held_script.new() as Node
				_held_system.name = "HeldObjectSystem"
				player.add_child(_held_system)
				break
	if _held_system != null:
		if _held_system.has_method("configure"):
			_held_system.call("configure", player)
		elif _held_system.has_method("setup"):
			_held_system.call("setup", player)
		elif _held_system.has_method("initialize"):
			_held_system.call("initialize", player)
	for spot_variant in _spots.values():
		var spot := spot_variant as Lesson2InteractionSpot
		if spot.has_method("set_guidance_level"):
			spot.call("set_guidance_level", 0)


func _pick_up_from_spot(id: String, profile: String) -> bool:
	if not _carried_item.is_empty():
		_feedback("ضع ما تحمله أولاً؛ سيبقى العنصر معك حتى تضعه بأمان.", "wrong")
		return false
	if not _spots.has(id):
		return false
	_carried_item = id
	_set_spot_enabled(id, false)
	_set_world_prop_state(id, "hidden")
	var source_transform: Transform3D = (_spots[id] as Node3D).global_transform
	_start_held_pickup(id, source_transform, profile)
	_mark_progress()
	return true


func _pick_up_virtual_item(id: String, source_transform: Transform3D, profile: String) -> bool:
	if not _carried_item.is_empty():
		_feedback("ضع ما تحمله أولاً.", "wrong")
		return false
	_carried_item = id
	_start_held_pickup(id, source_transform, profile)
	_mark_progress()
	return true


func _start_held_pickup(id: String, source_transform: Transform3D, profile: String) -> void:
	var animated_by_system := false
	if _held_system != null:
		if _held_system.has_method("pickup_item"):
			animated_by_system = bool(_held_system.call("pickup_item", id, source_transform, _item_visual_spec(id, profile)))
		elif _held_system.has_method("pick_up_item"):
			animated_by_system = bool(_held_system.call("pick_up_item", id, source_transform, _item_visual_spec(id, profile)))
	if not animated_by_system and player.has_method("play_interaction_pose"):
		player.call("play_interaction_pose", "pickup", 0.48)
	_refresh_target_preview()
	AudioDirector.play_sfx("lesson2_pickup")


func _place_carried_at(target_id: String, local_offset: Vector3, profile: String) -> void:
	if _carried_item.is_empty() or not _spots.has(target_id):
		return
	var target := _spots[target_id] as Node3D
	var target_transform := Transform3D(target.global_basis, target.global_position + local_offset)
	var animated_by_system := false
	if _held_system != null:
		var placement_spec := _item_visual_spec(_carried_item, profile)
		placement_spec["target_id"] = target_id
		placement_spec["expected_item_id"] = _carried_item
		placement_spec["keep_visual"] = true
		if _held_system.has_method("place_item"):
			animated_by_system = bool(_held_system.call("place_item", target_transform, placement_spec))
		elif _held_system.has_method("place_held_item"):
			animated_by_system = bool(_held_system.call("place_held_item", target_transform, placement_spec))
	if not animated_by_system and player.has_method("play_interaction_pose"):
		player.call("play_interaction_pose", "place", 0.52)
	AudioDirector.play_sfx("lesson2_place")
	_carried_item = ""
	_refresh_target_preview()


func _inspect_at_spot(id: String, profile: String) -> void:
	if not _spots.has(id):
		return
	var spot_transform: Transform3D = (_spots[id] as Node3D).global_transform
	if _held_system != null and _held_system.has_method("inspect_item"):
		_held_system.call("inspect_item", id, spot_transform, _item_visual_spec(id, profile))
	if player.has_method("play_interaction_pose"):
		player.call("play_interaction_pose", "inspect", 0.72)
	AudioDirector.play_sfx("lesson2_inspect")


func _item_visual_spec(id: String, profile: String) -> Dictionary:
	var color := Color(0.60, 0.38, 0.17)
	match profile:
		"tablet": color = Color(0.64, 0.43, 0.19)
		"harvest":
			color = Color(0.72, 0.58, 0.17) if id.contains("grain") else Color(0.28, 0.42, 0.11) if id.contains("olive") else Color(0.40, 0.18, 0.42)
		"material": color = Color(0.38, 0.25, 0.13) if id.contains("wood") else Color(0.38, 0.41, 0.44) if id.contains("metal") else Color(0.66, 0.37, 0.20)
		"crate": color = Color(0.42, 0.25, 0.12)
		"symbol": color = Color(0.64, 0.39, 0.12)
		"mask": color = Color(0.88, 0.78, 0.55)
		"model_piece": color = Color(0.78, 0.73, 0.61)
		"map_marker": color = Color(0.18, 0.65, 0.78)
		"basket": color = Color(0.52, 0.35, 0.16)
	var hold_pose := "one_hand"
	match profile:
		"tablet": hold_pose = "tablet"
		"crate": hold_pose = "crate"
		"basket", "harvest": hold_pose = "basket"
		"sculpture": hold_pose = "large"
	return {
		"profile": profile,
		"shape": {
			"tablet":"tablet", "harvest":"basket", "material":"bundle", "crate":"crate",
			"symbol":"marker", "mask":"mask", "model_piece":"model", "map_marker":"marker",
			"basket":"basket", "sculpture":"model", "prop":"tool",
		}.get(profile, "bundle"),
		"color": color,
		"accent_color": color.lightened(0.18),
		"large": profile in ["crate", "basket"],
		"hold_pose": hold_pose,
	}


func _refresh_target_preview() -> void:
	if _held_system == null:
		return
	if _held_system.has_method("clear_target_preview"):
		_held_system.call("clear_target_preview")
	if _carried_item.is_empty() or not _held_system.has_method("show_target_preview"):
		return
	var target_id := _target_for_item(_carried_item)
	if target_id.is_empty() or not _spots.has(target_id):
		return
	_held_system.call("show_target_preview", _spots[target_id], _carried_item, {
		"shape":"marker", "color":Color(0.25, 0.78, 0.88, 0.42),
	})


func _target_for_item(item_id: String) -> String:
	if item_id.begins_with("politics_"):
		return "politics_display"
	return {
		"farm_grain":"farm_mill", "farm_olives":"farm_press", "farm_grapes":"farm_market_delivery",
		"farm_finished_goods":"farm_market_delivery",
		"industry_wood":"industry_ship", "industry_metal":"industry_tools", "industry_clay":"industry_pottery",
		"trade_local_crate":"trade_market_drop", "trade_external_crate":"trade_harbour_drop",
		"belief_zeus":"belief_zeus_plinth", "belief_apollo":"belief_apollo_plinth", "belief_athena":"belief_athena_plinth",
		"theatre_chorus":"theatre_stage",
		"ideas_plato":"ideas_plato_desk", "ideas_aristotle":"ideas_aristotle_desk", "ideas_herodotus":"ideas_herodotus_desk",
		"arch_wall":"arch_model", "arch_agora":"arch_model", "arch_temple":"arch_model", "arch_theatre":"arch_model",
		"jordan_amman":"jordan_amman", "jordan_pella":"jordan_pella", "jordan_gadara":"jordan_gadara",
		"jordan_gerasa":"jordan_gerasa", "jordan_heshbon":"jordan_heshbon",
	}.get(item_id, "")


func _play_world_action(action_id: String) -> void:
	var environment := $Lesson2CityEnvironment
	if environment.has_method("play_mission_animation"):
		environment.call("play_mission_animation", action_id)


func _set_world_prop_state(action_id: String, state: String) -> void:
	var environment := $Lesson2CityEnvironment
	if environment.has_method("set_mission_prop_state"):
		environment.call("set_mission_prop_state", action_id, state)


func _react_npc(key: String, reaction: String) -> void:
	if not _npcs.has(key):
		return
	var npc := _npcs[key] as Node3D
	if npc.has_method("play_mission_reaction"):
		npc.call("play_mission_reaction", player, reaction)
	elif npc.has_method("play_receive_reaction"):
		npc.call("play_receive_reaction", player)


func _play_reveal(sequence_name: String, camera_position: Vector3, target: Vector3, duration: float) -> void:
	if _reveal_running or cutscene == null or cutscene.is_active():
		return
	_run_reveal(sequence_name, camera_position, target, duration)


func _run_reveal(sequence_name: String, camera_position: Vector3, target: Vector3, duration: float) -> void:
	if _reveal_running or cutscene.is_active():
		return
	_reveal_running = true
	cutscene.play_shots(sequence_name, [_make_visual_shot(camera_position, target, duration)], true)
	await cutscene.cutscene_finished
	_reveal_running = false


func _mark_progress() -> void:
	_last_progress_msec = Time.get_ticks_msec()
	_guidance_level = 0
	for spot_variant in _spots.values():
		var spot := spot_variant as Lesson2InteractionSpot
		if spot.has_method("set_guidance_level"):
			spot.call("set_guidance_level", 0)
	_refresh_journey_guidance(true)


func _next_jordan_id() -> String:
	for id in JORDAN_ORDER:
		if not _items.has(id):
			return id
	return ""


func _jordan_place_name(id: String) -> String:
	return {
		"jordan_amman":"عمّان", "jordan_pella":"بيلا", "jordan_gadara":"جدارا",
		"jordan_gerasa":"جراسا", "jordan_heshbon":"حشبون",
	}.get(id, "المدينة")


func _reset_task() -> void:
	_items.clear()
	_carried_item = ""
	if _held_system != null:
		if _held_system.has_method("reset_held_item"):
			_held_system.call("reset_held_item")
		elif _held_system.has_method("reset"):
			_held_system.call("reset")
	_refresh_target_preview()
	_disable_all_spots()
	_mark_progress()


func _enable_many(ids) -> void:
	for id in ids:
		_set_spot_enabled(str(id), true)


func _disable_all_spots() -> void:
	for spot_variant in _spots.values():
		(spot_variant as Lesson2InteractionSpot).set_interaction_enabled(false)
	_nearby_spots.clear()


func _count_prefix(prefix: String) -> int:
	var count := 0
	for key in _items.keys():
		if str(key).begins_with(prefix):
			count += 1
	return count


func _award_emblem(id: String, label: String) -> void:
	_emblems[id] = true
	if not label.is_empty():
		if hud.has_method("show_action_feedback"):
			hud.call("show_action_feedback", "حصلت على %s" % label, "checkpoint", 3.0)
		else:
			hud.show_mission_complete("حصلت على %s" % label, 3.0)


func _show_all_emblems() -> void:
	for id in ["Politics", "Economy", "Society", "Beliefs", "Culture", "Sport", "Heritage"]:
		_award_emblem(id, "")
		var node := $Lesson2CityEnvironment.get_node_or_null("Emblem" + id) as MeshInstance3D
		if node != null:
			node.visible = true


func _hide_board_emblems() -> void:
	for id in ["Politics", "Economy", "Society", "Beliefs", "Culture", "Sport", "Heritage"]:
		var node := $Lesson2CityEnvironment.get_node_or_null("Emblem" + id) as MeshInstance3D
		if node != null:
			node.visible = false


func _on_final_shot_started(sequence_name: String, shot_index: int, _shot: Dictionary) -> void:
	if sequence_name != "l2_complete_city":
		return
	var ids := ["Politics", "Economy", "Society", "Beliefs", "Culture", "Sport", "Heritage"]
	if shot_index >= ids.size():
		return
	var node := $Lesson2CityEnvironment.get_node_or_null("Emblem" + ids[shot_index]) as MeshInstance3D
	if node != null:
		node.visible = true


func _restore_emblems_for_stage(stage_name: String) -> void:
	var order := ["intro", "politics", "farm", "industry", "trade", "society", "beliefs", "theatre", "ideas", "architecture", "sport", "jordan", "final", "complete"]
	var stage_root := stage_name.trim_suffix("_npc").trim_suffix("_task").trim_suffix("_board")
	var index := order.find(stage_root)
	if index > order.find("politics"):
		_award_emblem("Politics", "")
	if index > order.find("trade"):
		_award_emblem("Economy", "")
	if index > order.find("society"):
		_award_emblem("Society", "")
	if index > order.find("beliefs"):
		_award_emblem("Beliefs", "")
	if index > order.find("architecture"):
		_award_emblem("Culture", "")
	if index > order.find("sport"):
		_award_emblem("Sport", "")
	if index > order.find("jordan"):
		_award_emblem("Heritage", "")


func _checkpoint(stage_name: String) -> void:
	var stage_changed := _stage != stage_name
	_stage = stage_name
	GameFlow.story_flags["lesson2_stage"] = stage_name
	GameFlow.save_checkpoint("lesson2", LESSON2_SCENE, {"lesson2_stage": stage_name})
	if stage_changed and not stage_name.ends_with("_task") and stage_name != "intro" and hud != null:
		if hud.has_method("show_action_feedback"):
			hud.call("show_action_feedback", "تم حفظ نقطة التقدم", "checkpoint", 1.35)
	_refresh_journey_guidance(true)


func _set_active_npc(key: String, objective_text: String) -> void:
	for npc_key in _npcs.keys():
		set_npc_available(_npcs[npc_key], npc_key == key, npc_key == key)
	set_objective(CHAPTER_TITLE, objective_text)
	_refresh_journey_guidance(true)


func _set_spot_enabled(id: String, enabled: bool) -> void:
	if _spots.has(id):
		var spot := _spots[id] as Lesson2InteractionSpot
		spot.set_interaction_enabled(enabled)
		if spot.has_method("set_guidance_level"):
			spot.call("set_guidance_level", _guidance_level if enabled else 0)
	if not enabled:
		for spot in _nearby_spots.duplicate():
			if spot.spot_id == id:
				_nearby_spots.erase(spot)
	_refresh_interaction_prompt()
	_refresh_journey_guidance(true)


func _on_spot_proximity_changed(spot: Lesson2InteractionSpot, is_near: bool) -> void:
	if is_near:
		if not _nearby_spots.has(spot):
			_nearby_spots.append(spot)
		if spot.spot_id == "sport_cp_%d" % _sport_checkpoint and _sport_checkpoint > 0:
			_set_spot_enabled(spot.spot_id, false)
			_sport_checkpoint += 1
			if _sport_checkpoint > 3:
				_sport_checkpoint = 0
				_complete_sport()
			else:
				_set_spot_enabled("sport_cp_%d" % _sport_checkpoint, true)
				set_objective(CHAPTER_TITLE, "السباق: اعبر العلامة %d / ٣" % _sport_checkpoint)
	else:
		_nearby_spots.erase(spot)
	_refresh_interaction_prompt()


func _nearest_spot() -> Lesson2InteractionSpot:
	var nearest: Lesson2InteractionSpot
	var distance := INF
	for spot in _nearby_spots:
		if not is_instance_valid(spot) or not spot.interaction_enabled:
			continue
		var candidate := player.global_position.distance_squared_to(spot.global_position)
		if candidate < distance:
			distance = candidate
			nearest = spot
	return nearest


func _refresh_interaction_prompt() -> void:
	if hud == null or activity_ui == null:
		return
	hud.show_interaction_prompt((not _nearby_spots.is_empty() or _get_nearest_available_npc() != null) and not Dialogue.is_active() and not cutscene.is_active() and not activity_ui.is_modal_open())


func _setup_journey_guidance() -> void:
	for spot_variant in _spots.values():
		var spot := spot_variant as Lesson2InteractionSpot
		if spot.has_method("set_primary_guidance"):
			spot.call("set_primary_guidance", false)
	_refresh_journey_guidance(true)


func _refresh_journey_guidance(force: bool = false) -> void:
	if hud == null:
		return
	if not force and _journey_refresh_time > 0.0:
		return
	_journey_refresh_time = 0.22
	var blocked := Dialogue.is_active() or _activity_running or activity_ui.is_modal_open()
	if cutscene != null:
		blocked = blocked or cutscene.is_active()
	if blocked:
		_set_primary_guidance_spot(null)
		return
	var journey_index := _journey_index_for_stage(_stage)
	var target_info := _journey_target()
	var target_key := str(target_info.get("key", ""))
	var target_changed := target_key != _journey_target_key
	var target_spot := target_info.get("target") as Lesson2InteractionSpot
	_set_primary_guidance_spot(target_spot)
	if target_key.is_empty():
		_journey_target_key = ""
	else:
		_journey_target_key = target_key
	var total := 13
	var location := _journey_location_label(journey_index)
	var instruction := (
		"اكتملت الرحلة التعليمية"
		if journey_index >= total
		else "توجّه إلى علامة ! عند %s" % str(target_info.get("label", location))
	)
	if force or target_changed or journey_index != _journey_ui_index:
		hud.call("set_journey_progress", location, instruction, mini(journey_index + 1, total), total)
		_journey_ui_index = journey_index


func _set_primary_guidance_spot(next_spot: Lesson2InteractionSpot) -> void:
	if _primary_guidance_spot == next_spot:
		return
	if is_instance_valid(_primary_guidance_spot) and _primary_guidance_spot.has_method("set_primary_guidance"):
		_primary_guidance_spot.call("set_primary_guidance", false)
	_primary_guidance_spot = next_spot
	if is_instance_valid(_primary_guidance_spot) and _primary_guidance_spot.has_method("set_primary_guidance"):
		_primary_guidance_spot.call("set_primary_guidance", true)


func _journey_index_for_stage(stage_name: String) -> int:
	if stage_name == "complete":
		return 13
	var root := stage_name.trim_suffix("_npc").trim_suffix("_task").trim_suffix("_board")
	return maxi(["intro", "politics", "farm", "industry", "trade", "society", "beliefs", "theatre", "ideas", "architecture", "sport", "jordan", "final"].find(root), 0)


func _journey_location_label(index: int) -> String:
	var labels := ["بوابة المدينة", "الساحة المدنية", "الحقول", "حي الورش", "السوق والمرفأ", "دار السجل", "المعبد", "المسرح", "المكتبة", "منصة المدينة", "ساحة الألعاب", "سجل الأردن", "لوحة الرحلة"]
	return labels[clampi(index, 0, labels.size() - 1)]


func _journey_target() -> Dictionary:
	if _stage == "complete":
		return {}
	if _stage == "intro":
		return {"key":"npc_guide", "target":_npcs["guide"], "label":"دليل المدينة"}
	if _stage.ends_with("_npc"):
		var npc_key := _stage.trim_suffix("_npc")
		if _npcs.has(npc_key):
			var npc_labels := {
				"politics":"دليل الساحة", "farm":"المزارع", "industry":"الحرفي",
				"trade":"التاجر", "society":"كاتب السجل", "beliefs":"دليل المعبد",
				"theatre":"مشرف المسرح", "ideas":"دليل المكتبة", "architecture":"البنّاء",
				"sport":"المدرب", "jordan":"دليل الآثار",
			}
			return {"key":"npc_" + npc_key, "target":_npcs[npc_key], "label":str(npc_labels.get(npc_key, "الشخصية التالية"))}
	if _stage in ["final_board", "complete"] and _spots.has("final_board"):
		return {"key":"spot_final_board", "target":_spots["final_board"], "label":"لوحة الرحلة"}
	if not _carried_item.is_empty():
		var carried_target := _target_for_item(_carried_item)
		if _spots.has(carried_target):
			var carried_spot := _spots[carried_target] as Lesson2InteractionSpot
			return {"key":"spot_" + carried_target, "target":carried_spot, "label":carried_spot.label_ar}
	if _stage == "sport_task" and _sport_checkpoint > 0:
		var checkpoint_id := "sport_cp_%d" % _sport_checkpoint
		if _spots.has(checkpoint_id):
			return {"key":"spot_" + checkpoint_id, "target":_spots[checkpoint_id], "label":"علامة السباق %d" % _sport_checkpoint}
	var placement_only := [
		"politics_display", "farm_mill", "farm_press", "farm_market_delivery",
		"industry_ship", "industry_tools", "industry_pottery", "trade_market_drop", "trade_harbour_drop",
		"belief_zeus_plinth", "belief_apollo_plinth", "belief_athena_plinth", "theatre_stage",
		"ideas_plato_desk", "ideas_aristotle_desk", "ideas_herodotus_desk", "arch_model",
		"jordan_amman", "jordan_pella", "jordan_gadara", "jordan_gerasa", "jordan_heshbon",
	]
	var nearest: Lesson2InteractionSpot
	var nearest_distance := INF
	for spot_variant in _spots.values():
		var spot := spot_variant as Lesson2InteractionSpot
		if not spot.interaction_enabled or placement_only.has(spot.spot_id):
			continue
		var distance := player.global_position.distance_squared_to(spot.global_position)
		if distance < nearest_distance:
			nearest = spot
			nearest_distance = distance
	if nearest != null:
		return {"key":"spot_" + nearest.spot_id, "target":nearest, "label":nearest.label_ar}
	return {}


func _feedback(text: String, feedback_type: String = "objective") -> void:
	if hud.has_method("show_action_feedback"):
		hud.call("show_action_feedback", text, feedback_type, 2.2)
	else:
		hud.show_mission_complete(text, 2.2)


func _material_name(id: String) -> String:
	return {"industry_wood":"الخشب", "industry_metal":"المعدن", "industry_clay":"الطين"}.get(id, "مادة")


func _belief_name(id: String) -> String:
	return {"belief_zeus":"رمز زيوس", "belief_apollo":"رمز أبولو — الشمس", "belief_athena":"رمز أثينا — الحكمة"}.get(id, "رمزاً")


func _thinker_name(id: String) -> String:
	return {"ideas_plato":"لوح أفلاطون", "ideas_aristotle":"لوح أرسطو — معلّم الإسكندر", "ideas_herodotus":"لوح هيرودوتس"}.get(id, "لوحاً")


func _make_shot(entry: Dictionary, camera_position: Vector3, target: Vector3) -> Dictionary:
	return {"line_id":str(entry.get("line_id", "")), "speaker_id":str(entry.get("speaker_id", "narrator")), "speaker":str(entry.get("speaker", "الراوي")), "subtitle":str(entry.get("text", "")), "audio_path":"", "gesture":str(entry.get("gesture", "none")), "position":camera_position, "target":target, "duration":3.8}


func _make_visual_shot(camera_position: Vector3, target: Vector3, duration: float) -> Dictionary:
	return {"speaker":"", "speaker_id":"narrator", "subtitle":"", "audio_path":"", "position":camera_position, "target":target, "duration":duration}


func _on_ending_action(action_id: String) -> void:
	match action_id:
		"explore":
			activity_ui.hide_ending()
			player.set_controls_enabled(true)
			set_objective(CHAPTER_TITLE, "استكشف المدينة بحرية  •  J سجل التعلم")
		"menu": GameFlow.transition_to_scene("res://scenes/ui/chapter_select.tscn", "menu")
		"replay":
			GameFlow.story_flags["lesson2_stage"] = "intro"
			GameFlow.transition_to_scene(LESSON2_SCENE, "lesson2", "الفصل الثاني", CHAPTER_TITLE)
		"quit": get_tree().quit()
