extends Node

var _failed := false
var _missing_voice_events: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	VoiceDirector.stop_all_voice()
	VoiceDirector.voice_file_missing.connect(_on_voice_file_missing)
	if not VoiceDirector.is_speech_enabled():
		await _test_silent_mode()
		VoiceDirector.stop_all_voice()
		print("VOICE_SYSTEM_TEST: ", "FAIL" if _failed else "PASS")
		get_tree().quit(1 if _failed else 0)
		return
	_test_speaker_ids()

	var story_entries := _collect_story_entries()
	var ambient_entries := _collect_ambient_entries()
	var all_entries: Array = story_entries + ambient_entries
	_test_catalog_and_assets(story_entries, ambient_entries, all_entries)
	await _test_runtime_playback(story_entries, ambient_entries)

	VoiceDirector.stop_all_voice()
	print("VOICE_SYSTEM_TEST: ", "FAIL" if _failed else "PASS")
	get_tree().quit(1 if _failed else 0)


func _test_silent_mode() -> void:
	_check(not VoiceDirector.is_speech_enabled(), "recorded speech is disabled by default")
	var missing_before := _missing_voice_events.size()
	var dialogue_duration := VoiceDirector.play_dialogue_entry({
		"line_id": "silent_mode_missing_dialogue",
		"speaker_id": "teacher",
		"audio_path": "res://audio/final_voice/not_present.mp3",
	})
	var narrator_duration := VoiceDirector.play_narrator_entry({
		"line_id": "silent_mode_missing_narrator",
		"speaker_id": "narrator",
		"audio_path": "res://audio/final_voice/not_present.mp3",
	})
	_check(dialogue_duration == 0.0 and narrator_duration == 0.0, "silent mode never waits for recorded speech")
	_check(not VoiceDirector.is_dialogue_playing() and not VoiceDirector.is_narrator_playing(), "silent mode starts no voice player")
	_check(_missing_voice_events.size() == missing_before, "silent mode reports no missing-audio warning")
	var lesson2_lines := Lesson2Content.all_lines()
	_check(lesson2_lines.size() == 58, "all Lesson 2 subtitle lines load")
	var valid_ids := true
	var empty_audio := true
	for line_variant in lesson2_lines:
		var line: Dictionary = line_variant
		valid_ids = valid_ids and str(line.get("line_id", "")).begins_with("l2_")
		empty_audio = empty_audio and str(line.get("audio_path", "")).is_empty()
	_check(valid_ids and empty_audio, "Lesson 2 uses stable l2 IDs and optional empty audio paths")
	var owner := Node.new()
	add_child(owner)
	_check(not VoiceDirector.try_reserve_ambient(owner, 3.0), "silent mode suppresses recorded ambient speech")
	VoiceDirector.begin_dialogue_session(&"silent_test")
	await get_tree().process_frame
	_check(not AudioDirector.is_speech_duck_active(), "silent subtitles do not duck music or ambience")
	VoiceDirector.end_dialogue_session(&"silent_test")
	owner.queue_free()


func _test_speaker_ids() -> void:
	_check(VoiceCatalog.speaker_id_for_name("الرسول") == "player", "player speaker ID")
	_check(VoiceCatalog.speaker_id_for_name("المعلّم") == "teacher", "teacher speaker ID")
	_check(
		VoiceCatalog.speaker_id_for_name("أمين المعبد") == "temple_recipient",
		"temple speaker ID"
	)
	_check(VoiceCatalog.speaker_id_for_name("الإسكندر") == "alexander", "Alexander speaker ID")
	_check(VoiceCatalog.speaker_id_for_name("الراوي") == "narrator", "narrator speaker ID")


