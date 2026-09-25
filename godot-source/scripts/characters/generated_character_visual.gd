class_name GeneratedCharacterVisual
extends Node3D

## Non-destructive presentation layer for the generated Ancient Greek characters.
## The imported skeleton, meshes, and Idle/Walk/Run clips stay untouched. Role
## palettes and small low-poly accessories are applied to each scene instance.

enum AppearanceProfile {
	AUTO,
	PLAYER_MESSENGER,
	TEACHER_ELDER,
	TEMPLE_ATTENDANT,
	ATHENIAN_CITIZEN,
	ATHENIAN_ELDER,
	SPARTAN_TRAINER,
	SPARTAN_HOPLITE,
	MACEDONIAN_OFFICER,
	ALEXANDER,
	MACEDONIAN_SOLDIER,
	VILLAGER_YOUTH,
	VILLAGER_MERCHANT,
	VILLAGER_CIVIC,
}

const PROFILE_LABELS := [
	"auto",
	"player_messenger",
	"teacher_elder",
	"temple_attendant",
	"athenian_citizen",
	"athenian_elder",
	"spartan_trainer",
	"spartan_hoplite",
	"macedonian_officer",
	"alexander",
	"macedonian_soldier",
	"villager_youth",
	"villager_merchant",
	"villager_civic",
]

@export_group("Animation")
@export_node_path("CharacterBody3D") var movement_body_path: NodePath
@export var idle_only: bool = false
@export var run_speed_threshold: float = 5.4

@export_group("Appearance")
@export_enum(
	"Auto",
	"Player Messenger",
	"Teacher Elder",
	"Temple Attendant",
	"Athenian Citizen",
	"Athenian Elder",
	"Spartan Trainer",
	"Spartan Hoplite",
	"Macedonian Officer",
	"Alexander",
	"Macedonian Soldier",
	"Villager Youth",
	"Villager Merchant",
	"Villager Civic"
) var appearance_profile: int = AppearanceProfile.AUTO
@export_range(-1, 7, 1) var appearance_variant: int = -1
@export var enable_role_accessories: bool = true
@export_range(0.88, 1.04, 0.01) var head_proportion: float = 0.95

var _movement_body: CharacterBody3D
var _animation_player: AnimationPlayer
var _current_animation: StringName = &""
var _resolved_profile: int = AppearanceProfile.AUTO
var _resolved_variant: int = 0
var _conversation_active: bool = false
var _conversation_speaking: bool = false
var _conversation_line_index: int = 0
var _conversation_gesture: String = "listen"
var _appearance_configured: bool = false
var _resolved_head_scale: float = 1.0

static var _tint_shader: Shader


func _ready() -> void:
	if not movement_body_path.is_empty():
		_movement_body = get_node_or_null(movement_body_path) as CharacterBody3D
	_configure_appearance()
	_animation_player = _find_animation_player($CharacterModel)
	if _animation_player != null:
		_animation_player.animation_finished.connect(_on_animation_finished)
	_play_animation(&"Idle")
	if idle_only or _movement_body == null:
		set_process(false)


func _process(_delta: float) -> void:
	if _conversation_active:
		_play_animation(_conversation_animation())
		return
	var horizontal_speed := Vector2(_movement_body.velocity.x, _movement_body.velocity.z).length()
	if horizontal_speed < 0.15:
		_play_animation(&"Idle")
	elif horizontal_speed >= run_speed_threshold:
		_play_animation(&"Run")
	else:
		_play_animation(&"Walk")


## Camera/dialogue systems can call this without knowing which generated model is
## in use. Extra imported idle clips are preferred; models without them safely
## remain on their normal Idle animation.
func set_conversation_state(
	speaking: bool, line_index: int = 0, gesture_state: String = "talk_explain"
) -> void:
	_conversation_active = true
	_conversation_speaking = speaking
	_conversation_line_index = maxi(line_index, 0)
	_conversation_gesture = gesture_state if speaking else "listen"
	_current_animation = &""
	_play_animation(_conversation_animation())


func clear_conversation_state() -> void:
	_conversation_active = false
	_conversation_speaking = false
	_conversation_line_index = 0
	_conversation_gesture = "listen"
	_current_animation = &""
	_play_animation(&"Idle")


func get_appearance_profile_name() -> String:
	if _resolved_profile >= 0 and _resolved_profile < PROFILE_LABELS.size():
		return PROFILE_LABELS[_resolved_profile]
	return "unknown"


func _conversation_animation() -> StringName:
	if _animation_player == null:
		return &"Idle"
	if _conversation_speaking:
		if (_conversation_gesture == "talk_emphasis" or _conversation_line_index % 2 == 1) and _animation_player.has_animation(&"Idle_002"):
			return &"Idle_002"
		if _animation_player.has_animation(&"Idle_001"):
			return &"Idle_001"
	elif _animation_player.has_animation(&"Idle_002"):
		return &"Idle_002"
	return &"Idle"


func _configure_appearance() -> void:
	if _appearance_configured or not has_node("CharacterModel"):
		return
	_appearance_configured = true
	_resolved_profile = _resolve_profile()
	_resolved_variant = _resolve_variant()
	var palette := _palette_for(_resolved_profile, _resolved_variant)
	_resolved_head_scale = float(palette["head_scale"])
	var model := $CharacterModel as Node3D
	model.scale = model.scale * (palette["body_scale"] as Vector3)
	_restyle_meshes(model, palette)
	_refine_head(model, palette)
	if enable_role_accessories:
		_add_role_details(model, palette)


