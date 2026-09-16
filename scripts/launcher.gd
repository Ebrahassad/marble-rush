extends Node3D

@export var ball_path: NodePath
@export var launch_force: Vector3 = Vector3(0, 2.0, -11.0)
@export var recoil_amount: float = 0.25
@export var recoil_time: float = 0.12

var ball: RigidBody3D
var has_launched: bool = false

func _ready() -> void:
	ball = get_node(ball_path)
	var barrel: Node3D = $Barrel
	var original_z: float = barrel.position.z
	var tween := create_tween()
	tween.tween_interval(0.6)
	tween.tween_property(barrel, "position:z", original_z + recoil_amount, recoil_time)
	tween.tween_callback(_fire)
	tween.tween_property(barrel, "position:z", original_z, 0.2)

func _fire() -> void:
	if has_launched or ball == null:
		return
	has_launched = true
	ball.enable_movement()
	ball.apply_central_impulse(launch_force * ball.mass)
	$Barrel/Flash.visible = true
	var flash_tween := create_tween()
	flash_tween.tween_interval(0.08)
	flash_tween.tween_callback(func(): $Barrel/Flash.visible = false)