func _collect_story_entries() -> Array:
	var result: Array = []
	_add_context(result, "village_opening", StoryContent.opening_shots(), "subtitle")
	_add_context(result, "teacher_message", StoryContent.teacher_dialogue())
	_add_context(result, "temple_record", StoryContent.temple_dialogue())
	_add_context(result, "athens_arrival", [
		StoryContent.line(
			"الراوي",
			"في أثينا، أصبحت الساحة مكانًا للنقاش والمشاركة في شؤون المدينة."
		)
	])
	_add_context(result, "athens_debate", StoryContent.athens_observation())
	_add_context(result, "athens_citizen", StoryContent.athens_citizen_dialogue())
	_add_context(result, "sparta_training", StoryContent.sparta_training())
	_add_context(result, "sparta_trainer", StoryContent.sparta_trainer_dialogue())
	_add_context(result, "city_state_conflict", StoryContent.conflict_shots(), "subtitle")
	_add_context(result, "macedon_arrival", [
		StoryContent.line(
			"الراوي",
			"بعد أن تبدّل ميزان القوى بين المدن، برزت مقدونيا قوة عسكرية كبرى."
		)
	])
	_add_context(result, "macedon_officer", StoryContent.macedon_officer_dialogue())
	_add_context(result, "alexander_briefing", StoryContent.alexander_dialogue())
	_add_context(result, "campaign_narration", StoryContent.campaign_narration())
	_add_context(result, "division_narration", StoryContent.division_narration())
	_add_context(result, "hellenistic_narration", StoryContent.hellenistic_narration())
	return result


func _add_context(
	target: Array, context_id: String, source_entries: Array, text_key: String = "text"
) -> void:
	var normalized := VoiceCatalog.normalize_entries(context_id, source_entries, text_key)
	for index in source_entries.size():
		var source: Dictionary = source_entries[index]
		var expected_text := str(source.get(text_key, source.get("text", source.get("subtitle", ""))))
		var entry: Dictionary = normalized[index]
		_check(str(entry.get("text", "")) == expected_text, "subtitle preserved: %s" % entry["line_id"])
		target.append(entry)


func _collect_ambient_entries() -> Array:
	var specifications := [
		["village_harbor", 0, "وصل الزيت من الجزيرة مع سفينة الصباح."],
		["village_harbor", 1, "المرفأ نشيط اليوم."],
		["village_market", 0, "زيتٌ وفخار من الجزر!"],
		["village_market", 1, "أما القافلة البرية فتأخرت عند الممر الجبلي."],
		["village_square", 0, "البحر يقرّب جزيرة، والجبل يبعد مدينة."],
		["village_square", 1, "سأعود قبل غروب الشمس."],
		["village_upper_path", 0, "الطريق إلى المعبد صاعد، لكنه واضح."],
		["athens_debater_west", 0, "فلنسمع أصحاب القوارب قبل أن نقرر."],
		["athens_debater_east", 0, "سيُعرض الأمر في الساحة."],
		["athens_civic", 0, "اجتماع المواطنين سيبدأ قريبًا."],
		["sparta_trainee_west", 0, "القوة في الانضباط."],
		["sparta_trainee_center", 0, "حافظوا على الإيقاع!"],
		["sparta_trainer_call", 0, "الصف الأول، تقدّم!"],
		["macedon_patrol_west", 0, "استعدوا لعبور البحر."],
		["macedon_patrol_east", 0, "الأوامر عند خريطة الحملة."],
		["macedon_supply", 0, "المؤن جاهزة للحملة."],
	]
	var result: Array = []
	for specification in specifications:
		result.append(VoiceCatalog.ambient_entry(
			str(specification[0]), int(specification[1]), str(specification[2])
		))
	return result


func _test_catalog_and_assets(story_entries: Array, ambient_entries: Array, all_entries: Array) -> void:
	var expected_files := VoiceCatalog.expected_final_voice_files()
	_check(expected_files.size() == 65, "catalog contains all 65 non-player recordings")
	_check(story_entries.size() == 55, "complete story contains 55 subtitle lines")
	_check(ambient_entries.size() == 16, "complete ambient set contains 16 lines")

	var covered_line_ids: Dictionary = {}
	var resolved_paths: Dictionary = {}
	var silent_player_count := 0
	var recorded_story_count := 0
	var paths_are_valid := true
	var durations_are_valid := true
	for entry_variant in all_entries:
		var entry: Dictionary = entry_variant
		var line_id := str(entry.get("line_id", ""))
		var speaker_id := str(entry.get("speaker_id", ""))
		var audio_path := str(entry.get("audio_path", ""))
		if speaker_id == "player":
			silent_player_count += 1
			paths_are_valid = paths_are_valid and audio_path.is_empty()
			paths_are_valid = paths_are_valid and bool(entry.get("voice_intentionally_silent", false))
			continue
		recorded_story_count += 1
		covered_line_ids[line_id] = true
		paths_are_valid = (
			paths_are_valid
			and expected_files.has(line_id)
			and audio_path.ends_with(".mp3")
			and ResourceLoader.exists(audio_path)
		)
		if not audio_path.is_empty():
			resolved_paths[audio_path] = line_id
			var stream := load(audio_path) as AudioStream
			durations_are_valid = durations_are_valid and stream != null and stream.get_length() > 0.1

	_check(silent_player_count == 6, "six player lines remain intentionally subtitle-only")
	_check(recorded_story_count == 65, "65 non-player lines resolve through the story and ambient flow")
	_check(paths_are_valid, "all mapped audio paths are valid final MP3 resources")
	_check(durations_are_valid, "all final MP3 resources load with non-zero duration")
	_check(resolved_paths.size() == 65, "every mapped line resolves to one unique recording")

	var coverage_is_complete := covered_line_ids.size() == expected_files.size()
	for line_id_variant in expected_files.keys():
		coverage_is_complete = coverage_is_complete and covered_line_ids.has(str(line_id_variant))
	_check(coverage_is_complete, "every final recording is mapped to a current exact story line")

	var disk_mp3s: Array[String] = []
	_collect_mp3_files("res://audio/final_voice", disk_mp3s)
	var names_are_exact := disk_mp3s.size() == 65
	for path in disk_mp3s:
		names_are_exact = names_are_exact and resolved_paths.has(path)
	_check(names_are_exact, "final voice root has no missing, duplicate-path, or incorrectly named MP3s")


