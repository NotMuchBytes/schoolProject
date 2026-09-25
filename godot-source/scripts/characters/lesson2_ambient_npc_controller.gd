class_name Lesson2AmbientNPCController
extends AmbientNPCController

@export var lesson2_line_ids: PackedStringArray = PackedStringArray()
@export_group("Living City")
@export_enum("auto", "work", "carry", "rehearse", "inspect", "rest") var ambient_activity: String = "auto"
@export_range(12.0, 60.0, 1.0) var activity_visibility_distance: float = 34.0
@export_range(12.0, 90.0, 1.0) var minimum_speech_gap: float = 22.0
@export var show_activity_prop: bool = true

var _lesson2_line_index := 0
var _activity_kind: String = "rest"
var _activity_phase: String = "rest"
var _activity_phase_index: int = -1
var _activity_phase_time: float = 0.0
var _activity_phase_duration: float = 1.0
var _activity_clock: float = 0.0
var _activity_rng := RandomNumberGenerator.new()
var _activity_prop: Node3D
var _activity_prop_base_position: Vector3
var _activity_prop_base_rotation: Vector3
var _visual_base_position: Vector3
var _silent_exchange_active: bool = false
var _silent_exchange_initiator: bool = false
var _silent_exchange_elapsed: float = 0.0
var _silent_exchange_duration: float = 0.0
var _silent_exchange_partner: Lesson2AmbientNPCController
var _silent_speaker_state: int = -1
var _silent_exchange_countdown: float = 0.0


func _ready() -> void:
	# Lesson 2 has six authored ambient citizens. Give each a long, staggered
	# subtitle interval so the city feels inhabited without becoming a wall of
	# floating text. Recorded audio remains optional through _next_ambient_entry.
	var identity_offset := float(posmod(str(name).hash(), 8))
	speech_interval_min = maxf(speech_interval_min, minimum_speech_gap + identity_offset)
	speech_interval_max = maxf(speech_interval_max, speech_interval_min + 10.0 + identity_offset * 0.5)
	super._ready()
	_activity_rng.seed = hash("%s:%s:%s" % [name, global_position.x, global_position.z])
	_activity_kind = _resolve_activity_kind()
	_visual_base_position = visual.position
	_silent_exchange_countdown = _activity_rng.randf_range(18.0, 34.0)
	_activity_phase_index = _activity_rng.randi_range(-1, _activity_sequence().size() - 2)
	_advance_activity_phase()
	if show_activity_prop:
		_build_activity_prop()
	destination_reached.connect(_on_activity_destination_reached)


func _exit_tree() -> void:
	_stop_silent_exchange()
	super._exit_tree()


func _process(delta: float) -> void:
	# Reset position before the shared controller applies its current pose. The
	# activity layer below then adds only small offsets and never accumulates drift.
	visual.position = _visual_base_position
	var close_enough := _is_camera_within(activity_visibility_distance)
	if _receive_reaction_active and _speech_timer <= delta:
		_speech_timer = _activity_rng.randf_range(3.0, 6.0)
	elif not close_enough and not _exchange_running and _speech_timer <= delta:
		# Do not begin subtitles or exchanges when nobody can see them. A fresh,
		# staggered timer is assigned rather than allowing an immediate burst later.
		_speech_timer = _activity_rng.randf_range(speech_interval_min, speech_interval_max)
	elif initiates_conversations and not conversation_partner_path.is_empty() and _speech_timer <= delta:
		var speech_partner := get_node_or_null(conversation_partner_path) as AmbientNPCController
		if (
			speech_partner != null
			and global_position.distance_squared_to(speech_partner.global_position) > 64.0
		):
			# Wait until both actors have patrolled into a believable speaking range.
			_speech_timer = _activity_rng.randf_range(4.0, 8.0)
	super._process(delta)
	_activity_clock += delta
	_activity_phase_time += delta
	if _activity_phase_time >= _activity_phase_duration:
		_advance_activity_phase()

	if _silent_exchange_active:
		_update_silent_exchange(delta)
	elif (
		initiates_conversations
		and close_enough
		and not _exchange_running
		and not _in_conversation
		and not _receive_reaction_active
	):
		_silent_exchange_countdown -= delta
		if _silent_exchange_countdown <= 0.0:
			_try_start_silent_exchange()

	if close_enough and not _receive_reaction_active:
		_apply_activity_pose()
	else:
		_reset_activity_prop_pose()


func _next_ambient_entry() -> Dictionary:
	if lesson2_line_ids.is_empty():
		return super._next_ambient_entry()
	var line_id := lesson2_line_ids[_lesson2_line_index]
	_lesson2_line_index = (_lesson2_line_index + 1) % lesson2_line_ids.size()
	var entry := Lesson2Content.entry(line_id)
	if entry.is_empty():
		return super._next_ambient_entry()
	# Lesson2Content keeps audio empty while the future recording is absent and
	# resolves the documented MP3 automatically once it is imported.
	return entry


