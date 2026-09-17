extends RigidBody3D

@export var forward_speed: float = 4.0
@export var base_max_forward_speed: float = 8.0
@export var difficulty_ramp: float = 0.012
@export var max_speed_cap: float = 20.0
@export var steer_force: float = 18.0
@export var jump_impulse: float = 6.0
@export var fast_fall_force: float = 25.0
@export var slam_impulse: float = 4.0
@export var lane_limit: float = 0.55
@export var fall_death_y: float = -5.0
@export var jump_threshold: float = 40.0
@export var fast_fall_threshold: float = 60.0
@export var track_manager_path: NodePath

var touch_start_x: float = 0.0
var touch_start_y: float = 0.0
var is_dragging: bool = false
var is_grounded: bool = false
var fast_falling: bool = false
var jump_consumed: bool = false
var movement_enabled: bool = false
var track_manager: Node = null

func _ready() -> void:
	add_to_group("player")
	if track_manager_path != NodePath():
		track_manager = get_node(track_manager_path)
	var iron_material := StandardMaterial3D.new()
	iron_material.albedo_color = Color(0.4, 0.41, 0.43)
	iron_material.metallic = 0.3
	iron_material.roughness = 0.55
	_apply_material_recursive(self, iron_material)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_material_recursive(child, mat)

func enable_movement() -> void:
	movement_enabled = true

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return

	if not movement_enabled:
		return

	if global_position.y < fall_death_y:
		GameManager.trigger_game_over()
		freeze = true
		return

	var distance: float = max(-global_position.z, 0.0)
	var current_max_speed: float = min(base_max_forward_speed + distance * difficulty_ramp, max_speed_cap)

	if linear_velocity.z > -current_max_speed:
		apply_central_force(Vector3(0, 0, -forward_speed * mass))

	var center_x: float = 0.0
	if track_manager != null:
		center_x = track_manager.get_path_x(global_position.z)
	var relative_x: float = global_position.x - center_x

	if relative_x > lane_limit:
		apply_central_force(Vector3(-steer_force * mass, 0, 0))
	elif relative_x < -lane_limit:
		apply_central_force(Vector3(steer_force * mass, 0, 0))

	if fast_falling and not is_grounded:
		apply_central_force(Vector3(0, -fast_fall_force * mass, 0))

func _input(event: InputEvent) -> void:
	if GameManager.is_game_over or not movement_enabled:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_x = event.position.x
			touch_start_y = event.position.y
			is_dragging = true
			jump_consumed = false
			if not is_grounded:
				fast_falling = true
				apply_central_impulse(Vector3(0, -slam_impulse * mass, 0))
		else:
			var total_delta_y: float = event.position.y - touch_start_y
			if not jump_consumed and total_delta_y < -jump_threshold:
				_jump()
			is_dragging = false
			fast_falling = false

	elif event is InputEventScreenDrag and is_dragging:
		var delta_x: float = event.position.x - touch_start_x
		var delta_y: float = event.position.y - touch_start_y

		if abs(delta_y) > abs(delta_x):
			if delta_y < -jump_threshold and not jump_consumed:
				_jump()
			elif delta_y > fast_fall_threshold:
				fast_falling = true
		elif abs(delta_x) > 15.0:
			var direction: float = sign(delta_x)
			apply_central_force(Vector3(direction * steer_force * mass, 0, 0))
			touch_start_x = event.position.x

func _jump() -> void:
	if is_grounded:
		apply_central_impulse(Vector3(0, jump_impulse * mass, 0))
		is_grounded = false
		jump_consumed = true
		SFX.play_jump()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacles"):
		GameManager.trigger_game_over()
		freeze = true
	else:
		is_grounded = true
