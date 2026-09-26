extends StoryLevelController

enum MissionState { TALK_TO_TEACHER, GO_TO_TEMPLE, APPROACH_MAP, TRANSITIONING }

const SCENE_PATH := "res://scenes/levels/main_level.tscn"
const STAGE_KEY := "village_stage"

@onready var teacher: TestNPC = $Teacher
@onready var temple_recipient: TestNPC = $TempleRecipient
@onready var history_map_trigger: Area3D = $HistoryMapTrigger
@onready var history_map_marker: Label3D = $HistoryMapTrigger/MapMarker

var _mission_state: MissionState = MissionState.TALK_TO_TEACHER


func _ready() -> void:
	super._ready()
	GameFlow.current_chapter = "village"
	history_map_trigger.body_entered.connect(_on_history_map_entered)
	history_map_trigger.monitoring = false
	history_map_marker.hide()
	set_npc_available(teacher, false, false)
	set_npc_available(temple_recipient, false, false)
	AudioDirector.play_ambient("village_sea_wind_market")
	AudioDirector.play_music("greek_world_theme")
	_restore_saved_stage()
	if _mission_state == MissionState.TALK_TO_TEACHER and not GameFlow.has_flag("village_opening_seen"):
		GameFlow.set_flag("village_opening_seen")
		_save_stage("teacher")
		call_deferred("_play_opening")


func on_npc_interaction_requested(npc: Node) -> void:
	if npc == teacher and _mission_state == MissionState.TALK_TO_TEACHER:
		start_conversation(teacher, "teacher_message", StoryContent.teacher_dialogue())
	elif npc == temple_recipient and _mission_state == MissionState.GO_TO_TEMPLE:
		start_conversation(temple_recipient, "temple_record", StoryContent.temple_dialogue())


func on_story_conversation_finished(context_id: String, _npc: Node3D) -> void:
	match context_id:
		"teacher_message":
			_mission_state = MissionState.GO_TO_TEMPLE
			set_npc_available(teacher, false, false)
			set_npc_available(temple_recipient, true, true)
			set_objective(StoryContent.MISSION_GREEK_WORLD, "أوصل الرسالة إلى المعبد")
			set_story_progress("القرية", "إيصال الرسالة إلى المعبد", 1, 3)
			_save_stage("temple")
			hud.show_action_feedback("تمّ التحدث إلى المعلّم — اتجه إلى المعبد", "checkpoint", 2.8)
			AudioDirector.play_sfx("objective_update")
		"temple_record":
			_mission_state = MissionState.APPROACH_MAP
			set_npc_available(temple_recipient, false, false)
			history_map_marker.show()
			history_map_trigger.set_deferred("monitoring", true)
			set_objective(StoryContent.MISSION_GREEK_WORLD, "اقترب من خريطة المدن")
			set_story_progress("القرية", "فتح خريطة المدن اليونانية", 2, 3)
			_save_stage("map")
			hud.show_mission_complete("وصلت الرسالة — افتُتح سجل المدن", 3.5)


func on_cutscene_completed(sequence_name: String, _was_skipped: bool) -> void:
	if sequence_name == "village_opening":
		hud.show_objective_panel(true)
		set_objective(StoryContent.MISSION_GREEK_WORLD, "تحدث إلى المعلّم")
		set_story_progress("القرية", "التحدث إلى المعلّم", 0, 3)


func _play_opening() -> void:
	hud.show_objective_panel(false)
	await cutscene.play_shots("village_opening", StoryContent.opening_shots(), true)


func _on_history_map_entered(body: Node3D) -> void:
	if body != player or _mission_state != MissionState.APPROACH_MAP:
		return
	_mission_state = MissionState.TRANSITIONING
	history_map_marker.hide()
	Objectives.clear_objective()
	GameFlow.transition_to_scene(
		"res://scenes/levels/city_states_level.tscn",
		"city_states",
		"أثينا وإسبرطة",
		"مدينتان يونانيتان... وطريقان مختلفان"
	)


func _restore_saved_stage() -> void:
	match str(GameFlow.story_flags.get(STAGE_KEY, "teacher")):
		"temple":
			_mission_state = MissionState.GO_TO_TEMPLE
			set_npc_available(temple_recipient, true, true)
			set_objective(StoryContent.MISSION_GREEK_WORLD, "أوصل الرسالة إلى المعبد")
			set_story_progress("القرية", "إيصال الرسالة إلى المعبد", 1, 3)
		"map":
			_mission_state = MissionState.APPROACH_MAP
			history_map_marker.show()
			history_map_trigger.set_deferred("monitoring", true)
			set_objective(StoryContent.MISSION_GREEK_WORLD, "اقترب من خريطة المدن")
			set_story_progress("القرية", "فتح خريطة المدن اليونانية", 2, 3)
		_:
			_mission_state = MissionState.TALK_TO_TEACHER
			set_npc_available(teacher, true, true)
			set_objective(StoryContent.MISSION_GREEK_WORLD, "تحدث إلى المعلّم")
			set_story_progress("القرية", "التحدث إلى المعلّم", 0, 3)
			_save_stage("teacher")


func _save_stage(stage: String) -> void:
	GameFlow.save_story_progress(STAGE_KEY, stage, SCENE_PATH)
