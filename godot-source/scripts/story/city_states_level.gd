extends StoryLevelController

enum ChapterState {
	ATHENS_EXPLORE,
	ATHENS_OBSERVING,
	ATHENS_CITIZEN,
	SPARTA_WATCH,
	SPARTA_OBSERVING,
	SPARTA_TRAINER,
	CONFLICT,
	TRANSITIONING
}

const SCENE_PATH := "res://scenes/levels/city_states_level.tscn"
const STAGE_KEY := "city_states_stage"

@onready var fall_respawn: FallRespawn = $FallRespawn
@onready var athens_citizen: NPCController = $AthensCast/AthensCitizen
@onready var sparta_trainer: NPCController = $SpartaCast/SpartaTrainer
@onready var athens_observation_trigger: Area3D = $AthensObservationTrigger
@onready var sparta_observation_trigger: Area3D = $SpartaObservationTrigger
@onready var athens_stage: Node3D = $AthensStage
@onready var sparta_stage: Node3D = $SpartaStage
@onready var athens_cast: Node3D = $AthensCast
@onready var sparta_cast: Node3D = $SpartaCast
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Sun

var _state: ChapterState = ChapterState.ATHENS_EXPLORE


func _ready() -> void:
	super._ready()
	GameFlow.current_chapter = "city_states"
	athens_observation_trigger.body_entered.connect(_on_athens_observation_entered)
	sparta_observation_trigger.body_entered.connect(_on_sparta_observation_entered)
	sparta_stage.hide()
	sparta_stage.process_mode = Node.PROCESS_MODE_DISABLED
	sparta_cast.hide()
	sparta_cast.process_mode = Node.PROCESS_MODE_DISABLED
	set_npc_available(athens_citizen, false, false)
	set_npc_available(sparta_trainer, false, false)
	AudioDirector.play_ambient("athens_civic_crowd")
	AudioDirector.play_music("city_states_theme")
	_restore_saved_stage()


func on_npc_interaction_requested(npc: Node) -> void:
	if npc == athens_citizen and _state == ChapterState.ATHENS_CITIZEN:
		start_conversation(athens_citizen, "athens_citizen", StoryContent.athens_citizen_dialogue())
	elif npc == sparta_trainer and _state == ChapterState.SPARTA_TRAINER:
		start_conversation(sparta_trainer, "sparta_trainer", StoryContent.sparta_trainer_dialogue())


func on_story_conversation_finished(context_id: String, _npc: Node3D) -> void:
	if context_id == "athens_citizen":
		set_npc_available(athens_citizen, false, false)
		hud.show_action_feedback("فهمتَ نظام أثينا — الرحلة تتجه الآن إلى إسبرطة", "checkpoint", 3.0)
		_transition_to_sparta()
	elif context_id == "sparta_trainer":
		set_npc_available(sparta_trainer, false, false)
		_state = ChapterState.CONFLICT
		set_story_progress("أثينا وإسبرطة", "مقارنة المدينتين", 4, 4)
		_save_stage("conflict")
		Objectives.clear_objective()
		hud.show_objective_panel(false)
		hud.show_action_feedback("اكتملت المقارنة — شاهد نتيجة الصراع", "checkpoint", 2.8)
		await cutscene.play_shots("city_state_conflict", StoryContent.conflict_shots(), true)


func on_cutscene_completed(sequence_name: String, _was_skipped: bool) -> void:
	if sequence_name == "athens_arrival":
		hud.show_objective_panel(true)
		set_objective(StoryContent.MISSION_CITY_STATES, "استكشف ساحة أثينا")
		set_story_progress("أثينا", "استكشاف الساحة", 0, 4)
	elif sequence_name == "city_state_conflict":
		_state = ChapterState.TRANSITIONING
		GameFlow.transition_to_scene(
			"res://scenes/levels/macedon_level.tscn",
			"macedon",
			"بعد زمن — مقدونيا",
			"قوة جديدة تغيّر العالم اليوناني"
		)


func _play_athens_arrival() -> void:
	hud.show_objective_panel(false)
	var shots: Array = [
		{
			"position": Vector3(-11.0, 7.5, 13.0),
			"target": Vector3(0.0, 1.0, -2.0),
			"duration": 8.0,
			"speaker": "الراوي",
			"subtitle": "في أثينا، أصبحت الساحة مكانًا للنقاش والمشاركة في شؤون المدينة."
		}
	]
	await cutscene.play_shots("athens_arrival", shots, true)


