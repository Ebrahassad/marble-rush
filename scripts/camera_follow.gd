extends Camera3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 2.4, 4.2)
@export var follow_speed: float = 8.0
@export var vertical_follow_factor: float = 0.15
@export var look_ahead_distance: float = 6.0

var target: Node3D
var smoothed_y: float = 0.0


func _ready() -> void:
	target = get_node(target_path)
	smoothed_y = target.global_position.y


func _process(delta: float) -> void:
	if target == null:
		return

	smoothed_y = lerp(smoothed_y, target.global_position.y, vertical_follow_factor)

	var desired_position: Vector3 = Vector3(
		target.global_position.x + offset.x,
		smoothed_y + offset.y,
		target.global_position.z + offset.z
	)
	global_position = global_position.lerp(desired_position, follow_speed * delta)

	var look_target: Vector3 = Vector3(
		target.global_position.x, smoothed_y, target.global_position.z - look_ahead_distance
	)
	look_at(look_target, Vector3.UP)
