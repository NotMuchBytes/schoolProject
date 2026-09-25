class_name VoiceCatalog
extends RefCounted

const SPEAKER_IDS := {
	"الرسول": "player",
	"المعلّم": "teacher",
	"أمين المعبد": "temple_recipient",
	"المواطن الأثيني": "athens",
	"مواطن أول": "athens",
	"مواطن ثانٍ": "athens",
	"المنادي": "athens",
	"المدرّب الإسبرطي": "sparta",
	"المدرّب": "sparta",
	"متدرّب": "sparta",
	"الإسكندر": "alexander",
	"الضابط المقدوني": "macedonian_officer",
	"رسول مقدوني": "macedonian_messenger",
	"الراوي": "narrator",
}

const SPEAKER_FOLDERS := {
	"player": "player",
	"teacher": "teacher",
	"temple_recipient": "temple_recipient",
	"athens": "athens",
	"sparta": "sparta",
	"alexander": "alexander",
	"macedonian_officer": "macedonian_officer",
	"macedonian_messenger": "narrator",
	"narrator": "narrator",
	"npc": "ambient",
}

# The delivered recordings intentionally use a compact, global numbering scheme
# that skips the silent player lines. Keep this mapping in one place so story,
# scene, and subtitle data remain untouched.
const FINAL_VOICE_ROOTS := [
	"res://audio/final_voice",
	# The supplied bundle currently has one additional container directory. The
	# first root remains supported if the bundle is flattened in a future export.
	"res://audio/final_voice/final_voice_mp3",
]

const FINAL_VOICE_FILES := {
	"village_opening_001": "narrator/narrator_001.mp3",
	"village_opening_002": "narrator/narrator_002.mp3",
	"village_opening_003": "narrator/narrator_003.mp3",
	"village_opening_004": "narrator/narrator_004.mp3",
	"teacher_message_001": "teacher/teacher_message_001.mp3",
	"teacher_message_003": "teacher/teacher_message_002.mp3",
	"teacher_message_004": "teacher/teacher_message_003.mp3",
	"teacher_message_005": "teacher/teacher_message_004.mp3",
	"temple_record_001": "temple/temple_recipient_001.mp3",
	"temple_record_003": "temple/temple_recipient_002.mp3",
	"temple_record_004": "temple/temple_recipient_003.mp3",
	"athens_arrival_001": "narrator/narrator_005.mp3",
	"athens_debate_001": "athens/athens_001.mp3",
	"athens_debate_002": "athens/athens_002.mp3",
	"athens_debate_003": "athens/athens_003.mp3",
	"athens_citizen_001": "athens/athens_004.mp3",
	"athens_citizen_003": "athens/athens_005.mp3",
	"athens_citizen_004": "athens/athens_006.mp3",
	"sparta_training_001": "sparta/sparta_001.mp3",
	"sparta_training_002": "sparta/sparta_002.mp3",
	"sparta_trainer_002": "sparta/sparta_003.mp3",
	"sparta_trainer_003": "sparta/sparta_004.mp3",
	"sparta_trainer_005": "sparta/sparta_005.mp3",
	"city_state_conflict_001": "narrator/narrator_006.mp3",
	"city_state_conflict_002": "narrator/narrator_007.mp3",
	"city_state_conflict_003": "narrator/narrator_008.mp3",
	"macedon_arrival_001": "narrator/narrator_009.mp3",
	"macedon_officer_001": "macedonian_officer/macedonian_officer_001.mp3",
	"macedon_officer_002": "macedonian_officer/macedonian_officer_002.mp3",
	"macedon_officer_003": "macedonian_officer/macedonian_officer_003.mp3",
	"alexander_briefing_001": "alexander/alexander_001.mp3",
	"alexander_briefing_003": "alexander/alexander_002.mp3",
	"alexander_briefing_004": "alexander/alexander_003.mp3",
	"campaign_narration_001": "narrator/narrator_010.mp3",
	"campaign_narration_002": "narrator/narrator_011.mp3",
	"campaign_narration_003": "narrator/narrator_012.mp3",
	"campaign_narration_004": "narrator/narrator_013.mp3",
	"campaign_narration_005": "narrator/narrator_014.mp3",
	"campaign_narration_006": "macedonian_messenger/macedonian_messenger_001.mp3",
	"campaign_narration_007": "narrator/narrator_015.mp3",
	"division_narration_001": "narrator/narrator_016.mp3",
	"division_narration_002": "narrator/narrator_017.mp3",
	"division_narration_003": "narrator/narrator_018.mp3",
	"division_narration_004": "narrator/narrator_019.mp3",
	"division_narration_005": "narrator/narrator_020.mp3",
	"hellenistic_narration_001": "narrator/narrator_021.mp3",
	"hellenistic_narration_002": "narrator/narrator_022.mp3",
	"hellenistic_narration_003": "narrator/narrator_023.mp3",
	"hellenistic_narration_004": "narrator/narrator_024.mp3",
	"ambient_village_harbor_001": "ambient/ambient_001.mp3",
	"ambient_village_harbor_002": "ambient/ambient_002.mp3",
	"ambient_village_market_001": "ambient/ambient_003.mp3",
	"ambient_village_market_002": "ambient/ambient_004.mp3",
	"ambient_village_square_001": "ambient/ambient_005.mp3",
	"ambient_village_square_002": "ambient/ambient_006.mp3",
	"ambient_village_upper_path_001": "ambient/ambient_007.mp3",
	"ambient_athens_debater_west_001": "ambient/ambient_008.mp3",
	"ambient_athens_debater_east_001": "ambient/ambient_009.mp3",
	"ambient_athens_civic_001": "ambient/ambient_010.mp3",
	"ambient_sparta_trainee_west_001": "ambient/ambient_011.mp3",
	"ambient_sparta_trainee_center_001": "ambient/ambient_012.mp3",
	"ambient_sparta_trainer_call_001": "ambient/ambient_013.mp3",
	"ambient_macedon_patrol_west_001": "ambient/ambient_014.mp3",
	"ambient_macedon_patrol_east_001": "ambient/ambient_015.mp3",
	"ambient_macedon_supply_001": "ambient/ambient_016.mp3",
}