func _resolve_activity_kind() -> String:
	if ambient_activity != "auto":
		return ambient_activity
	var context := str(name).to_lower()
	if "farm" in context or "stagehand" in context:
		return "work"
	if "carrier" in context or "harbour" in context or "harbor" in context:
		return "carry"
	if "theatre" in context or "chorus" in context:
		return "rehearse"
	if "library" in context or "student" in context:
		return "inspect"
	var fallbacks: Array[String] = ["work", "carry", "rehearse", "inspect", "rest"]
	return fallbacks[posmod(str(name).hash(), fallbacks.size())]


func _activity_sequence() -> Array[String]:
	match _activity_kind:
		"work":
			return ["work", "look", "work", "rest"]
		"carry":
			return ["carry", "look", "carry", "rest"]
		"rehearse":
			return ["gesture", "listen", "gesture", "rest"]
		"inspect":
			return ["inspect", "ponder", "look", "rest"]
		_:
			return ["look", "rest", "look", "rest"]


func _advance_activity_phase() -> void:
	var sequence := _activity_sequence()
	_activity_phase_index = (_activity_phase_index + 1) % sequence.size()
	_activity_phase = sequence[_activity_phase_index]
	_activity_phase_time = 0.0
	var duration_range := Vector2(1.2, 2.6)
	match _activity_phase:
		"work", "carry", "inspect", "gesture":
			duration_range = Vector2(2.0, 4.1)
		"ponder", "listen", "look":
			duration_range = Vector2(1.4, 2.8)
		"rest":
			duration_range = Vector2(1.8, 3.7)
	_activity_phase_duration = _activity_rng.randf_range(duration_range.x, duration_range.y)


func _apply_activity_pose() -> void:
	if _in_conversation:
		# Shared dialogue gestures already provide the speaking/listening motion;
		# suppress tool swings so silent exchanges remain readable and natural.
		_reset_activity_prop_pose()
		return
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var moving := horizontal_speed >= 0.12
	var phase_progress := clampf(
		_activity_phase_time / maxf(_activity_phase_duration, 0.001), 0.0, 1.0
	)
	var soft_cycle := sin(phase_progress * TAU)
	_reset_activity_prop_pose()

	# Walking always keeps a readable silhouette. Work/rehearsal bends happen only
	# during waypoint pauses, while carriers retain their load during locomotion.
	if moving:
		if _activity_kind == "carry":
			visual.rotation.x += 0.018
			if _activity_prop != null:
				_activity_prop.position.y += absf(sin(_activity_clock * 6.0)) * 0.025
		elif _activity_prop != null:
			_activity_prop.rotation.x += 0.18
		return

	match _activity_phase:
		"work":
			var work_arc := sin(phase_progress * TAU * 2.0)
			visual.rotation.x += 0.06 + maxf(work_arc, 0.0) * 0.045
			visual.rotation.z += work_arc * 0.012
			if _activity_prop != null:
				_activity_prop.rotation.x += work_arc * 0.38
				_activity_prop.position.y += maxf(-work_arc, 0.0) * 0.08
		"carry":
			visual.rotation.x += 0.018
			visual.rotation.z += soft_cycle * 0.007
			if _activity_prop != null:
				_activity_prop.position.y += soft_cycle * 0.012
		"gesture":
			visual.rotation.x += sin(phase_progress * PI) * 0.024
			visual.rotation.z += soft_cycle * 0.035
		"inspect":
			visual.rotation.x += 0.055 + soft_cycle * 0.008
			if _activity_prop != null:
				_activity_prop.position.y += sin(phase_progress * PI) * 0.16
				_activity_prop.rotation.x -= 0.17
		"ponder":
			visual.rotation.x += 0.025
			visual.rotation.y += soft_cycle * 0.018
			if _activity_prop != null:
				_activity_prop.position.y += 0.08
		"look", "listen":
			visual.rotation.y += soft_cycle * 0.055
			visual.rotation.x -= sin(phase_progress * PI) * 0.008
		"rest":
			visual.rotation.z += sin(_activity_clock * 0.65) * 0.006
			if _activity_prop != null and _activity_kind != "carry":
				_activity_prop.position.y -= 0.11


func _is_camera_within(distance: float) -> bool:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		# Headless flow tests have no active camera; keep behavior deterministic.
		return true
	return global_position.distance_squared_to(camera.global_position) <= distance * distance


func _try_start_silent_exchange() -> void:
	_silent_exchange_countdown = _activity_rng.randf_range(26.0, 48.0)
	if conversation_partner_path.is_empty():
		return
	var partner := get_node_or_null(conversation_partner_path) as Lesson2AmbientNPCController
	if (
		partner == null
		or partner._silent_exchange_active
		or partner._exchange_running
		or partner._in_conversation
		or partner._receive_reaction_active
		or not partner.is_visible_in_tree()
	):
		return
	if global_position.distance_squared_to(partner.global_position) > 64.0:
		_silent_exchange_countdown = _activity_rng.randf_range(4.0, 8.0)
		return
	var duration := _activity_rng.randf_range(3.4, 5.2)
	_silent_exchange_active = true
	_silent_exchange_initiator = true
	_silent_exchange_elapsed = 0.0
	_silent_exchange_duration = duration
	_silent_exchange_partner = partner
	_silent_speaker_state = -1
	begin_conversation(partner)
	partner._accept_silent_exchange(self, duration)