func _resolve_profile() -> int:
	if appearance_profile != AppearanceProfile.AUTO:
		return appearance_profile
	var host := get_parent()
	var host_profile := _read_int_property(host, "appearance_profile", AppearanceProfile.AUTO)
	if host_profile != AppearanceProfile.AUTO:
		return host_profile
	var context := _context_name()
	if "alexander" in context:
		return AppearanceProfile.ALEXANDER
	if "officer" in context:
		return AppearanceProfile.MACEDONIAN_OFFICER
	if "macedon" in context or "patrol" in context or "supplyrunner" in context:
		return AppearanceProfile.MACEDONIAN_SOLDIER
	if "spartatrainer" in context:
		return AppearanceProfile.SPARTAN_TRAINER
	if "trainee" in context or "sparta" in context:
		return AppearanceProfile.SPARTAN_HOPLITE
	if "athenscitizen" in context or "debater" in context or "civicwalker" in context:
		return AppearanceProfile.ATHENIAN_CITIZEN
	if "marketvendor" in context:
		return AppearanceProfile.VILLAGER_MERCHANT
	if "harborwalker" in context or "upperpathwalker" in context:
		return AppearanceProfile.VILLAGER_YOUTH
	if "squarevillager" in context:
		return AppearanceProfile.VILLAGER_CIVIC
	if "player" in context or "messenger" in context:
		return AppearanceProfile.PLAYER_MESSENGER
	if "teacher" in context or "testnpc" in context:
		return AppearanceProfile.TEACHER_ELDER
	if "temple" in context or "recipient" in context:
		return AppearanceProfile.TEMPLE_ATTENDANT
	return AppearanceProfile.VILLAGER_CIVIC


func _resolve_variant() -> int:
	if appearance_variant >= 0:
		return appearance_variant
	var host := get_parent()
	var host_variant := _read_int_property(host, "appearance_variant", -1)
	if host_variant >= 0:
		return host_variant
	return absi(_context_name().hash()) % 4


func _read_int_property(object: Object, property_name: String, fallback: int) -> int:
	if object == null:
		return fallback
	for property in object.get_property_list():
		if str(property.get("name", "")) == property_name:
			return int(object.get(property_name))
	return fallback


func _context_name() -> String:
	var names: PackedStringArray = []
	var cursor: Node = self
	var depth := 0
	while cursor != null and depth < 7:
		names.append(str(cursor.name).to_lower())
		cursor = cursor.get_parent()
		depth += 1
	return " ".join(names)


func _palette_for(profile: int, variant: int) -> Dictionary:
	var palette := {
		"primary": Color("7c694e"),
		"secondary": Color("d8c79f"),
		"accent": Color("a9773e"),
		"skin": Color("c98c68"),
		"hair": Color("30241e"),
		"leather": Color("4a3021"),
		"metal": Color("a97b3d"),
		"body_scale": Vector3.ONE,
		"head_scale": head_proportion,
	}
	match profile:
		AppearanceProfile.PLAYER_MESSENGER:
			palette.merge({
				"primary": Color("345f86"), "secondary": Color("d9c89e"),
				"accent": Color("bc8747"), "skin": Color("cb8e68"),
				"hair": Color("2a211d"), "leather": Color("4b3020"),
				"body_scale": Vector3(0.96, 1.025, 0.96), "head_scale": 0.94,
			}, true)
		AppearanceProfile.TEACHER_ELDER:
			palette.merge({
				"primary": Color("815044"), "secondary": Color("d2bd91"),
				"accent": Color("9b7041"), "skin": Color("bc8062"),
				"hair": Color("aaa59b"), "leather": Color("493025"),
				"body_scale": Vector3(0.94, 1.035, 0.96), "head_scale": 0.95,
			}, true)
		AppearanceProfile.TEMPLE_ATTENDANT:
			palette.merge({
				"primary": Color("e0d4b9"), "secondary": Color("55786a"),
				"accent": Color("c2a35a"), "skin": Color("d4a07c"),
				"hair": Color("372923"), "leather": Color("63452f"),
				"body_scale": Vector3(0.96, 1.015, 0.96), "head_scale": 0.94,
			}, true)
		AppearanceProfile.ATHENIAN_CITIZEN:
			palette.merge({
				"primary": Color("ded1b3"), "secondary": Color("557797"),
				"accent": Color("b68b4d"), "skin": Color("c9906d"),
				"hair": Color("3a2920"), "leather": Color("66432b"),
				"body_scale": Vector3(0.95, 1.01, 0.96), "head_scale": 0.94,
			}, true)
		AppearanceProfile.ATHENIAN_ELDER:
			palette.merge({
				"primary": Color("a87951"), "secondary": Color("dfcfaa"),
				"accent": Color("5c7890"), "skin": Color("bf8264"),
				"hair": Color("918b82"), "leather": Color("563a29"),
				"body_scale": Vector3(0.94, 1.025, 0.96), "head_scale": 0.95,
			}, true)
		AppearanceProfile.SPARTAN_TRAINER:
			palette.merge({
				"primary": Color("68352f"), "secondary": Color("8f352f"),
				"accent": Color("bd843f"), "skin": Color("b87858"),
				"hair": Color("44362f"), "leather": Color("38251e"),
				"metal": Color("a86e32"), "body_scale": Vector3(1.01, 1.035, 1.01),
				"head_scale": 0.93,
			}, true)
		AppearanceProfile.SPARTAN_HOPLITE:
			palette.merge({
				"primary": Color("733730"), "secondary": Color("a44336"),
				"accent": Color("b77936"), "skin": Color("b97a58"),
				"hair": Color("30251f"), "leather": Color("33241e"),
				"metal": Color("a97535"), "body_scale": Vector3(1.025, 1.025, 1.025),
				"head_scale": 0.92,
			}, true)
		AppearanceProfile.MACEDONIAN_OFFICER:
			palette.merge({
				"primary": Color("314b67"), "secondary": Color("7f3835"),
				"accent": Color("c09349"), "skin": Color("c48765"),
				"hair": Color("4b382d"), "leather": Color("443026"),
				"metal": Color("b1813e"), "body_scale": Vector3(1.0, 1.035, 1.0),
				"head_scale": 0.93,
			}, true)
		AppearanceProfile.ALEXANDER:
			palette.merge({
				"primary": Color("d8ccb0"), "secondary": Color("59416f"),
				"accent": Color("d0a04d"), "skin": Color("d29a73"),
				"hair": Color("5a3827"), "leather": Color("543828"),
				"metal": Color("bd8c40"), "body_scale": Vector3(1.015, 1.03, 1.015),
				"head_scale": 0.93,
			}, true)
		AppearanceProfile.MACEDONIAN_SOLDIER:
			palette.merge({
				"primary": Color("3d5063"), "secondary": Color("88463b"),
				"accent": Color("b88643"), "skin": Color("bd805e"),
				"hair": Color("38291f"), "leather": Color("3d2b22"),
				"metal": Color("a97839"), "body_scale": Vector3(1.01, 1.02, 1.01),
				"head_scale": 0.93,
			}, true)
		AppearanceProfile.VILLAGER_YOUTH:
			palette.merge({
				"primary": Color("5d7890"), "secondary": Color("bb8754"),
				"accent": Color("d1b777"), "skin": Color("c68a67"),
				"hair": Color("34261e"), "body_scale": Vector3(0.95, 1.0, 0.96),
				"head_scale": 0.95,
			}, true)
		AppearanceProfile.VILLAGER_MERCHANT:
			palette.merge({
				"primary": Color("8b6040"), "secondary": Color("c4aa76"),
				"accent": Color("536e64"), "skin": Color("b97958"),
				"hair": Color("5e5043"), "body_scale": Vector3(0.97, 1.015, 0.98),
				"head_scale": 0.95,
			}, true)
		AppearanceProfile.VILLAGER_CIVIC:
			palette.merge({
				"primary": Color("cbbd9f"), "secondary": Color("687b62"),
				"accent": Color("9d7443"), "skin": Color("d19a75"),
				"hair": Color("442f26"), "body_scale": Vector3(0.96, 1.0, 0.97),
				"head_scale": 0.95,
			}, true)

	_apply_variant(palette, profile, variant)
	return palette


