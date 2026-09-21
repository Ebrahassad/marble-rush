extends RigidBody3D

@export var base_max_forward_speed: float = 11.0
@export var difficulty_ramp: float = 0.012
@export var max_speed_cap: float = 24.0
@export var speed_ramp_rate: float = 0.18
@export var jump_impulse: float = 9.5
@export var fast_fall_force: float = 25.0
@export var slam_impulse: float = 4.0
@export var fall_death_y: float = -5.0
@export var jump_threshold: float = 40.0
@export var fast_fall_threshold: float = 60.0
@export var model_scale: float = 2.4
@export var start_delay: float = 1.5

var touch_start_y: float = 0.0
var is_dragging: bool = false
var is_grounded: bool = false
var fast_falling: bool = false
var jump_consumed: bool = false
var movement_enabled: bool = false
var elapsed_since_ready: float = 0.0
var anim_player: AnimationPlayer = null

func _ready() -> void:
	add_to_group("player")
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	var horse_scene: PackedScene = load(HorseManager.get_selected_path())
	var model: Node3D = horse_scene.instantiate()
	model.scale = Vector3(model_scale, model_scale, model_scale)
	model.rotate_y(PI)
	add_child(model)
	HorseManager.apply_horse_color(model, HorseManager.selected_horse)
	anim_player = _find_animation_player(model)
	_play_animation_containing("idle")

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
			var anim: Animation = anim_player.get_animation(anim_name)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			anim_player.play(anim_name)
			return

func enable_movement() -> void:
	if movement_enabled:
		return
	movement_enabled = true
	_play_animation_containing("run")

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return

	if not movement_enabled:
		elapsed_since_ready += delta
		if elapsed_since_ready >= start_delay:
			enable_movement()
		return

	if global_position.y < fall_death_y:
		GameManager.trigger_game_over()
		freeze = true
		if anim_player:
			anim_player.stop()
		return

	var distance: float = max(-global_position.z, 0.0)
	var current_max_speed: float = min(base_max_forward_speed + distance * difficulty_ramp, max_speed_cap)
	linear_velocity.z = lerp(linear_velocity.z, -current_max_speed, speed_ramp_rate)
	linear_velocity.x = lerp(linear_velocity.x, 0.0, 0.2)

	if fast_falling and not is_grounded:
		apply_central_force(Vector3(0, -fast_fall_force * mass, 0))

func _input(event: InputEvent) -> void:
	if GameManager.is_game_over or not movement_enabled:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
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
		var delta_y: float = event.position.y - touch_start_y
		if delta_y < -jump_threshold and not jump_consumed:
			_jump()
		elif delta_y > fast_fall_threshold:
			fast_falling = true

func _jump() -> void:
	if is_grounded:
		apply_central_impulse(Vector3(0, jump_impulse * mass, 0))
		is_grounded = false
		jump_consumed = true
		SFX.play_jump()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacles"):
		var died: bool = GameManager.register_hit()
		if died:
			freeze = true
			if anim_player:
				anim_player.stop()
	else:
		is_grounded = true