func _accept_silent_exchange(partner: Lesson2AmbientNPCController, duration: float) -> void:
	_silent_exchange_active = true
	_silent_exchange_initiator = false
	_silent_exchange_elapsed = 0.0
	_silent_exchange_duration = duration
	_silent_exchange_partner = partner
	_silent_speaker_state = -1
	begin_conversation(partner)


func _update_silent_exchange(delta: float) -> void:
	_silent_exchange_elapsed += delta
	var turn := int(floor(_silent_exchange_elapsed / 1.35)) % 2
	var should_speak := turn == (0 if _silent_exchange_initiator else 1)
	var speaker_state := 1 if should_speak else 0
	if speaker_state != _silent_speaker_state:
		_silent_speaker_state = speaker_state
		set_conversation_speaking(
			should_speak,
			int(floor(_silent_exchange_elapsed / 1.35)),
			"talk_ambient" if should_speak else "listen"
		)
	if _silent_exchange_elapsed >= _silent_exchange_duration:
		if _silent_exchange_initiator:
			_stop_silent_exchange()
		elif _silent_exchange_partner == null or not is_instance_valid(_silent_exchange_partner):
			_leave_silent_exchange()


func _stop_silent_exchange() -> void:
	if not _silent_exchange_active:
		return
	var partner := _silent_exchange_partner
	_leave_silent_exchange()
	if partner != null and is_instance_valid(partner) and partner._silent_exchange_active:
		partner._leave_silent_exchange()


func _leave_silent_exchange() -> void:
	_silent_exchange_active = false
	_silent_exchange_initiator = false
	_silent_exchange_elapsed = 0.0
	_silent_exchange_duration = 0.0
	_silent_exchange_partner = null
	_silent_speaker_state = -1
	if _in_conversation:
		end_conversation()


func _on_activity_destination_reached(_npc: Node, _waypoint_index: int) -> void:
	# Arrivals naturally become a short work/look/rest beat rather than an abrupt
	# statue pose. The randomized next phase keeps neighboring citizens unsynced.
	_activity_phase_time = maxf(_activity_phase_duration - 0.18, 0.0)


func _build_activity_prop() -> void:
	if _activity_kind not in ["work", "carry", "inspect"]:
		return
	_activity_prop = Node3D.new()
	_activity_prop.name = "AmbientTaskProp"
	visual.add_child(_activity_prop)
	match _activity_kind:
		"carry":
			_activity_prop.position = Vector3(0.0, 1.0, 0.43)
			_add_prop_box(
				_activity_prop, "Basket", Vector3(0.52, 0.20, 0.34), Vector3.ZERO,
				Color("8a5a32")
			)
			_add_prop_box(
				_activity_prop, "BasketRim", Vector3(0.58, 0.045, 0.39),
				Vector3(0.0, 0.12, 0.0), Color("b17a43")
			)
			for cargo_index in 3:
				_add_prop_sphere(
					_activity_prop, "Cargo%02d" % cargo_index, 0.075,
					Vector3((float(cargo_index) - 1.0) * 0.14, 0.15, 0.0),
					Color("a07937") if cargo_index != 1 else Color("65733e")
				)
		"inspect":
			_activity_prop.position = Vector3(0.0, 1.06, 0.43)
			_activity_prop.rotation = Vector3(-0.10, 0.0, 0.0)
			_add_prop_box(
				_activity_prop, "WaxTablet", Vector3(0.42, 0.30, 0.045),
				Vector3.ZERO, Color("8b5c36")
			)
			_add_prop_box(
				_activity_prop, "TabletInset", Vector3(0.34, 0.22, 0.012),
				Vector3(0.0, 0.0, 0.029), Color("c8a86f")
			)
		"work":
			_activity_prop.position = Vector3(0.30, 0.90, 0.31)
			_activity_prop.rotation = Vector3(0.20, 0.0, -0.18)
			_add_prop_box(
				_activity_prop, "ToolHandle", Vector3(0.055, 0.78, 0.055),
				Vector3(0.0, -0.05, 0.0), Color("765036")
			)
			_add_prop_box(
				_activity_prop, "ToolHead", Vector3(0.28, 0.07, 0.11),
				Vector3(0.0, -0.45, 0.02), Color("6b655b")
			)
	_activity_prop_base_position = _activity_prop.position
	_activity_prop_base_rotation = _activity_prop.rotation


func _reset_activity_prop_pose() -> void:
	if _activity_prop == null:
		return
	_activity_prop.position = _activity_prop_base_position
	_activity_prop.rotation = _activity_prop_base_rotation


func _add_prop_box(
	parent: Node3D, node_name: String, size: Vector3, local_position: Vector3, color: Color
) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = local_position
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.visibility_range_end = activity_visibility_distance + 8.0
	parent.add_child(instance)


func _add_prop_sphere(
	parent: Node3D, node_name: String, radius: float, local_position: Vector3, color: Color
) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = local_position
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.visibility_range_end = activity_visibility_distance + 8.0
	parent.add_child(instance)
