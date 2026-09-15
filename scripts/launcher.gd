extends Node3D

@export var ball_path: NodePath
@export var launch_force: Vector3 = Vector3(0, 3.0, -9.0)
@export var compress_time: float = 0.3
@export var release_time: float = 0.12

var ball: RigidBody3D
var has_launched: bool = false

func _ready() -> void:
	ball = get_node(ball_path)
	var spring: Node3D = $Spring
	var original_scale: Vector3 = spring.scale
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(spring, "scale:y", original_scale.y * 0.35, compress_time)
	tween.tween_property(spring, "scale:y", original_scale.y, release_time)
	tween.tween_callback(_fire)

func _fire() -> void:
	if has_launched or ball == null:
		return
	has_launched = true
	ball.enable_movement()
	ball.apply_central_impulse(launch_force * ball.mass)