func _apply_variant(palette: Dictionary, profile: int, variant: int) -> void:
	var tone_steps: Array[float] = [0.0, -0.055, 0.045, -0.025]
	var tone_step: float = tone_steps[variant % tone_steps.size()]
	if tone_step < 0.0:
		palette["primary"] = (palette["primary"] as Color).darkened(-tone_step)
		palette["secondary"] = (palette["secondary"] as Color).darkened(-tone_step * 0.55)
	else:
		palette["primary"] = (palette["primary"] as Color).lightened(tone_step)
		palette["secondary"] = (palette["secondary"] as Color).lightened(tone_step * 0.55)
	var skin_tones: Array[Color] = [Color("d19a75"), Color("bd805f"), Color("ca8c68"), Color("ad704f")]
	if profile not in [AppearanceProfile.TEACHER_ELDER, AppearanceProfile.ATHENIAN_ELDER]:
		palette["skin"] = skin_tones[variant % skin_tones.size()]
	if profile not in [AppearanceProfile.TEACHER_ELDER, AppearanceProfile.ATHENIAN_ELDER]:
		var hair_tones: Array[Color] = [Color("2d231e"), Color("493226"), Color("5a3b29"), Color("211d1b")]
		palette["hair"] = hair_tones[variant % hair_tones.size()]


