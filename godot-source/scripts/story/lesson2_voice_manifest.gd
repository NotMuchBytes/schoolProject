class_name Lesson2VoiceManifest
extends RefCounted

const FUTURE_AUDIO_ROOT := "res://audio/final_voice_lesson2"

const IMPORTANT_SPEAKER_ORDER: Array[String] = [
	"l2_guide",
	"l2_civic_guide",
	"l2_farmer",
	"l2_artisan",
	"l2_merchant",
	"l2_scribe",
	"l2_temple_guide",
	"l2_theatre_director",
	"l2_tragedy_actor",
	"l2_comedy_actor",
	"l2_library_guide",
	"l2_architect",
	"l2_coach",
	"l2_jordan_guide",
]

const AMBIENT_SPEAKER_ORDER: Array[String] = [
	"l2_farm_worker",
	"l2_market_carrier",
	"l2_harbour_worker",
	"l2_theatre_chorus",
	"l2_theatre_stagehand",
	"l2_library_student",
]

const SPEAKER_DEFINITIONS := {
	"l2_narrator": {
		"name_ar": "الراوي", "folder": "narrator", "prefix": "narrator_l2",
		"style": "راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية",
	},
	"l2_guide": {
		"name_ar": "دليل المدينة", "folder": "city_guide", "prefix": "city_guide",
		"style": "دليل بالغ ودود وواثق؛ ترحيبي وواضح",
	},
	"l2_civic_guide": {
		"name_ar": "دليل الساحة", "folder": "civic_guide", "prefix": "civic_guide",
		"style": "مسؤول مدني هادئ؛ دقيق وشارح",
	},
	"l2_farmer": {
		"name_ar": "المزارع", "folder": "farmer", "prefix": "farmer",
		"style": "مزارع بالغ عملي ودافئ؛ حديث طبيعي",
	},
	"l2_artisan": {
		"name_ar": "الحرفي", "folder": "artisan", "prefix": "artisan",
		"style": "حرفي متمرس؛ فخور بعمله وعملي",
	},
	"l2_merchant": {
		"name_ar": "التاجر", "folder": "merchant", "prefix": "merchant",
		"style": "تاجر نشيط وواضح؛ ودود وغير مبالغ",
	},
	"l2_scribe": {
		"name_ar": "كاتب السجل", "folder": "scribe", "prefix": "scribe",
		"style": "كاتب سجل متزن؛ رسمي قليلاً ودقيق",
	},
	"l2_temple_guide": {
		"name_ar": "دليل المعبد", "folder": "temple_guide", "prefix": "temple_guide",
		"style": "دليل معبد هادئ ومحترم؛ تاريخي ومحايد",
	},
	"l2_theatre_director": {
		"name_ar": "مشرف المسرح", "folder": "theatre_director", "prefix": "theatre_director",
		"style": "مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل",
	},
	"l2_tragedy_actor": {
		"name_ar": "ممثل التراجيديا", "folder": "tragedy_actor", "prefix": "tragedy_actor",
		"style": "ممثل مسرحي حزين ومقروء؛ أداء قصير مضبوط",
	},
	"l2_comedy_actor": {
		"name_ar": "ممثل الكوميديا", "folder": "comedy_actor", "prefix": "comedy_actor",
		"style": "ممثل مسرحي مرح وخفيف؛ نهاية سعيدة واضحة",
	},
	"l2_library_guide": {
		"name_ar": "دليل المكتبة", "folder": "library_guide", "prefix": "library_guide",
		"style": "دليل مكتبة مثقف وهادئ؛ دقيق وسلس",
	},
	"l2_architect": {
		"name_ar": "البنّاء", "folder": "architect", "prefix": "architect",
		"style": "بنّاء خبير؛ عملي وواضح مع ثقة هادئة",
	},
	"l2_coach": {
		"name_ar": "المدرب", "folder": "coach", "prefix": "coach",
		"style": "مدرب رياضي مشجع وحازم؛ طاقة مضبوطة",
	},
	"l2_jordan_guide": {
		"name_ar": "دليل الآثار", "folder": "jordan_guide", "prefix": "jordan_guide",
		"style": "دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ",
	},
	"l2_farm_worker": {
		"name_ar": "عامل المزرعة", "folder": "farm_worker", "prefix": "ambient_l2",
		"style": "عامل منشغل؛ جملة محيطية طبيعية وقصيرة",
	},
	"l2_market_carrier": {
		"name_ar": "حامل بضائع السوق", "folder": "market_carrier", "prefix": "ambient_l2",
		"style": "عامل سوق أثناء العمل؛ طبيعي وغير موجه للاعب",
	},
	"l2_harbour_worker": {
		"name_ar": "عامل المرفأ", "folder": "harbour_worker", "prefix": "ambient_l2",
		"style": "عامل مرفأ عملي؛ نداء قصير من البيئة",
	},
	"l2_theatre_chorus": {
		"name_ar": "عضو الجوقة", "folder": "theatre_chorus", "prefix": "ambient_l2",
		"style": "عضو جوقة يتحدث إلى زميل؛ سؤال طبيعي واضح",
	},
	"l2_theatre_stagehand": {
		"name_ar": "عامل خشبة المسرح", "folder": "theatre_stagehand", "prefix": "ambient_l2",
		"style": "عامل مسرح يجيب زميله؛ هادئ ومستعد",
	},
	"l2_library_student": {
		"name_ar": "طالب المكتبة", "folder": "library_student", "prefix": "ambient_l2",
		"style": "طالب يراجع المعروض؛ هادئ وطبيعي",
	},
}

