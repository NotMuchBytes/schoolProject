class_name PlayerController
extends CharacterBody3D

signal interact_pressed
signal interaction_pose_started(pose_name: String)
signal interaction_pose_finished(pose_name: String)

@export var walk_speed: float = 4.2
@export var run_speed: float = 6.8
@export var jump_velocity: float = 5.3
@export var acceleration: float = 36.0
@export var deceleration: float = 44.0
@export var mouse_sensitivity: float = 0.0023

const CAMERA_BASE_FOV: float = 64.5
const CAMERA_RUN_FOV_BONUS: float = 3.5
const CAMERA_ROTATION_RESPONSE: float = 17.0
const CAMERA_HORIZONTAL_RESPONSE: float = 18.0
const CAMERA_VERTICAL_RESPONSE: float = 10.0
const CAMERA_RECOVERY_SPEED: float = 6.0
const CAMERA_MAX_LOOK_AHEAD: float = 0.42
const CAMERA_TELEPORT_SNAP_DISTANCE: float = 8.0
const CAMERA_FADE_NEAR: float = 0.90
const CAMERA_FADE_FAR: float = 2.30

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_boom: SpringArm3D = $CameraPivot/CameraBoom
@onready var camera: Camera3D = $CameraPivot/CameraBoom/CameraMount/Camera3D
@onready var body_visual: Node3D = $Visual

var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _target_camera_yaw: float = 0.0
var _target_camera_pitch: float = -0.22
var _camera_distance: float = 5.25
var _camera_pivot_height: float = 1.68
var _last_camera_clearance: float = 5.25
var _player_meshes: Array[GeometryInstance3D] = []
var _player_mesh_base_transparency: Array[float] = []
var _last_camera_visual_fade: float = -1.0
var _camera_collision_warmup_frames := 0
var _controls_enabled: bool = true
var _footstep_distance: float = 0.0
var _was_on_floor: bool = false
var _conversation_target: Node3D
var _conversation_active: bool = false
var _conversation_speaking: bool = false
var _conversation_pose_time: float = 0.0
var _visual_base_x: float = 0.0
var _visual_base_z: float = 0.0
var _interaction_pose_active: bool = false
var _interaction_pose_name: String = ""
var _interaction_pose_elapsed: float = 0.0
var _interaction_pose_duration: float = 0.0
var _interaction_pose_locks_movement: bool = false
var _interaction_pose_restore_controls: bool = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Raw mouse events keep camera aiming responsive. The camera itself still uses
	# a short exponential ease below, so disabling event accumulation does not
	# make the view feel twitchy.
	Input.use_accumulated_input = false
	# Prevent the camera boom from collapsing into the player or nearby spawn walls.
	camera_boom.add_excluded_object(get_rid())
	if OS.has_feature("web"):
		camera_boom.collision_mask = 0
	_camera_pivot_height = camera_pivot.position.y
	# The camera rig tracks in world space so CharacterBody stair snapping and small
	# landing corrections do not transfer directly into the picture.
	var initial_camera_transform := camera_pivot.global_transform
	camera_pivot.top_level = true
	# The player body is physics-interpolated, while this detached camera rig is
	# positioned every rendered frame from the player's interpolated transform.
	# Excluding the rig avoids applying interpolation twice.
	camera_pivot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	camera_pivot.global_transform = initial_camera_transform
	_target_camera_yaw = camera_pivot.rotation.y
	_target_camera_pitch = camera_boom.rotation.x
	_camera_distance = camera_boom.spring_length
	_last_camera_clearance = camera_boom.spring_length
	camera.fov = CAMERA_BASE_FOV
	_collect_player_meshes(body_visual)
	_was_on_floor = is_on_floor()
	_visual_base_x = body_visual.rotation.x
	_visual_base_z = body_visual.rotation.z