func _collect_mp3_files(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry_name := directory.get_next()
	while not entry_name.is_empty():
		if entry_name != "." and entry_name != "..":
			var child_path := directory_path.path_join(entry_name)
			if directory.current_is_dir():
				_collect_mp3_files(child_path, output)
			elif entry_name.get_extension().to_lower() == "mp3":
				output.append(child_path)
		entry_name = directory.get_next()
	directory.list_dir_end()


func _test_runtime_playback(story_entries: Array, ambient_entries: Array) -> void:
	var by_line_id: Dictionary = {}
	for entry_variant in story_entries:
		var entry: Dictionary = entry_variant
		by_line_id[str(entry["line_id"])] = entry

	# Exercise one real clip from every important speaking role.
	for line_id in [
		"teacher_message_001",
		"temple_record_001",
		"athens_citizen_001",
		"sparta_trainer_002",
		"macedon_officer_001",
		"alexander_briefing_001",
	]:
		var duration := VoiceDirector.play_dialogue_entry(by_line_id[line_id])
		await get_tree().process_frame
		_check(duration > 0.1 and VoiceDirector.is_dialogue_playing(), "runtime voice plays: " + line_id)
		VoiceDirector.stop_dialogue(false)

	var narrator_duration := VoiceDirector.play_narrator_entry(by_line_id["village_opening_001"])
	await get_tree().process_frame
	_check(
		narrator_duration > 0.1
		and VoiceDirector.is_narrator_playing()
		and VoiceDirector.get("_narrator_player") is AudioStreamPlayer,
		"narrator uses a valid non-positional stream"
	)
	VoiceDirector.stop_narrator(false)

	var messenger_duration := VoiceDirector.play_narrator_entry(by_line_id["campaign_narration_006"])
	await get_tree().process_frame
	_check(messenger_duration > 0.1 and VoiceDirector.is_narrator_playing(), "Macedonian messenger voice plays")

	# A new important line must always stop the other important channel.
	VoiceDirector.play_dialogue_entry(by_line_id["teacher_message_001"])
	await get_tree().process_frame
	_check(
		VoiceDirector.is_dialogue_playing() and not VoiceDirector.is_narrator_playing(),
		"dialogue and narration never overlap"
	)

	var missing_before := _missing_voice_events.size()
	var player_entry: Dictionary = by_line_id["teacher_message_002"]
	var player_duration := VoiceDirector.play_dialogue_entry(player_entry)
	await get_tree().process_frame
	_check(
		player_duration == 0.0
		and not VoiceDirector.is_dialogue_playing()
		and not VoiceDirector.is_narrator_playing()
		and _missing_voice_events.size() == missing_before,
		"player dialogue stays silent without a missing-file report"
	)

	var synthetic_missing_count := _missing_voice_events.size()
	var missing_duration := VoiceDirector.play_dialogue_entry({
		"speaker_id": "teacher",
		"line_id": "synthetic_missing_voice_test",
		"audio_path": "res://audio/final_voice/teacher/not_a_real_recording.mp3",
	})
	_check(
		missing_duration == 0.0
		and not VoiceDirector.is_dialogue_playing()
		and _missing_voice_events.size() == synthetic_missing_count + 1,
		"a missing non-player recording reports once and continues safely"
	)
	# The synthetic failure above validates fallback behavior; remove it before
	# checking the real 65-file set for missing reports.
	_missing_voice_events.resize(synthetic_missing_count)

	Dialogue.start_dialogue("silent_player_test", [
		{"speaker": "الرسول", "text": "اختبار ترجمة صامتة"}
	])
	_check(Dialogue.is_active(), "silent player subtitle opens normally")
	Dialogue.advance()
	_check(not Dialogue.is_active(), "silent player subtitle advances normally")

	var reservation_owner := Node.new()
	add_child(reservation_owner)
	VoiceDirector.begin_dialogue_session(&"voice_test")
	_check(not VoiceDirector.try_reserve_ambient(reservation_owner, 1.0), "ambient is suppressed for full dialogue sessions")
	_check(AudioDirector.is_speech_duck_active(), "important speech activates mix ducking")
	VoiceDirector.end_dialogue_session(&"voice_test")
	reservation_owner.queue_free()

	var ambient_scene := load("res://scenes/characters/ambient_messenger_npc.tscn") as PackedScene
	var ambient_npc := ambient_scene.instantiate() as AmbientNPCController
	ambient_npc.ambient_category = "village_harbor"
	ambient_npc.ambient_lines = PackedStringArray([
		"وصل الزيت من الجزيرة مع سفينة الصباح.",
		"المرفأ نشيط اليوم.",
	])
	add_child(ambient_npc)
	await get_tree().process_frame
	var ambient_duration := ambient_npc.play_scripted_ambient_entry(ambient_entries[0])
	await get_tree().process_frame
	var positional_player := ambient_npc.get_node_or_null("AmbientVoicePlayer3D") as AudioStreamPlayer3D
	_check(
		positional_player != null
		and positional_player.playing
		and positional_player.bus == &"Voice"
		and positional_player.max_distance > 0.0
		and positional_player.position.y > 1.0
		and ambient_duration > 4.0,
		"ambient NPC speech is positional, attenuated, and uses real MP3 duration"
	)
	ambient_npc.finish_scripted_ambient_entry()

	ambient_npc.call("_try_play_solo_line")
	await get_tree().process_frame
	var competing_owner := Node.new()
	add_child(competing_owner)
	_check(
		float(ambient_npc.get("_speech_hide_timer")) > 4.0
		and not VoiceDirector.try_reserve_ambient(competing_owner, 1.0),
		"long ambient MP3 reserves the global slot for its actual duration"
	)
	VoiceDirector.stop_all_voice()
	await get_tree().process_frame
	_check(not positional_player.playing, "global voice stop also stops positional ambient speech")
	competing_owner.queue_free()
	ambient_npc.queue_free()

	# Verify the configured attenuation mix actually reaches and leaves its target.
	await get_tree().create_timer(0.5, true, false, true).timeout
	var music_bus := AudioServer.get_bus_index("Music")
	var ambient_bus := AudioServer.get_bus_index("Ambient")
	var music_base := AudioServer.get_bus_volume_db(music_bus)
	var ambient_base := AudioServer.get_bus_volume_db(ambient_bus)
	VoiceDirector.begin_dialogue_session(&"duck_test")
	await get_tree().create_timer(0.25, true, false, true).timeout
	_check(
		AudioServer.get_bus_volume_db(music_bus) <= music_base - 5.5
		and AudioServer.get_bus_volume_db(ambient_bus) <= ambient_base - 2.5,
		"speech smoothly ducks Music and Ambient buses"
	)
	VoiceDirector.end_dialogue_session(&"duck_test")
	await get_tree().create_timer(0.55, true, false, true).timeout
	_check(
		absf(AudioServer.get_bus_volume_db(music_bus) - music_base) < 0.1
		and absf(AudioServer.get_bus_volume_db(ambient_bus) - ambient_base) < 0.1,
		"background mix restores after speech"
	)
	_check(_missing_voice_events.is_empty(), "no expected non-player voice file is reported missing")


func _on_voice_file_missing(line_id: String, expected_path: String) -> void:
	_missing_voice_events.append("%s=%s" % [line_id, expected_path])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
		return
	_failed = true
	push_error("FAIL: " + message)
