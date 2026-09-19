extends RigidBody3D

@export var base_max_forward_speed: float = 8.0
@export var difficulty_ramp: float = 0.012
@export var max_speed_cap: float = 20.0
@export var speed_ramp_rate: float = 0.12
@export var steer_force: float = 22.0
@export var jump_impulse: float = 6.5
@export var fast_fall_force: float = 25.0
@export var slam_impulse: float = 4.0
@export var lane_limit: float = 1.6
@export var fall_death_y: float = -5.0
@export var jump_threshold: float = 40.0
@export var fast_fall_threshold: float = 60.0
@export var track_manager_path: NodePath
@export var model_scale: float = 2.0
@export var start_delay: float = 1.5

var touch_start_x: float = 0.0
var touch_start_y: float = 0.0
var is_dragging: bool = false
var is_grounded: bool = false
var fast_falling: bool = false
var jump_consumed: bool = false
var movement_enabled: bool = false
var track_manager: Node = null
var anim_player: AnimationPlayer = null

func _ready() -> void:
	add_to_group("player")
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	if track_manager_path != NodePath():
		track_manager = get_node(track_manager_path)

	var horse_scene: PackedScene = load(HorseManager.get_selected_path())
	var model: Node3D = horse_scene.instantiate()
	model.scale = Vector3(model_scale, model_scale, model_scale)
	model.rotate_y(PI)
	add_child(model)
	anim_player = _find_animation_player(model)
	_play_animation_containing("idle")

	get_tree().create_timer(start_delay).timeout.connect(enable_movement)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result: AnimationPlayer = _find_animation_player(child)
		if result:
			return result
	return null

func _play_animation_containing(keyword: String) -> void:
	if anim_player == null:
		return
	for anim_name in anim_player.get_animation_list():
		if keyword.to_lower() in anim_name.to_lower():
			anim_player.play(anim_name)
			return

func enable_movement() -> void:
	movement_enabled = true
	_play_animation_containing("run")

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return

	if not movement_enabled:
		return

	if global_position.y < fall_death_y:
		GameManager.trigger_game_over()
		freeze = true
		if anim_player:
			anim_player.stop()
		return

	var distance: float = max(-global_position.z, 0.0)
	var current_max_speed: float = min(base_max_forward_speed + distance * difficulty_ramp, max_speed_cap)

	var new_z_velocity: float = lerp(linear_velocity.z, -current_max_speed, speed_ramp_rate)
	linear_velocity.z = new_z_velocity

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
		if anim_player:
			anim_player.stop()
	else:
		is_grounded = true