const CONTEXTS := {
	"intro": "الانتقال من الفصل الأول وفتح سجل الدرس الثاني",
	"politics": "الساحة العامة — أنظمة الحكم",
	"farm": "منطقة الزراعة — المحاصيل والمعالجة",
	"workshop": "الورشة — الصناعة والمواد",
	"trade": "السوق والمرفأ — التجارة الداخلية والخارجية",
	"society": "فناء السجل — طبقات المجتمع والحقوق",
	"religion": "المعبد — المعتقدات اليونانية",
	"theatre": "المسرح — شرح العرض ونشاطه",
	"stage_tragedy": "بروفة المسرح — المثال التراجيدي",
	"stage_comedy": "بروفة المسرح — المثال الكوميدي",
	"ideas": "المكتبة — الفلسفة وكتابة التاريخ",
	"architecture": "منصة المشاهدة — العمارة والنحت",
	"sport": "ساحة الرياضة — نشاط الجري القصير",
	"jordan": "سجل الأردن — المدن والآثار وقصر العبد",
	"ending": "اكتمال سجل الحياة ونهاية الفصل الثاني",
}

static func enrich_lines(source_lines: Array) -> Array:
	var result: Array = []
	var speaker_counters: Dictionary = {}
	var ambient_counter := 0
	for source_variant in source_lines:
		var line: Dictionary = (source_variant as Dictionary).duplicate(true)
		var speaker_id := str(line.get("speaker_id", ""))
		var category := category_for(line)
		var definition: Dictionary = SPEAKER_DEFINITIONS.get(speaker_id, {})
		if definition.is_empty():
			push_error("Unknown Lesson 2 voice speaker: %s" % speaker_id)
			result.append(line)
			continue
		var filename := ""
		if category == "ambient":
			ambient_counter += 1
			filename = "ambient_l2_%03d.mp3" % ambient_counter
		else:
			var sequence := int(speaker_counters.get(speaker_id, 0)) + 1
			speaker_counters[speaker_id] = sequence
			filename = "%s_%03d.mp3" % [str(definition["prefix"]), sequence]
		line["voice_filename"] = filename
		line["future_audio_path"] = "%s/%s/%s" % [
			FUTURE_AUDIO_ROOT, str(definition["folder"]), filename
		]
		line["voice_category"] = category
		line["recording_context"] = context_for(str(line.get("line_id", "")))
		line["delivery"] = str(definition["style"])
		result.append(line)
	return result


static func category_for(line: Dictionary) -> String:
	var line_id := str(line.get("line_id", ""))
	if line_id.begins_with("l2_ambient_"):
		return "ambient"
	if line_id.begins_with("l2_stage_"):
		return "npc_to_npc"
	if str(line.get("speaker_id", "")) == "l2_narrator":
		return "narrator"
	return "important_npc"


static func context_for(line_id: String) -> String:
	var remainder := line_id.trim_prefix("l2_")
	# Check the longer stage prefixes before the generic theatre prefix.
	for key in [
		"stage_tragedy", "stage_comedy", "architecture", "workshop", "politics",
		"religion", "theatre", "society", "ending", "ambient", "intro", "farm",
		"trade", "ideas", "sport", "jordan",
	]:
		if remainder.begins_with(str(key) + "_"):
			if key == "ambient":
				return "حديث محيطي مؤلف داخل مدينة الفصل الثاني"
			return str(CONTEXTS.get(key, "الفصل الثاني"))
	return "الفصل الثاني"


static func speaker_definition(speaker_id: String) -> Dictionary:
	return (SPEAKER_DEFINITIONS.get(speaker_id, {}) as Dictionary).duplicate(true)


static func full_speaker_order() -> Array[String]:
	var result: Array[String] = ["l2_narrator"]
	result.append_array(IMPORTANT_SPEAKER_ORDER)
	result.append_array(AMBIENT_SPEAKER_ORDER)
	return result
