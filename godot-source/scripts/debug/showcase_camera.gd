extends Camera3D

@export var move_speed: float = 10.0
@export var fast_multiplier: float = 2.5
@export var look_sensitivity: float = 0.0022

var _yaw: float
var _pitch: float


func _ready() -> void:
	_yaw = rotation.y
	_pitch = rotation.x
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	var local_input := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		local_input.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		local_input.z += 1.0
	if Input.is_key_pressed(KEY_A):
		local_input.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		local_input.x += 1.0
	if Input.is_key_pressed(KEY_E):
		local_input.y += 1.0
	if Input.is_key_pressed(KEY_Q):
		local_input.y -= 1.0
	if local_input != Vector3.ZERO:
		var speed := move_speed * (fast_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		global_position += global_basis * local_input.normalized() * speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * look_sensitivity
		_pitch = clampf(_pitch - event.relative.y * look_sensitivity, deg_to_rad(-85.0), deg_to_rad(85.0))
		rotation = Vector3(_pitch, _yaw, 0.0)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