func _on_athens_observation_entered(body: Node3D) -> void:
	if body != player or _state != ChapterState.ATHENS_EXPLORE:
		return
	_state = ChapterState.ATHENS_OBSERVING
	athens_observation_trigger.set_deferred("monitoring", false)
	set_objective(StoryContent.MISSION_CITY_STATES, "استمع إلى نقاش المواطنين")
	set_story_progress("أثينا", "الاستماع إلى نقاش المواطنين", 0, 4)
	_play_ambient_exchange(StoryContent.athens_observation(), "athens_debate")


func _on_sparta_observation_entered(body: Node3D) -> void:
	if body != player or _state != ChapterState.SPARTA_WATCH:
		return
	_state = ChapterState.SPARTA_OBSERVING
	sparta_observation_trigger.set_deferred("monitoring", false)
	set_objective(StoryContent.MISSION_CITY_STATES, "شاهد تدريبات إسبرطة")
	set_story_progress("إسبرطة", "مشاهدة التدريب العسكري", 2, 4)
	_play_ambient_exchange(StoryContent.sparta_training(), "sparta_training")


func _play_ambient_exchange(entries: Array, cue_name: String) -> void:
	AudioDirector.play_sfx(cue_name)
	VoiceDirector.set_ambient_suspended(true)
	var voiced_entries := VoiceCatalog.normalize_entries(cue_name, entries)
	var actors: Array[AmbientNPCController] = []
	if cue_name == "athens_debate":
		actors = [
			$AthensCast/DebaterWest as AmbientNPCController,
			$AthensCast/DebaterEast as AmbientNPCController,
		]
	else:
		actors = [
			$SpartaCast/TraineeEast as AmbientNPCController,
			$SpartaCast/TraineeWest as AmbientNPCController,
		]
	if actors.size() >= 2:
		actors[0].begin_conversation(actors[1])
		actors[1].begin_conversation(actors[0])
	for index in voiced_entries.size():
		var entry_variant = voiced_entries[index]
		var entry: Dictionary = entry_variant
		hud.show_cinematic_subtitle(str(entry["speaker"]), str(entry["text"]))
		var duration := 3.2
		if not actors.is_empty():
			var actor := actors[index % actors.size()]
			duration = maxf(duration, actor.play_scripted_ambient_entry(entry))
		await get_tree().create_timer(duration).timeout
		if not actors.is_empty():
			actors[index % actors.size()].finish_scripted_ambient_entry()
	if actors.size() >= 2:
		actors[0].end_conversation()
		actors[1].end_conversation()
	VoiceDirector.set_ambient_suspended(false)
	hud.hide_cinematic_subtitle()
	if _state == ChapterState.ATHENS_OBSERVING:
		_state = ChapterState.ATHENS_CITIZEN
		set_npc_available(athens_citizen, true, true)
		set_objective(StoryContent.MISSION_CITY_STATES, "تحدث إلى المواطن الأثيني")
		set_story_progress("أثينا", "التحدث إلى المواطن الأثيني", 1, 4)
		_save_stage("athens_citizen")
	elif _state == ChapterState.SPARTA_OBSERVING:
		_state = ChapterState.SPARTA_TRAINER
		set_npc_available(sparta_trainer, true, true)
		set_objective(StoryContent.MISSION_CITY_STATES, "تحدث إلى المدرّب الإسبرطي")
		set_story_progress("إسبرطة", "التحدث إلى المدرّب الإسبرطي", 3, 4)
		_save_stage("sparta_trainer")


func _transition_to_sparta() -> void:
	_state = ChapterState.TRANSITIONING
	Objectives.clear_objective()
	player.set_cinematic_mode(true)
	await GameFlow.play_local_transition(
		"إسبرطة",
		"الانضباط والقوة العسكرية",
		1.35,
		Callable(self, "_activate_sparta")
	)
	player.set_cinematic_mode(false)
	_state = ChapterState.SPARTA_WATCH
	AudioDirector.play_ambient("sparta_training_yard")
	set_objective(StoryContent.MISSION_CITY_STATES, "شاهد تدريبات إسبرطة")
	set_story_progress("إسبرطة", "مشاهدة التدريب العسكري", 2, 4)
	_save_stage("sparta_watch")


