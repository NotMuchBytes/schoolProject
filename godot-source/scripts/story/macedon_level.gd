extends StoryLevelController

enum MissionState { TALK_TO_OFFICER, TALK_TO_ALEXANDER, APPROACH_MAP, TRANSITIONING }

const SCENE_PATH := "res://scenes/levels/macedon_level.tscn"
const STAGE_KEY := "macedon_stage"

@onready var officer: NPCController = $MacedonCast/Officer
@onready var alexander: NPCController = $MacedonCast/Alexander
@onready var campaign_map_trigger: Area3D = $CampaignMapTrigger
@onready var campaign_map_marker: Label3D = $CampaignMapTrigger/MapMarker

var _state: MissionState = MissionState.TALK_TO_OFFICER


func _ready() -> void:
	super._ready()
	GameFlow.current_chapter = "macedon"
	campaign_map_trigger.body_entered.connect(_on_campaign_map_entered)
	campaign_map_trigger.monitoring = false
	campaign_map_marker.hide()
	set_npc_available(officer, false, false)
	set_npc_available(alexander, false, false)
	AudioDirector.play_ambient("macedonian_assembly")
	AudioDirector.play_music("macedon_theme")
	_restore_saved_stage()


func on_npc_interaction_requested(npc: Node) -> void:
	if npc == officer and _state == MissionState.TALK_TO_OFFICER:
		start_conversation(officer, "macedon_officer", StoryContent.macedon_officer_dialogue())
	elif npc == alexander and _state == MissionState.TALK_TO_ALEXANDER:
		start_conversation(alexander, "alexander_briefing", StoryContent.alexander_dialogue())


func on_story_conversation_finished(context_id: String, _npc: Node3D) -> void:
	if context_id == "macedon_officer":
		_state = MissionState.TALK_TO_ALEXANDER
		set_npc_available(officer, false, false)
		set_npc_available(alexander, true, true)
		set_objective(StoryContent.MISSION_ALEXANDER, "تحدث إلى الإسكندر عند خريطة الحملة")
		set_story_progress("مقدونيا", "لقاء الإسكندر", 1, 3)
		_save_stage("alexander")
		hud.show_action_feedback("الضابط وجّهك إلى الإسكندر", "checkpoint", 2.6)
	elif context_id == "alexander_briefing":
		_state = MissionState.APPROACH_MAP
		set_npc_available(alexander, false, false)
		campaign_map_marker.show()
		campaign_map_trigger.set_deferred("monitoring", true)
		set_objective(StoryContent.MISSION_ALEXANDER, "اقترب من خريطة الحملة")
		set_story_progress("مقدونيا", "فتح خريطة حملة الإسكندر", 2, 3)
		_save_stage("map")
		hud.show_action_feedback("اكتمل شرح الحملة — الخريطة جاهزة", "checkpoint", 2.8)


func on_cutscene_completed(sequence_name: String, _was_skipped: bool) -> void:
	if sequence_name == "macedon_arrival":
		hud.show_objective_panel(true)
		set_objective(StoryContent.MISSION_ALEXANDER, "قابل الضابط المقدوني")
		set_story_progress("مقدونيا", "مقابلة الضابط المقدوني", 0, 3)


func _play_arrival() -> void:
	hud.show_objective_panel(false)
	var shots: Array = [
		{
			"position": Vector3(-12.0, 7.0, 13.0),
			"target": Vector3(0.0, 1.0, -3.0),
			"duration": 8.0,
			"speaker": "الراوي",
			"subtitle": "بعد أن تبدّل ميزان القوى بين المدن، برزت مقدونيا قوة عسكرية كبرى."
		}
	]
	await cutscene.play_shots("macedon_arrival", shots, true)


func _on_campaign_map_entered(body: Node3D) -> void:
	if body != player or _state != MissionState.APPROACH_MAP:
		return
	_state = MissionState.TRANSITIONING
	campaign_map_marker.hide()
	Objectives.clear_objective()
	GameFlow.transition_to_scene(
		"res://scenes/story/historical_map.tscn",
		"historical_map",
		"حملة الإسكندر",
		"من اليونان إلى أقاليم واسعة في الشرق"
	)


func _restore_saved_stage() -> void:
	match str(GameFlow.story_flags.get(STAGE_KEY, "officer")):
		"alexander":
			_state = MissionState.TALK_TO_ALEXANDER
			set_npc_available(alexander, true, true)
			set_objective(StoryContent.MISSION_ALEXANDER, "تحدث إلى الإسكندر عند خريطة الحملة")
			set_story_progress("مقدونيا", "لقاء الإسكندر", 1, 3)
		"map":
			_state = MissionState.APPROACH_MAP
			campaign_map_marker.show()
			campaign_map_trigger.set_deferred("monitoring", true)
			set_objective(StoryContent.MISSION_ALEXANDER, "اقترب من خريطة الحملة")
			set_story_progress("مقدونيا", "فتح خريطة حملة الإسكندر", 2, 3)
		_:
			_state = MissionState.TALK_TO_OFFICER
			set_npc_available(officer, true, true)
			set_objective(StoryContent.MISSION_ALEXANDER, "قابل الضابط المقدوني")
			set_story_progress("مقدونيا", "مقابلة الضابط المقدوني", 0, 3)
			if not GameFlow.has_flag("macedon_arrival_seen"):
				GameFlow.set_flag("macedon_arrival_seen")
				_save_stage("officer")
				call_deferred("_play_arrival")


func _save_stage(stage: String) -> void:
	GameFlow.save_story_progress(STAGE_KEY, stage, SCENE_PATH)
