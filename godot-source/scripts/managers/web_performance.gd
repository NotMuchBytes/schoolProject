extends Node

## Lightweight Web quality controller. The 2D HUD always stays at native
## resolution; only the 3D render buffer is scaled when the browser is slow.

const INITIAL_SCALE := 0.65
const MIN_SCALE := 0.55
const MAX_SCALE := 0.75
const SAMPLE_SECONDS := 2.0
const ARABIC_FONT_PATH := "res://assets/fonts/NotoSansArabic-Regular.ttf"
const WEB_CAMERA_FAR := 150.0

var _web_enabled := false
var _sample_elapsed := 0.0
var _warmup_elapsed := 0.0
var _arabic_font: Font


func _ready() -> void:
	_install_arabic_font()
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


func _install_arabic_font() -> void:
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
	if _arabic_font != null:
		var engine_font := ThemeDB.get_default_theme().default_font
		if engine_font != null:
			_arabic_font.set_fallbacks([engine_font])
		ThemeDB.fallback_font = _arabic_font
		var project_theme := ThemeDB.get_project_theme()
		if project_theme != null:
			project_theme.default_font = _arabic_font
	else:
		push_error("Could not load the bundled Arabic font")


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
	if node is Light3D:
		# Dynamic shadow maps are the largest GPU cost in these dense city scenes.
		(node as Light3D).shadow_enabled = false
	elif node is WorldEnvironment:
		_optimize_environment((node as WorldEnvironment).environment)
	elif node is GPUParticles3D:
		(node as GPUParticles3D).emitting = false
	elif node is Camera3D:
		(node as Camera3D).far = minf((node as Camera3D).far, WEB_CAMERA_FAR)
	elif node is GeometryInstance3D:
		_optimize_geometry(node as GeometryInstance3D)


func _optimize_geometry(geometry: GeometryInstance3D) -> void:
	geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	geometry.lod_bias = minf(geometry.lod_bias, 0.75)
	if geometry.visibility_range_end > 0.0 or not geometry is MeshInstance3D:
		return
	var mesh_instance := geometry as MeshInstance3D
	if mesh_instance.mesh == null:
		return
	var extent := mesh_instance.mesh.get_aabb().size * mesh_instance.scale.abs()
	var longest_side := maxf(extent.x, maxf(extent.y, extent.z))
	# Small props dominate draw-call count in the procedural cities. Culling them
	# earlier keeps nearby lesson landmarks intact while making WebGL much lighter.
	if longest_side <= 2.5:
		geometry.visibility_range_end = 48.0
	elif longest_side <= 10.0:
		geometry.visibility_range_end = 90.0
	elif longest_side <= 24.0:
		geometry.visibility_range_end = 125.0


func _optimize_environment(environment: Environment) -> void:
	if environment == null:
		return
	environment.ssao_enabled = false
	environment.ssil_enabled = false
	environment.sdfgi_enabled = false
	environment.glow_enabled = false
	environment.volumetric_fog_enabled = false