func _activate_sparta() -> void:
	athens_stage.hide()
	athens_stage.process_mode = Node.PROCESS_MODE_DISABLED
	athens_cast.hide()
	athens_cast.process_mode = Node.PROCESS_MODE_DISABLED
	sparta_stage.show()
	sparta_stage.process_mode = Node.PROCESS_MODE_INHERIT
	sparta_cast.show()
	sparta_cast.process_mode = Node.PROCESS_MODE_INHERIT
	_apply_sparta_atmosphere()
	var checkpoint := Transform3D(Basis.IDENTITY, Vector3(70.0, 0.05, 14.0))
	player.global_transform = checkpoint
	player.velocity = Vector3.ZERO
	fall_respawn.set_checkpoint(checkpoint)


func _apply_sparta_atmosphere() -> void:
	# The local transition hides this restrained lighting change. Athens remains
	# bright and civic; Sparta returns with a drier, more austere late-day grade.
	var environment := world_environment.environment
	if environment != null:
		environment.fog_light_color = Color(0.66, 0.62, 0.54)
		environment.fog_light_energy = 0.31
		environment.fog_density = 0.0044
		environment.adjustment_contrast = 1.045
		environment.adjustment_saturation = 0.90
		if environment.sky != null:
			var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
			if sky_material != null:
				sky_material.sky_top_color = Color(0.085, 0.20, 0.34)
				sky_material.sky_horizon_color = Color(0.69, 0.66, 0.57)
				sky_material.ground_horizon_color = Color(0.47, 0.40, 0.30)
	# Keep Sparta's drier late-day identity without undoing the stronger shaped
	# key light used by the final open-world render pass.
	sun.light_color = Color(1.0, 0.80, 0.64)
	sun.light_energy = 1.02
	sun.rotation = Vector3(-0.80, -0.42, -0.08)


func _restore_saved_stage() -> void:
	var saved_stage := str(GameFlow.story_flags.get(STAGE_KEY, "athens_explore"))
	match saved_stage:
		"athens_citizen":
			_state = ChapterState.ATHENS_CITIZEN
			athens_observation_trigger.set_deferred("monitoring", false)
			set_npc_available(athens_citizen, true, true)
			set_objective(StoryContent.MISSION_CITY_STATES, "تحدث إلى المواطن الأثيني")
			set_story_progress("أثينا", "التحدث إلى المواطن الأثيني", 1, 4)
		"sparta_watch", "sparta_trainer", "conflict":
			_activate_sparta()
			AudioDirector.play_ambient("sparta_training_yard")
			if saved_stage == "sparta_trainer":
				_state = ChapterState.SPARTA_TRAINER
				sparta_observation_trigger.set_deferred("monitoring", false)
				set_npc_available(sparta_trainer, true, true)
				set_objective(StoryContent.MISSION_CITY_STATES, "تحدث إلى المدرّب الإسبرطي")
				set_story_progress("إسبرطة", "التحدث إلى المدرّب الإسبرطي", 3, 4)
			elif saved_stage == "conflict":
				_state = ChapterState.CONFLICT
				sparta_observation_trigger.set_deferred("monitoring", false)
				Objectives.clear_objective()
				hud.show_objective_panel(false)
				set_story_progress("أثينا وإسبرطة", "مقارنة المدينتين", 4, 4)
				call_deferred("_resume_conflict")
			else:
				_state = ChapterState.SPARTA_WATCH
				set_objective(StoryContent.MISSION_CITY_STATES, "شاهد تدريبات إسبرطة")
				set_story_progress("إسبرطة", "مشاهدة التدريب العسكري", 2, 4)
		_:
			_state = ChapterState.ATHENS_EXPLORE
			set_objective(StoryContent.MISSION_CITY_STATES, "استكشف ساحة أثينا")
			set_story_progress("أثينا", "استكشاف الساحة", 0, 4)
			if not GameFlow.has_flag("athens_arrival_seen"):
				GameFlow.set_flag("athens_arrival_seen")
				_save_stage("athens_explore")
				call_deferred("_play_athens_arrival")


func _resume_conflict() -> void:
	if _state == ChapterState.CONFLICT and not cutscene.is_active():
		await cutscene.play_shots("city_state_conflict", StoryContent.conflict_shots(), true)


func _save_stage(stage: String) -> void:
	GameFlow.save_story_progress(STAGE_KEY, stage, SCENE_PATH)