static func normalize_entries(context_id: String, entries: Array, text_key: String = "text") -> Array:
	var normalized: Array = []
	for index in entries.size():
		normalized.append(normalize_entry(context_id, index, entries[index], text_key))
	return normalized


static func normalize_entry(
	context_id: String,
	index: int,
	entry_variant: Variant,
	text_key: String = "text"
) -> Dictionary:
	var entry: Dictionary = (entry_variant as Dictionary).duplicate(true)
	var speaker_name := str(entry.get("speaker", "الراوي"))
	var speaker_id := str(entry.get("speaker_id", speaker_id_for_name(speaker_name)))
	var line_id := str(entry.get("line_id", "%s_%03d" % [_safe_id(context_id), index + 1]))
	var subtitle := str(entry.get(text_key, entry.get("text", entry.get("subtitle", ""))))
	var folder := str(SPEAKER_FOLDERS.get(speaker_id, speaker_id))
	entry["speaker"] = speaker_name
	entry["speaker_id"] = speaker_id
	entry["line_id"] = line_id
	entry["text"] = subtitle
	if speaker_id == "player":
		# The messenger is deliberately a silent protagonist. An empty path is
		# explicit metadata, not a missing recording.
		entry["audio_path"] = ""
		entry["voice_intentionally_silent"] = true
	else:
		var final_path := final_voice_path_for_line(line_id)
		entry["audio_path"] = (
			final_path
			if not final_path.is_empty()
			else str(entry.get(
				"audio_path", "res://audio/dialogue/%s/%s.ogg" % [folder, line_id]
			))
		)
		entry["voice_intentionally_silent"] = false
	entry["gesture"] = str(entry.get("gesture", _default_gesture(speaker_id, index)))
	return entry


static func speaker_id_for_name(display_name: String) -> String:
	return str(SPEAKER_IDS.get(display_name.strip_edges(), "npc"))


static func ambient_entry(category: String, index: int, text: String) -> Dictionary:
	var safe_category := _safe_id(category)
	var line_id := "ambient_%s_%03d" % [safe_category, index + 1]
	var final_path := final_voice_path_for_line(line_id)
	return {
		"speaker": "",
		"speaker_id": "ambient_" + safe_category,
		"line_id": line_id,
		"text": text,
		"audio_path": (
			final_path if not final_path.is_empty() else "res://audio/ambient/%s.ogg" % line_id
		),
		"gesture": "talk_ambient",
	}


static func final_voice_path_for_line(line_id: String) -> String:
	if not FINAL_VOICE_FILES.has(line_id):
		return ""
	var relative_path := str(FINAL_VOICE_FILES[line_id])
	for root in FINAL_VOICE_ROOTS:
		var candidate := str(root).path_join(relative_path)
		if ResourceLoader.exists(candidate):
			return candidate
	# Return the documented root when reporting a genuinely absent file.
	return str(FINAL_VOICE_ROOTS[0]).path_join(relative_path)


static func expected_final_voice_files() -> Dictionary:
	return FINAL_VOICE_FILES.duplicate()


static func _default_gesture(speaker_id: String, index: int) -> String:
	if speaker_id == "narrator":
		return "none"
	if speaker_id == "player":
		return "talk_response"
	return "talk_emphasis" if index % 3 == 2 else "talk_explain"


static func _safe_id(value: String) -> String:
	var result := value.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
	return result if not result.is_empty() else "line"
