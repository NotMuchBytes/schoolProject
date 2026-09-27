extends Node

## Lightweight Web quality controller. The 2D HUD always stays at native
## resolution; only the 3D render buffer is scaled when the browser is slow.

const INITIAL_SCALE := 0.65
const MIN_SCALE := 0.55
const MAX_SCALE := 0.75
const SAMPLE_SECONDS := 2.0
const ARABIC_FONT_PATH := "res://assets/fonts/NotoSansArabic-Regular.ttf"
const LATIN_GREEK_FONT_PATH := "res://assets/fonts/NotoSans-LatinGreek.ttf"
const WEB_CAMERA_FAR := 150.0

var _web_enabled := false
var _sample_elapsed := 0.0
var _warmup_elapsed := 0.0
var _arabic_font: Font
var _latin_greek_font: Font


func _ready() -> void:
	_install_multilingual_fonts()
	_web_enabled = OS.has_feature("web")
	if not _web_enabled:
		set_process(false)
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.max_fps = 60
	Engine.physics_ticks_per_second = 60
	get_tree().root.scaling_3d_scale = INITIAL_SCALE
	get_tree().node_added.connect(_optimize_node)
	call_deferred("_optimize_current_scene")


func _install_multilingual_fonts() -> void:
	# Use Godot's imported FontFile so the glyph data is embedded correctly in
	# WebAssembly builds. Keep a raw-file fallback for source checkouts that have
	# not generated an import cache yet.
	var imported_font := load(ARABIC_FONT_PATH)
	if imported_font is Font:
		_arabic_font = imported_font as Font
	else:
		var raw_font := FontFile.new()
		if raw_font.load_dynamic_font(ARABIC_FONT_PATH) == OK:
			_arabic_font = raw_font
	var imported_latin_greek := load(LATIN_GREEK_FONT_PATH)
	if imported_latin_greek is Font:
		_latin_greek_font = imported_latin_greek as Font
	else:
		var raw_latin_greek := FontFile.new()
		if raw_latin_greek.load_dynamic_font(LATIN_GREEK_FONT_PATH) == OK:
			_latin_greek_font = raw_latin_greek
	if _arabic_font != null:
		var engine_font := ThemeDB.get_default_theme().default_font
		var fallbacks: Array[Font] = []
		if _latin_greek_font != null:
			fallbacks.append(_latin_greek_font)
		if engine_font != null:
			fallbacks.append(engine_font)
		_arabic_font.set_fallbacks(fallbacks)
		ThemeDB.fallback_font = _arabic_font
		var project_theme := ThemeDB.get_project_theme()
		if project_theme != null:
			project_theme.default_font = _arabic_font
	else:
		push_error("Could not load the bundled Arabic font")
	if _latin_greek_font == null:
		push_error("Could not load the bundled Latin and Greek font")


func _process(delta: float) -> void:
	_warmup_elapsed += delta
	_sample_elapsed += delta
	if _warmup_elapsed < 3.0 or _sample_elapsed < SAMPLE_SECONDS:
		return
	_sample_elapsed = 0.0
	var viewport := get_tree().root
	var current_scale := viewport.scaling_3d_scale
	var fps := Engine.get_frames_per_second()
	if fps < 38.0 and current_scale > MIN_SCALE:
		viewport.scaling_3d_scale = maxf(MIN_SCALE, current_scale - 0.05)
	elif fps > 56.0 and current_scale < MAX_SCALE:
		viewport.scaling_3d_scale = minf(MAX_SCALE, current_scale + 0.03)


func _optimize_current_scene() -> void:
	var scene := get_tree().current_scene
	if scene != null:
		_optimize_branch(scene)


func _optimize_branch(node: Node) -> void:
	_optimize_node(node)
	for child in node.get_children():
		_optimize_branch(child)


func _optimize_node(node: Node) -> void:
	# The engine theme already supplies a Latin font, so its font takes priority
	# over ThemeDB.fallback_font. Override it on text nodes to guarantee Arabic
	# glyphs in every menu, HUD, dialogue, and 3D marker.
	if _arabic_font != null:
		if node is Control:
			(node as Control).add_theme_font_override("font", _arabic_font)
		elif node is Label3D:
			(node as Label3D).font = _arabic_font
	if not _web_enabled:
		return
	if node is DirectionalLight3D:
		var sun := node as DirectionalLight3D
		sun.shadow_enabled = true
		sun.light_energy = minf(sun.light_energy, 0.90)
		sun.shadow_opacity = minf(sun.shadow_opacity, 0.72)
	elif node is Light3D:
		(node as Light3D).shadow_enabled = false
	elif node is WorldEnvironment:
		_optimize_environment((node as WorldEnvironment).environment)
	elif node is GPUParticles3D:
		(node as GPUParticles3D).emitting = false
	elif node is Camera3D:
		(node as Camera3D).far = minf((node as Camera3D).far, WEB_CAMERA_FAR)


func _optimize_environment(environment: Environment) -> void:
	if environment == null:
		return
	environment.ssao_enabled = false
	environment.ssil_enabled = false
	environment.sdfgi_enabled = false
	environment.glow_enabled = false
	environment.volumetric_fog_enabled = false
	environment.background_energy_multiplier = minf(environment.background_energy_multiplier, 0.72)
	environment.ambient_light_energy = minf(environment.ambient_light_energy, 0.36)
	environment.tonemap_exposure = minf(environment.tonemap_exposure, 0.94)
	if environment.adjustment_enabled:
		environment.adjustment_brightness = minf(environment.adjustment_brightness, 0.96)