func _process(delta: float) -> void:
	_update_camera_follow(delta)
	var rotation_weight := 1.0 - exp(-CAMERA_ROTATION_RESPONSE * delta)
	camera_pivot.rotation.y = lerp_angle(
		camera_pivot.rotation.y, _target_camera_yaw, rotation_weight
	)
	camera_boom.rotation.x = lerpf(
		camera_boom.rotation.x, _target_camera_pitch, rotation_weight
	)
	var camera_clearance := _smooth_camera_collision(delta)
	_update_camera_fov(delta)
	_update_camera_visual_fade(camera_clearance)
	if _interaction_pose_active:
		_update_interaction_pose(delta)
	else:
		_update_conversation_pose(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not _controls_enabled:
		if event.is_action_pressed("interact"):
			interact_pressed.emit()
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_target_camera_yaw = wrapf(
			_target_camera_yaw - event.relative.x * mouse_sensitivity, -PI, PI
		)
		_target_camera_pitch = clampf(
			_target_camera_pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(-42.0),
			deg_to_rad(18.0)
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_VISIBLE
		)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("interact"):
		interact_pressed.emit()


func _physics_process(delta: float) -> void:
	var started_on_floor := is_on_floor()
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if _controls_enabled and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		AudioDirector.play_sfx("player_jump")

	var input_vector := Vector2.ZERO
	if _controls_enabled:
		input_vector = Input.get_vector(
			"move_left", "move_right", "move_forward", "move_backward"
		)
	# Movement follows the requested camera heading immediately instead of the
	# visually smoothed pivot. This removes the subtle steering delay while the
	# rendered camera can retain its polished ease.
	var movement_basis := Basis(Vector3.UP, _target_camera_yaw)
	var camera_forward := -movement_basis.z
	var camera_right := movement_basis.x

	var move_direction := (camera_right * input_vector.x + camera_forward * -input_vector.y).normalized()
	var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
	var target_velocity := move_direction * target_speed
	var change_rate := acceleration if move_direction != Vector3.ZERO else deceleration
	if not is_on_floor():
		change_rate *= 0.35

	velocity.x = move_toward(velocity.x, target_velocity.x, change_rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, change_rate * delta)

	if move_direction != Vector3.ZERO:
		var target_yaw := atan2(move_direction.x, move_direction.z)
		var turn_weight := 1.0 - exp(-18.0 * delta)
		body_visual.rotation.y = lerp_angle(body_visual.rotation.y, target_yaw, turn_weight)

	move_and_slide()
	_update_movement_audio(delta, started_on_floor)


func set_controls_enabled(enabled: bool) -> void:
	# A short interaction pose may temporarily own movement. Remember external
	# control changes instead of allowing the pose to re-enable controls after a
	# cutscene or modal UI has taken over.
	if _interaction_pose_active and _interaction_pose_locks_movement:
		_interaction_pose_restore_controls = enabled
		if not enabled:
			velocity.x = 0.0
			velocity.z = 0.0
		return
	_controls_enabled = enabled
	if not enabled:
		velocity.x = 0.0
		velocity.z = 0.0


func set_cinematic_mode(enabled: bool) -> void:
	set_controls_enabled(not enabled)
	if enabled:
		# Dialogue and authored shots use a separate camera. Always restore the
		# complete player silhouette before that camera takes control.
		_apply_camera_visual_fade(0.0)


func get_gameplay_camera() -> Camera3D:
	return camera


func snap_camera_after_teleport() -> void:
	# Keep renderer interpolation and the detached camera rig in the same world
	# position after respawns or authored repositioning.
	reset_physics_interpolation()
	camera_pivot.global_position = global_position + Vector3.UP * _camera_pivot_height
	_camera_distance = camera_boom.spring_length
	_last_camera_clearance = camera_boom.spring_length
	camera.position.z = 0.0
	_camera_collision_warmup_frames = 2


func face_toward(target_position: Vector3) -> void:
	var direction := target_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.0001:
		body_visual.rotation.y = atan2(direction.x, direction.z)


func play_interaction_pose(
	pose_name: String = "inspect", duration: float = 0.48, lock_movement: bool = true
) -> void:
	# The current character rig intentionally stays simple. These small full-body
	# offsets make pickup, placement and inspection readable without introducing
	# brittle bone-name dependencies or affecting normal locomotion.
	if _interaction_pose_active and _interaction_pose_locks_movement:
		_controls_enabled = _interaction_pose_restore_controls
	_interaction_pose_active = true
	_interaction_pose_name = pose_name
	_interaction_pose_elapsed = 0.0
	_interaction_pose_duration = maxf(duration, 0.08)
	_interaction_pose_locks_movement = lock_movement
	_interaction_pose_restore_controls = _controls_enabled
	if lock_movement:
		_controls_enabled = false
		velocity.x = 0.0
		velocity.z = 0.0
	interaction_pose_started.emit(_interaction_pose_name)


func cancel_interaction_pose() -> void:
	if not _interaction_pose_active:
		return
	var finished_pose := _interaction_pose_name
	_interaction_pose_active = false
	_interaction_pose_name = ""
	_interaction_pose_elapsed = 0.0
	body_visual.rotation.x = _visual_base_x
	body_visual.rotation.z = _visual_base_z
	if _interaction_pose_locks_movement:
		_controls_enabled = _interaction_pose_restore_controls
	_interaction_pose_locks_movement = false
	interaction_pose_finished.emit(finished_pose)


func is_interaction_pose_active() -> bool:
	return _interaction_pose_active


func get_hold_anchor(hold_pose: String = "one_hand") -> Node3D:
	var anchors := body_visual.get_node_or_null("HoldAnchors") as Node3D
	if anchors == null:
		anchors = Node3D.new()
		anchors.name = "HoldAnchors"
		body_visual.add_child(anchors)
	var anchor_name := "OneHand"
	match hold_pose:
		"two_hand", "basket": anchor_name = "TwoHand"
		"large", "crate": anchor_name = "Large"
		"inspect", "tablet": anchor_name = "Inspect"
	var anchor := anchors.get_node_or_null(anchor_name) as Node3D
	if anchor == null:
		anchor = Node3D.new()
		anchor.name = anchor_name
		anchors.add_child(anchor)
		match anchor_name:
			"TwoHand": anchor.position = Vector3(0.0, 1.08, 0.43)
			"Large": anchor.position = Vector3(0.0, 1.02, 0.58)
			"Inspect": anchor.position = Vector3(0.2, 1.34, 0.3)
			_: anchor.position = Vector3(0.36, 1.08, 0.38)
	return anchor


func begin_conversation_pose(target: Node3D) -> void:
	_conversation_target = target
	_conversation_active = target != null
	_conversation_speaking = false
	_conversation_pose_time = 0.0
	velocity.x = 0.0
	velocity.z = 0.0
	if body_visual.has_method("set_conversation_state"):
		body_visual.call("set_conversation_state", false, 0)


func set_conversation_speaking(
	speaking: bool, line_index: int = 0, gesture_state: String = "talk_response"
) -> void:
	_conversation_speaking = speaking
	# Starting a fresh, deterministic gesture phase keeps consecutive lines from
	# looking like one endlessly looping motion.
	_conversation_pose_time = float(posmod(line_index * 17, 23)) * 0.11
	if body_visual.has_method("set_conversation_state"):
		body_visual.call("set_conversation_state", speaking, line_index, gesture_state)


func end_conversation_pose() -> void:
	_conversation_active = false
	_conversation_speaking = false
	_conversation_target = null
	if body_visual.has_method("clear_conversation_state"):
		body_visual.call("clear_conversation_state")


func _update_conversation_pose(delta: float) -> void:
	if not _conversation_active or not is_instance_valid(_conversation_target):
		body_visual.rotation.x = lerpf(body_visual.rotation.x, _visual_base_x, minf(delta * 8.0, 1.0))
		body_visual.rotation.z = lerpf(body_visual.rotation.z, _visual_base_z, minf(delta * 8.0, 1.0))
		return

	_conversation_pose_time += delta
	var direction := _conversation_target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.0001:
		var target_yaw := atan2(direction.x, direction.z)
		body_visual.rotation.y = lerp_angle(
			body_visual.rotation.y, target_yaw, minf(delta * 7.5, 1.0)
		)

	# The imported character has Idle/Walk/Run only. These restrained offsets sit
	# on top of Idle and provide distinct speaking/listening silhouettes without
	# touching the skeleton or risking incompatible animation tracks.
	var nod_amount := 0.018 if _conversation_speaking else 0.007
	var sway_amount := 0.013 if _conversation_speaking else 0.005
	var nod_speed := 3.4 if _conversation_speaking else 1.35
	body_visual.rotation.x = _visual_base_x + sin(_conversation_pose_time * nod_speed) * nod_amount
	body_visual.rotation.z = _visual_base_z + sin(_conversation_pose_time * (nod_speed * 0.63) + 0.7) * sway_amount


func _update_interaction_pose(delta: float) -> void:
	_interaction_pose_elapsed += delta
	var progress := clampf(
		_interaction_pose_elapsed / maxf(_interaction_pose_duration, 0.001), 0.0, 1.0
	)
	var pulse := sin(progress * PI)
	var bend := 0.06
	var lean := 0.015
	match _interaction_pose_name:
		"pickup":
			bend = 0.19
			lean = -0.035
		"place":
			bend = 0.13
			lean = 0.03
		"carry_receive":
			bend = 0.08
			lean = -0.025
		"inspect":
			bend = -0.045
			lean = 0.025
	body_visual.rotation.x = _visual_base_x + pulse * bend
	body_visual.rotation.z = _visual_base_z + pulse * lean
	if progress >= 1.0:
		cancel_interaction_pose()


func _update_camera_follow(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var look_ahead := Vector3.ZERO
	if _controls_enabled and horizontal_velocity.length_squared() > 0.01:
		var speed_ratio := clampf(horizontal_velocity.length() / maxf(run_speed, 0.01), 0.0, 1.0)
		# Suppress velocity lead in cramped spaces so the spring origin cannot be
		# pulled toward the same obstacle that is already retracting the camera.
		var clearance_ratio := clampf(
			inverse_lerp(1.5, 3.2, _last_camera_clearance), 0.0, 1.0
		)
		look_ahead = (
			horizontal_velocity.normalized()
			* CAMERA_MAX_LOOK_AHEAD
			* speed_ratio
			* clearance_ratio
		)

	# Sampling the interpolated transform prevents visible 60 Hz body steps when
	# the renderer is running faster (or at an uneven frame cadence).
	var player_render_position := get_global_transform_interpolated().origin
	var desired_position := player_render_position + Vector3.UP * _camera_pivot_height + look_ahead
	var current_position := camera_pivot.global_position
	if current_position.distance_squared_to(desired_position) > CAMERA_TELEPORT_SNAP_DISTANCE * CAMERA_TELEPORT_SNAP_DISTANCE:
		camera_pivot.global_position = desired_position
		# A scene transfer, respawn, or debug reposition can leave the spring arm's
		# previous-frame hit cached at the old location. Reset only the recovery
		# offset; the spring arm will still apply a real obstruction on this frame.
		_camera_distance = camera_boom.spring_length
		_last_camera_clearance = camera_boom.spring_length
		camera.position.z = 0.0
		_camera_collision_warmup_frames = 1
		return

	var horizontal_weight := 1.0 - exp(-CAMERA_HORIZONTAL_RESPONSE * delta)
	var vertical_weight := 1.0 - exp(-CAMERA_VERTICAL_RESPONSE * delta)
	current_position.x = lerpf(current_position.x, desired_position.x, horizontal_weight)
	current_position.z = lerpf(current_position.z, desired_position.z, horizontal_weight)
	current_position.y = lerpf(current_position.y, desired_position.y, vertical_weight)
	camera_pivot.global_position = current_position


func _update_camera_fov(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var run_blend := clampf(
		inverse_lerp(walk_speed, maxf(run_speed, walk_speed + 0.01), horizontal_speed),
		0.0,
		1.0
	)
	if not _controls_enabled:
		run_blend = 0.0
	var target_fov := CAMERA_BASE_FOV + CAMERA_RUN_FOV_BONUS * run_blend
	var fov_weight := 1.0 - exp(-4.5 * delta)
	camera.fov = lerpf(camera.fov, target_fov, fov_weight)


func _smooth_camera_collision(delta: float) -> float:
	var collision_distance := camera_boom.get_hit_length()
	if _camera_collision_warmup_frames > 0:
		_camera_collision_warmup_frames -= 1
		collision_distance = camera_boom.spring_length
	if collision_distance <= 0.0:
		collision_distance = camera_boom.spring_length
	collision_distance = clampf(collision_distance, 0.0, camera_boom.spring_length)
	if collision_distance < _camera_distance:
		_camera_distance = collision_distance
	else:
		_camera_distance = move_toward(
			_camera_distance, collision_distance, CAMERA_RECOVERY_SPEED * delta
		)
	camera.position.z = _camera_distance - collision_distance
	_last_camera_clearance = _camera_distance
	return _camera_distance


func _collect_player_meshes(node: Node) -> void:
	if node is GeometryInstance3D:
		var geometry := node as GeometryInstance3D
		_player_meshes.append(geometry)
		_player_mesh_base_transparency.append(geometry.transparency)
	for child in node.get_children():
		_collect_player_meshes(child)


func _update_camera_visual_fade(camera_clearance: float) -> void:
	_apply_camera_visual_fade(0.0)


func _apply_camera_visual_fade(fade: float) -> void:
	fade = clampf(fade, 0.0, 1.0)
	if is_equal_approx(fade, _last_camera_visual_fade):
		return
	_last_camera_visual_fade = fade
	# A partially transparent face filling the frame is more distracting than a
	# brief clean hide. Once an obstruction brings the boom inside the character's
	# silhouette, hide the whole visual (including held props) until clearance
	# returns; the collision body and gameplay remain unchanged.
	body_visual.visible = true
	var mesh_fade := minf(fade, 0.96)
	for index in range(_player_meshes.size()):
		var geometry := _player_meshes[index]
		if not is_instance_valid(geometry):
			continue
		var base_transparency := _player_mesh_base_transparency[index]
		geometry.transparency = lerpf(base_transparency, 1.0, mesh_fade)


func _update_movement_audio(delta: float, started_on_floor: bool) -> void:
	var grounded := is_on_floor()
	if grounded and not started_on_floor and not _was_on_floor:
		AudioDirector.play_sfx("player_land")
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if grounded and _controls_enabled and horizontal_speed > 0.25:
		_footstep_distance += horizontal_speed * delta
		var step_spacing := 1.65 if horizontal_speed >= run_speed * 0.78 else 2.05
		if _footstep_distance >= step_spacing:
			_footstep_distance = 0.0
			AudioDirector.play_sfx("player_footstep_stone_earth")
	else:
		_footstep_distance = 0.0
	_was_on_floor = grounded
