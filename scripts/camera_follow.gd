extends Camera3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 9.0, 17.5)
@export var follow_speed: float = 8.0
@export var vertical_follow_factor: float = 0.15
@export var look_ahead_distance: float = 6.0
@export var max_look_offset: float = 7.0
@export var look_return_speed: float = 2.5

var target: Node3D
var smoothed_y: float = 0.0
var look_offset_x: float = 0.0
var cam_touch_start_x: float = 0.0
var cam_dragging: bool = false

func _ready() -> void:
	target = get_node(target_path)
	smoothed_y = target.global_position.y

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			cam_touch_start_x = event.position.x
			cam_dragging = true
		else:
			cam_dragging = false
	elif event is InputEventScreenDrag and cam_dragging:
		var delta_x: float = event.position.x - cam_touch_start_x
		look_offset_x = clamp(-delta_x * 0.02, -max_look_offset, max_look_offset)

func _process(delta: float) -> void:
	if target == null:
		return
	if not cam_dragging:
		look_offset_x = lerp(look_offset_x, 0.0, look_return_speed * delta)

	smoothed_y = lerp(smoothed_y, target.global_position.y, vertical_follow_factor)

	var desired_position: Vector3 = Vector3(
		target.global_position.x + offset.x,
		smoothed_y + offset.y,
		target.global_position.z + offset.z
	)
	global_position = global_position.lerp(desired_position, follow_speed * delta)

	var look_target: Vector3 = Vector3(
		target.global_position.x + look_offset_x,
		smoothed_y,
		target.global_position.z - look_ahead_distance
	)
	look_at(look_target, Vector3.UP)
