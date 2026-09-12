extends Camera3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 4, 6)
@export var follow_speed: float = 5.0

var target: Node3D

func _ready() -> void:
	target = get_node(target_path)

func _process(delta: float) -> void:
	if target == null:
		return
	var desired_position: Vector3 = target.global_position + offset
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	look_at(target.global_position, Vector3.UP)
