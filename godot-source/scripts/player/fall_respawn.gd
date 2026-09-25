class_name FallRespawn
extends Node

@export_node_path("CharacterBody3D") var player_path: NodePath
@export_node_path("Node3D") var spawn_point_path: NodePath
@export var fall_limit_y: float = -8.0

@onready var player: CharacterBody3D = get_node(player_path) as CharacterBody3D
@onready var spawn_point: Node3D = get_node(spawn_point_path) as Node3D

var _spawn_transform: Transform3D


func _ready() -> void:
	_spawn_transform = spawn_point.global_transform


func _physics_process(_delta: float) -> void:
	if player.global_position.y < fall_limit_y:
		respawn_player()


func respawn_player() -> void:
	player.velocity = Vector3.ZERO
	player.global_transform = _spawn_transform
	if player.has_method("snap_camera_after_teleport"):
		player.call("snap_camera_after_teleport")
	else:
		player.reset_physics_interpolation()


func set_checkpoint(checkpoint_transform: Transform3D) -> void:
	_spawn_transform = checkpoint_transform