func _restyle_meshes(node: Node, palette: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface_index in mesh_instance.mesh.get_surface_count():
				var original := mesh_instance.get_active_material(surface_index)
				if original == null:
					continue
				var material_name := original.resource_name.to_lower()
				var mesh_name := str(mesh_instance.name).to_lower()
				if "eye" in material_name or "eye" in mesh_name:
					continue
				var tint: Color
				var roughness := 0.86
				var metallic := 0.0
				if "skin" in material_name:
					tint = palette["skin"]
					roughness = 0.82
				elif "hair" in material_name or "hair" in mesh_name or "beard" in mesh_name:
					tint = palette["hair"]
					roughness = 0.88
				elif "leather" in material_name or "belt" in mesh_name or "sandal" in mesh_name:
					tint = palette["leather"]
					roughness = 0.78
				elif "bronze" in material_name or "clasp" in mesh_name:
					tint = palette["metal"]
					roughness = 0.42
					metallic = 0.45
				elif "fabric" in material_name:
					if _is_secondary_cloth(mesh_name):
						tint = palette["secondary"]
					elif "hem" in mesh_name:
						tint = palette["accent"]
					else:
						tint = palette["primary"]
				else:
					continue
				mesh_instance.set_surface_override_material(
					surface_index, _make_tinted_material(original, tint, roughness, metallic)
				)
	for child in node.get_children():
		_restyle_meshes(child, palette)


func _is_secondary_cloth(mesh_name: String) -> bool:
	return (
		"cloak" in mesh_name
		or "himation" in mesh_name
		or "sash" in mesh_name
		or "drape" in mesh_name
		or "creamrobe" in mesh_name
	)


func _make_tinted_material(
	original: Material, tint: Color, roughness: float, metallic: float
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_name = "role_tint_%s" % original.resource_name
	material.shader = _get_tint_shader()
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("surface_roughness", roughness)
	material.set_shader_parameter("surface_metallic", metallic)
	var pattern: Texture2D
	var normal_map: Texture2D
	var roughness_map: Texture2D
	var metallic_map: Texture2D
	var ao_map: Texture2D
	var normal_strength := 1.0
	var roughness_channel := Vector4(1.0, 0.0, 0.0, 0.0)
	var metallic_channel := Vector4(1.0, 0.0, 0.0, 0.0)
	var ao_channel := Vector4(1.0, 0.0, 0.0, 0.0)
	if original is StandardMaterial3D:
		var source := original as StandardMaterial3D
		pattern = source.albedo_texture
		if source.normal_enabled:
			normal_map = source.normal_texture
			normal_strength = source.normal_scale
		roughness_map = source.roughness_texture
		metallic_map = source.metallic_texture
		if source.ao_enabled:
			ao_map = source.ao_texture
		roughness_channel = _texture_channel_mask(int(source.roughness_texture_channel))
		metallic_channel = _texture_channel_mask(int(source.metallic_texture_channel))
		ao_channel = _texture_channel_mask(int(source.ao_texture_channel))
	material.set_shader_parameter("has_pattern", pattern != null)
	if pattern != null:
		material.set_shader_parameter("pattern_texture", pattern)
	material.set_shader_parameter("has_normal_map", normal_map != null)
	if normal_map != null:
		material.set_shader_parameter("normal_texture", normal_map)
		material.set_shader_parameter("normal_strength", normal_strength)
	material.set_shader_parameter("has_roughness_map", roughness_map != null)
	if roughness_map != null:
		material.set_shader_parameter("roughness_texture", roughness_map)
		material.set_shader_parameter("roughness_channel", roughness_channel)
	material.set_shader_parameter("has_metallic_map", metallic_map != null)
	if metallic_map != null:
		material.set_shader_parameter("metallic_texture", metallic_map)
		material.set_shader_parameter("metallic_channel", metallic_channel)
	material.set_shader_parameter("has_ao_map", ao_map != null)
	if ao_map != null:
		material.set_shader_parameter("ao_texture", ao_map)
		material.set_shader_parameter("ao_channel", ao_channel)
	return material


func _texture_channel_mask(channel: int) -> Vector4:
	match channel:
		BaseMaterial3D.TEXTURE_CHANNEL_GREEN:
			return Vector4(0.0, 1.0, 0.0, 0.0)
		BaseMaterial3D.TEXTURE_CHANNEL_BLUE:
			return Vector4(0.0, 0.0, 1.0, 0.0)
		BaseMaterial3D.TEXTURE_CHANNEL_ALPHA:
			return Vector4(0.0, 0.0, 0.0, 1.0)
		BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE:
			return Vector4(0.299, 0.587, 0.114, 0.0)
		_:
			return Vector4(1.0, 0.0, 0.0, 0.0)


func _get_tint_shader() -> Shader:
	if _tint_shader == null:
		_tint_shader = Shader.new()
		_tint_shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D pattern_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_pattern = false;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_normal_map = false;
uniform float normal_strength : hint_range(0.0, 4.0) = 1.0;
uniform sampler2D roughness_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_roughness_map = false;
uniform vec4 roughness_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D metallic_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_metallic_map = false;
uniform vec4 metallic_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D ao_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_ao_map = false;
uniform vec4 ao_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec4 tint : source_color = vec4(1.0);
uniform float surface_roughness : hint_range(0.0, 1.0) = 0.85;
uniform float surface_metallic : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float detail = 1.0;
	if (has_pattern) {
		vec3 sample_color = texture(pattern_texture, UV).rgb;
		float value = dot(sample_color, vec3(0.299, 0.587, 0.114));
		detail = mix(0.78, 1.12, smoothstep(0.05, 0.82, value));
	}
	ALBEDO = tint.rgb * detail;
	float mapped_roughness = 1.0;
	if (has_roughness_map) {
		mapped_roughness = dot(texture(roughness_texture, UV), roughness_channel);
	}
	ROUGHNESS = clamp(surface_roughness * mix(0.82, 1.12, mapped_roughness), 0.05, 1.0);
	float mapped_metallic = 1.0;
	if (has_metallic_map) {
		mapped_metallic = dot(texture(metallic_texture, UV), metallic_channel);
	}
	METALLIC = clamp(surface_metallic * mapped_metallic, 0.0, 1.0);
	if (has_normal_map) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = normal_strength;
	}
	if (has_ao_map) {
		AO = dot(texture(ao_texture, UV), ao_channel);
		AO_LIGHT_AFFECT = 0.72;
	}
}
"""
	return _tint_shader


func _refine_head(model: Node, palette: Dictionary) -> void:
	var head_attachment := _find_descendant(model, "Head_2") as Node3D
	if head_attachment == null:
		return
	var proportion := float(palette["head_scale"])
	var face_pivot := Vector3(0.0, 0.11, 0.0)
	for child in head_attachment.get_children():
		if child is MeshInstance3D:
			var part := child as MeshInstance3D
			part.position = face_pivot + (part.position - face_pivot) * proportion
			part.scale *= proportion
	var hair := head_attachment.get_node_or_null("Hair") as MeshInstance3D
	if hair != null:
		match _resolved_profile:
			AppearanceProfile.SPARTAN_HOPLITE, AppearanceProfile.MACEDONIAN_SOLDIER:
				hair.scale.y *= 0.72 + 0.06 * float(_resolved_variant % 3)
				hair.position.y -= 0.018
			AppearanceProfile.PLAYER_MESSENGER, AppearanceProfile.VILLAGER_YOUTH:
				hair.scale.x *= 0.94
				hair.scale.y *= 0.88
	_add_face_details(head_attachment, palette)


func _add_face_details(head: Node3D, palette: Dictionary) -> void:
	var hair_material := _solid_material(palette["hair"], 0.9)
	var mouth_material := _solid_material(Color("5b3028"), 0.92)
	var brow_slant := 0.05 + float(_resolved_variant % 3) * 0.025
	_add_head_box(head, "BrowL", Vector3(0.072, 0.015, 0.018), Vector3(-0.06, 0.185, 0.169), Vector3(0.0, 0.0, -brow_slant), hair_material)
	_add_head_box(head, "BrowR", Vector3(0.072, 0.015, 0.018), Vector3(0.06, 0.185, 0.169), Vector3(0.0, 0.0, brow_slant), hair_material)
	_add_head_box(head, "Mouth", Vector3(0.07, 0.012, 0.012), Vector3(0.0, 0.015, 0.166), Vector3.ZERO, mouth_material)
	if _resolved_profile in [AppearanceProfile.TEACHER_ELDER, AppearanceProfile.ATHENIAN_ELDER]:
		var age_material := _solid_material((palette["skin"] as Color).darkened(0.22), 0.94)
		_add_head_box(head, "AgeLineL", Vector3(0.038, 0.007, 0.009), Vector3(-0.105, 0.118, 0.158), Vector3(0.0, 0.0, -0.12), age_material)
		_add_head_box(head, "AgeLineR", Vector3(0.038, 0.007, 0.009), Vector3(0.105, 0.118, 0.158), Vector3(0.0, 0.0, 0.12), age_material)
	elif _resolved_profile == AppearanceProfile.SPARTAN_HOPLITE and _resolved_variant % 2 == 1:
		_add_short_beard(head, palette["hair"])
	elif _resolved_profile == AppearanceProfile.MACEDONIAN_SOLDIER and _resolved_variant % 3 == 2:
		_add_short_beard(head, palette["hair"])


func _add_role_details(model: Node, palette: Dictionary) -> void:
	var head := _find_descendant(model, "Head_2") as Node3D
	var spine := _find_descendant(model, "Spine") as Node3D
	var hips := _find_descendant(model, "Hips") as Node3D
	var military_profile := _resolved_profile in [
		AppearanceProfile.SPARTAN_TRAINER,
		AppearanceProfile.SPARTAN_HOPLITE,
		AppearanceProfile.MACEDONIAN_OFFICER,
		AppearanceProfile.ALEXANDER,
		AppearanceProfile.MACEDONIAN_SOLDIER,
	]
	if not military_profile:
		_add_civilian_garment_finish(spine, hips, palette)
	match _resolved_profile:
		AppearanceProfile.PLAYER_MESSENGER:
			_add_messenger_kit(spine, hips, palette)
			_add_shouldered_clasp(spine, palette, -1.0, "MessengerShoulderClasp")
		AppearanceProfile.TEACHER_ELDER:
			_add_scroll(hips, palette)
			_add_scholar_finish(spine, palette)
		AppearanceProfile.TEMPLE_ATTENDANT:
			_add_headband(head, palette["metal"], false)
			_add_pendant(spine, palette)
			_add_temple_finish(spine, palette)
		AppearanceProfile.ATHENIAN_CITIZEN:
			_add_headband(head, palette["accent"], false)
			_add_civic_brooch(spine, palette)
			_add_civic_chain(spine, palette)
		AppearanceProfile.ATHENIAN_ELDER:
			_add_headband(head, palette["accent"], false)
			_add_scroll(hips, palette)
			_add_scholar_finish(spine, palette)
		AppearanceProfile.SPARTAN_TRAINER:
			_add_military_kit(spine, hips, palette, true)
			_add_command_clasp(spine, palette, false)
		AppearanceProfile.SPARTAN_HOPLITE:
			_add_military_kit(spine, hips, palette, _resolved_variant % 2 == 0)
			if _resolved_variant % 3 != 2:
				_add_helmet(head, palette, false)
		AppearanceProfile.MACEDONIAN_OFFICER:
			_add_military_kit(spine, hips, palette, true)
			_add_headband(head, palette["metal"], false)
			_add_command_clasp(spine, palette, false)
		AppearanceProfile.ALEXANDER:
			_add_military_kit(spine, hips, palette, false)
			_add_headband(head, palette["metal"], true)
			_add_civic_brooch(spine, palette)
			_add_command_clasp(spine, palette, true)
		AppearanceProfile.MACEDONIAN_SOLDIER:
			_add_military_kit(spine, hips, palette, _resolved_variant == 0)
			if _resolved_variant % 2 == 0:
				_add_helmet(head, palette, true)
		AppearanceProfile.VILLAGER_YOUTH:
			_add_belt_pouch(hips, palette, 1.0)
			_add_shouldered_clasp(spine, palette, 1.0, "YouthShoulderToggle")
		AppearanceProfile.VILLAGER_MERCHANT:
			_add_messenger_kit(spine, hips, palette)
			_add_scroll(hips, palette)
			_add_merchant_finish(hips, palette)
		AppearanceProfile.VILLAGER_CIVIC:
			_add_civic_brooch(spine, palette)
			_add_civic_chain(spine, palette)


## A restrained set of finishing pieces gives every unarmoured profile a clean,
## tailored silhouette. They are attached to animated bones rather than placed in
## world space, so the neckline and belt stay registered in every animation.
func _add_civilian_garment_finish(spine: Node3D, hips: Node3D, palette: Dictionary) -> void:
	if spine == null or hips == null:
		return
	var trim_color := (palette["accent"] as Color).lightened(0.08)
	var trim := _solid_material(trim_color, 0.74)
	var belt := _solid_material(palette["leather"], 0.8)
	var metal := _solid_material(palette["metal"], 0.43, 0.38)
	_add_box(spine, "NeckTrimL", Vector3(0.034, 0.17, 0.018), Vector3(-0.055, 0.455, 0.211), Vector3(0.0, 0.0, -0.48), trim)
	_add_box(spine, "NeckTrimR", Vector3(0.034, 0.17, 0.018), Vector3(0.055, 0.455, 0.211), Vector3(0.0, 0.0, 0.48), trim)
	_add_box(hips, "TailoredWaistBand", Vector3(0.50, 0.045, 0.026), Vector3(0.0, 0.22, 0.211), Vector3.ZERO, belt)
	_add_cylinder(hips, "WaistBuckle", 0.037, 0.022, Vector3(0.0, 0.22, 0.233), Vector3(PI * 0.5, 0.0, 0.0), metal, 10)


func _add_shouldered_clasp(
	spine: Node3D, palette: Dictionary, side: float, node_name: String
) -> void:
	if spine == null:
		return
	var metal := _solid_material(palette["metal"], 0.4, 0.44)
	_add_cylinder(spine, node_name, 0.047, 0.025, Vector3(0.235 * side, 0.405, 0.218), Vector3(PI * 0.5, 0.0, 0.0), metal, 12)


func _add_scholar_finish(spine: Node3D, palette: Dictionary) -> void:
	if spine == null:
		return
	var border := _solid_material((palette["accent"] as Color).lightened(0.12), 0.76)
	_add_box(spine, "ScholarMantleBorder", Vector3(0.035, 0.48, 0.022), Vector3(-0.205, 0.16, 0.218), Vector3(0.0, 0.0, -0.055), border)
	_add_shouldered_clasp(spine, palette, -1.0, "ScholarClasp")


func _add_temple_finish(spine: Node3D, palette: Dictionary) -> void:
	if spine == null:
		return
	var metal := _solid_material(palette["metal"], 0.42, 0.42)
	_add_cylinder(spine, "TempleShoulderPinL", 0.036, 0.022, Vector3(-0.225, 0.405, 0.216), Vector3(PI * 0.5, 0.0, 0.0), metal, 10)
	_add_cylinder(spine, "TempleShoulderPinR", 0.036, 0.022, Vector3(0.225, 0.405, 0.216), Vector3(PI * 0.5, 0.0, 0.0), metal, 10)
	_add_torus(spine, "TempleCollar", 0.135, 0.154, Vector3(0.0, 0.485, 0.0), Vector3.ZERO, metal)


func _add_civic_chain(spine: Node3D, palette: Dictionary) -> void:
	if spine == null:
		return
	var metal := _solid_material(palette["metal"], 0.43, 0.38)
	_add_box(spine, "CivicMantleChain", Vector3(0.18, 0.014, 0.014), Vector3(-0.125, 0.395, 0.22), Vector3(0.0, 0.0, 0.08), metal)


func _add_merchant_finish(hips: Node3D, palette: Dictionary) -> void:
	if hips == null:
		return
	var metal := _solid_material(palette["metal"], 0.44, 0.36)
	var side := 1.0 if _resolved_variant % 2 == 0 else -1.0
	_add_cylinder(hips, "MerchantSeal", 0.035, 0.018, Vector3(0.12 * side, 0.12, 0.23), Vector3(PI * 0.5, 0.0, 0.0), metal, 10)


func _add_messenger_kit(spine: Node3D, hips: Node3D, palette: Dictionary) -> void:
	if spine != null:
		var strap_material := _solid_material(palette["leather"], 0.8)
		var strap_inlay := _solid_material((palette["accent"] as Color).lightened(0.1), 0.74)
		var strap_angle := -0.48 if _resolved_variant % 2 == 0 else 0.48
		_add_box(spine, "MessengerStrap", Vector3(0.045, 0.68, 0.024), Vector3(0.0, 0.21, 0.205), Vector3(0.0, 0.0, strap_angle), strap_material)
		_add_box(spine, "MessengerStrapInlay", Vector3(0.014, 0.64, 0.009), Vector3(0.0, 0.21, 0.223), Vector3(0.0, 0.0, strap_angle), strap_inlay)
	_add_belt_pouch(hips, palette, -1.0 if _resolved_variant % 2 == 0 else 1.0)


func _add_belt_pouch(hips: Node3D, palette: Dictionary, side: float) -> void:
	if hips == null:
		return
	var leather := _solid_material(palette["leather"], 0.82)
	var metal := _solid_material(palette["metal"], 0.48, 0.35)
	_add_box(hips, "BeltPouch", Vector3(0.18, 0.21, 0.09), Vector3(0.29 * side, 0.02, 0.16), Vector3(0.0, 0.0, -0.05 * side), leather)
	_add_box(hips, "PouchFlap", Vector3(0.185, 0.065, 0.025), Vector3(0.29 * side, 0.075, 0.213), Vector3(0.0, 0.0, -0.05 * side), leather)
	_add_box(hips, "PouchClasp", Vector3(0.045, 0.045, 0.014), Vector3(0.29 * side, 0.055, 0.212), Vector3.ZERO, metal)


func _add_scroll(hips: Node3D, palette: Dictionary) -> void:
	if hips == null:
		return
	var papyrus := _solid_material(Color("d8c799"), 0.94)
	var tie := _solid_material(palette["leather"], 0.83)
	var side := -1.0 if _resolved_variant % 2 == 0 else 1.0
	_add_cylinder(hips, "ScholarScroll", 0.043, 0.28, Vector3(0.28 * side, 0.015, 0.215), Vector3.ZERO, papyrus, 10)
	_add_torus(hips, "ScrollTieTop", 0.038, 0.049, Vector3(0.28 * side, 0.105, 0.215), Vector3.ZERO, tie)
	_add_torus(hips, "ScrollTieBottom", 0.038, 0.049, Vector3(0.28 * side, -0.075, 0.215), Vector3.ZERO, tie)


func _add_pendant(spine: Node3D, palette: Dictionary) -> void:
	if spine == null:
		return
	var cord := _solid_material(palette["leather"], 0.84)
	var metal := _solid_material(palette["metal"], 0.42, 0.45)
	_add_box(spine, "PendantCordL", Vector3(0.018, 0.28, 0.014), Vector3(-0.052, 0.35, 0.205), Vector3(0.0, 0.0, -0.26), cord)
	_add_box(spine, "PendantCordR", Vector3(0.018, 0.28, 0.014), Vector3(0.052, 0.35, 0.205), Vector3(0.0, 0.0, 0.26), cord)
	_add_cylinder(spine, "TempleMedallion", 0.055, 0.025, Vector3(0.0, 0.225, 0.222), Vector3(PI * 0.5, 0.0, 0.0), metal, 12)


func _add_civic_brooch(spine: Node3D, palette: Dictionary) -> void:
	if spine == null:
		return
	var metal := _solid_material(palette["metal"], 0.42, 0.42)
	_add_cylinder(spine, "CivicBrooch", 0.052, 0.026, Vector3(-0.235, 0.41, 0.205), Vector3(PI * 0.5, 0.0, 0.0), metal, 12)


func _add_military_kit(spine: Node3D, hips: Node3D, palette: Dictionary, with_shield: bool) -> void:
	if spine == null or hips == null:
		return
	var bronze := _solid_material(palette["metal"], 0.43, 0.48)
	var dark_bronze := _solid_material((palette["metal"] as Color).darkened(0.23), 0.49, 0.38)
	var relief_bronze := _solid_material((palette["metal"] as Color).darkened(0.08), 0.46, 0.43)
	var leather := _solid_material(palette["leather"], 0.8)
	var shield_color := _solid_material(palette["secondary"], 0.68)
	_add_box(spine, "CuirassPlate", Vector3(0.54, 0.36, 0.052), Vector3(0.0, 0.27, 0.213), Vector3(-0.035, 0.0, 0.0), dark_bronze)
	_add_box(spine, "CuirassTopTrim", Vector3(0.57, 0.035, 0.068), Vector3(0.0, 0.445, 0.214), Vector3.ZERO, bronze)
	_add_box(spine, "CuirassCollar", Vector3(0.34, 0.048, 0.073), Vector3(0.0, 0.475, 0.204), Vector3.ZERO, bronze)
	_add_box(spine, "CuirassLowerTrim", Vector3(0.55, 0.037, 0.07), Vector3(0.0, 0.092, 0.222), Vector3.ZERO, bronze)
	_add_box(spine, "CuirassCenterRidge", Vector3(0.028, 0.31, 0.072), Vector3(0.0, 0.27, 0.223), Vector3.ZERO, bronze)
	_add_box(spine, "CuirassPanelL", Vector3(0.17, 0.06, 0.016), Vector3(-0.13, 0.33, 0.249), Vector3(0.0, 0.0, -0.075), relief_bronze)
	_add_box(spine, "CuirassPanelR", Vector3(0.17, 0.06, 0.016), Vector3(0.13, 0.33, 0.249), Vector3(0.0, 0.0, 0.075), relief_bronze)
	_add_box(spine, "CuirassAbdomenBand", Vector3(0.41, 0.04, 0.018), Vector3(0.0, 0.19, 0.251), Vector3.ZERO, bronze)
	_add_sphere(spine, "PauldronL", 0.145, 0.15, Vector3(-0.31, 0.39, 0.03), Vector3(0.0, 0.0, 0.18), bronze, Vector3(1.0, 0.72, 0.72))
	_add_sphere(spine, "PauldronR", 0.145, 0.15, Vector3(0.31, 0.39, 0.03), Vector3(0.0, 0.0, -0.18), bronze, Vector3(1.0, 0.72, 0.72))
	_add_box(hips, "CuirassWaistBelt", Vector3(0.55, 0.058, 0.038), Vector3(0.0, 0.22, 0.214), Vector3.ZERO, dark_bronze)
	_add_cylinder(hips, "CuirassWaistSeal", 0.043, 0.022, Vector3(0.0, 0.22, 0.244), Vector3(PI * 0.5, 0.0, 0.0), bronze, 10)
	for strip_index in 5:
		var x := (float(strip_index) - 2.0) * 0.105
		_add_box(hips, "Pteryx%02d" % strip_index, Vector3(0.072, 0.29, 0.035), Vector3(x, -0.04, 0.225), Vector3(0.05, 0.0, x * 0.12), leather)
	if with_shield:
		_add_cylinder(spine, "ShieldRim", 0.37, 0.065, Vector3(0.0, 0.14, -0.285), Vector3(PI * 0.5, 0.0, 0.0), bronze, 18)
		_add_cylinder(spine, "ShieldFace", 0.31, 0.072, Vector3(0.0, 0.14, -0.292), Vector3(PI * 0.5, 0.0, 0.0), shield_color, 18)
		_add_cylinder(spine, "ShieldBoss", 0.09, 0.085, Vector3(0.0, 0.14, -0.345), Vector3(PI * 0.5, 0.0, 0.0), bronze, 14)


func _add_command_clasp(spine: Node3D, palette: Dictionary, royal: bool) -> void:
	if spine == null:
		return
	var metal_color := (palette["metal"] as Color).lightened(0.12 if royal else 0.05)
	var metal := _solid_material(metal_color, 0.37, 0.52)
	if royal:
		_add_cylinder(spine, "RoyalSunDisk", 0.07, 0.023, Vector3(0.0, 0.325, 0.274), Vector3(PI * 0.5, 0.0, 0.0), metal, 14)
		_add_box(spine, "RoyalSunRayHorizontal", Vector3(0.20, 0.018, 0.014), Vector3(0.0, 0.325, 0.288), Vector3.ZERO, metal)
		_add_box(spine, "RoyalSunRayVertical", Vector3(0.018, 0.20, 0.014), Vector3(0.0, 0.325, 0.288), Vector3.ZERO, metal)
	else:
		_add_cylinder(spine, "CommandMantleClasp", 0.055, 0.024, Vector3(-0.225, 0.415, 0.256), Vector3(PI * 0.5, 0.0, 0.0), metal, 12)
		_add_box(spine, "CommandRankBar", Vector3(0.15, 0.025, 0.014), Vector3(0.145, 0.39, 0.274), Vector3(0.0, 0.0, -0.12), metal)


func _add_headband(head: Node3D, color: Color, crowned: bool) -> void:
	if head == null:
		return
	var metal := _solid_material(color, 0.45, 0.38)
	_add_torus(head, "HeadFillet", 0.174 * _resolved_head_scale, 0.192 * _resolved_head_scale, _head_position(Vector3(0.0, 0.225, 0.0)), Vector3.ZERO, metal)
	if crowned:
		for leaf_index in 5:
			var x := (float(leaf_index) - 2.0) * 0.052
			_add_head_box(head, "DiademLeaf%02d" % leaf_index, Vector3(0.042, 0.022, 0.016), Vector3(x, 0.238 + absf(x) * 0.025, 0.16), Vector3(0.0, 0.0, -x * 1.2), metal)
		_add_cylinder(head, "DiademSeal", 0.028 * _resolved_head_scale, 0.014 * _resolved_head_scale, _head_position(Vector3(0.0, 0.235, 0.186)), Vector3(PI * 0.5, 0.0, 0.0), metal, 10)


func _add_helmet(head: Node3D, palette: Dictionary, macedonian: bool) -> void:
	if head == null:
		return
	var hair := head.get_node_or_null("Hair") as MeshInstance3D
	if hair != null:
		hair.visible = false
	var bronze := _solid_material(palette["metal"], 0.43, 0.46)
	var crest_color := _solid_material(palette["secondary"], 0.78)
	_add_sphere(head, "HelmetDome", 0.205 * _resolved_head_scale, 0.26 * _resolved_head_scale, _head_position(Vector3(0.0, 0.245, 0.0)), Vector3.ZERO, bronze, Vector3.ONE, true)
	_add_torus(head, "HelmetBrow", 0.183 * _resolved_head_scale, 0.205 * _resolved_head_scale, _head_position(Vector3(0.0, 0.18, 0.0)), Vector3.ZERO, bronze)
	_add_head_box(head, "HelmetNoseGuard", Vector3(0.043, 0.205, 0.035), Vector3(0.0, 0.09, 0.192), Vector3(-0.05, 0.0, 0.0), bronze)
	_add_head_box(head, "HelmetCheekL", Vector3(0.045, 0.20, 0.045), Vector3(-0.163, 0.06, 0.125), Vector3(0.0, 0.10, -0.13), bronze)
	_add_head_box(head, "HelmetCheekR", Vector3(0.045, 0.20, 0.045), Vector3(0.163, 0.06, 0.125), Vector3(0.0, -0.10, 0.13), bronze)
	var crest_height := 0.17 if macedonian else 0.205
	_add_head_box(head, "HelmetCrest", Vector3(0.055, crest_height, 0.29), Vector3(0.0, 0.42, -0.005), Vector3.ZERO, crest_color)


func _add_short_beard(head: Node3D, color: Color) -> void:
	var beard_material := _solid_material(color, 0.9)
	_add_sphere(head, "ShortBeard", 0.13 * _resolved_head_scale, 0.17 * _resolved_head_scale, _head_position(Vector3(0.0, -0.008, 0.153)), Vector3.ZERO, beard_material, Vector3(1.0, 1.0, 0.32))
	_add_head_box(head, "MoustacheL", Vector3(0.068, 0.025, 0.018), Vector3(-0.035, 0.055, 0.177), Vector3(0.0, 0.0, -0.14), beard_material)
	_add_head_box(head, "MoustacheR", Vector3(0.068, 0.025, 0.018), Vector3(0.035, 0.055, 0.177), Vector3(0.0, 0.0, 0.14), beard_material)


func _add_head_box(parent: Node3D, node_name: String, size: Vector3, position: Vector3, rotation: Vector3, material: Material) -> MeshInstance3D:
	return _add_box(
		parent,
		node_name,
		size * _resolved_head_scale,
		_head_position(position),
		rotation,
		material
	)


func _head_position(position: Vector3) -> Vector3:
	const FACE_PIVOT := Vector3(0.0, 0.11, 0.0)
	return FACE_PIVOT + (position - FACE_PIVOT) * _resolved_head_scale


func _solid_material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _add_box(parent: Node3D, node_name: String, size: Vector3, position: Vector3, rotation: Vector3, material: Material) -> MeshInstance3D:
	if parent == null:
		return null
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	return _add_mesh(parent, node_name, mesh, position, rotation, Vector3.ONE)


func _add_cylinder(parent: Node3D, node_name: String, radius: float, height: float, position: Vector3, rotation: Vector3, material: Material, segments: int) -> MeshInstance3D:
	if parent == null:
		return null
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	mesh.material = material
	return _add_mesh(parent, node_name, mesh, position, rotation, Vector3.ONE)


func _add_torus(parent: Node3D, node_name: String, inner_radius: float, outer_radius: float, position: Vector3, rotation: Vector3, material: Material) -> MeshInstance3D:
	if parent == null:
		return null
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 8
	mesh.ring_segments = 16
	mesh.material = material
	return _add_mesh(parent, node_name, mesh, position, rotation, Vector3.ONE)


func _add_sphere(parent: Node3D, node_name: String, radius: float, height: float, position: Vector3, rotation: Vector3, material: Material, scale: Vector3 = Vector3.ONE, hemisphere: bool = false) -> MeshInstance3D:
	if parent == null:
		return null
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 5
	mesh.is_hemisphere = hemisphere
	mesh.material = material
	return _add_mesh(parent, node_name, mesh, position, rotation, scale)


func _add_mesh(parent: Node3D, node_name: String, mesh: PrimitiveMesh, position: Vector3, rotation: Vector3, scale: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.rotation = rotation
	instance.scale = scale
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _find_descendant(node: Node, target_name: String) -> Node:
	if str(node.name) == target_name:
		return node
	for child in node.get_children():
		var found := _find_descendant(child, target_name)
		if found != null:
			return found
	return null


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _play_animation(animation_name: StringName) -> void:
	if _animation_player == null or animation_name == _current_animation:
		return
	if not _animation_player.has_animation(animation_name):
		return
	_current_animation = animation_name
	# A short blend hides pose pops without making starts, stops, or run changes
	# feel delayed relative to the responsive controller.
	_animation_player.play(animation_name, 0.08)


func _on_animation_finished(animation_name: StringName) -> void:
	# Blender action clips are finite on import; replay the active clip so idle and
	# locomotion never freeze on their final pose.
	if _animation_player != null and animation_name == _current_animation:
		_animation_player.play(_current_animation)
