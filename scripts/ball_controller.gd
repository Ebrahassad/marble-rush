extends RigidBody3D

@export var forward_speed: float = 6.0
@export var steer_force: float = 12.0
@export var jump_impulse: float = 6.0
@export var fast_fall_force: float = 25.0
@export var lane_limit: float = 2.5

var touch_start_x: float = 0.0
var touch_start_y: float = 0.0
var is_dragging: bool = false
var is_grounded: bool = false
var fast_falling: bool = false

func _ready() -> void:
	var gold_material := StandardMaterial3D.new()
	gold_material.albedo_color = Color(0.83, 0.68, 0.21)
	gold_material.metallic = 0.85
	gold_material.roughness = 0.15
	gold_material.emission_enabled = true
	gold_material.emission = Color(0.6, 0.45, 0.05)
	gold_material.emission_energy_multiplier = 0.3
	_apply_material_recursive(self, gold_material)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_material_recursive(child, mat)

func _physics_process(delta: float) -> void:
	apply_central_force(Vector3(0, 0, -forward_speed * mass))

	if global_position.x > lane_limit:
		apply_central_force(Vector3(-steer_force * mass, 0, 0))
	elif global_position.x < -lane_limit:
		apply_central_force(Vector3(steer_force * mass, 0, 0))

	if fast_falling and not is_grounded:
		apply_central_force(Vector3(0, -fast_fall_force * mass, 0))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_x = event.position.x
			touch_start_y = event.position.y
			is_dragging = true
		else:
			is_dragging = false
			fast_falling = false

	elif event is InputEventScreenDrag and is_dragging:
		var delta_x: float = event.position.x - touch_start_x
		var delta_y: float = event.position.y - touch_start_y

		if delta_y > 80.0:
			fast_falling = true
		elif abs(delta_x) > 30.0:
			var direction: float = sign(delta_x)
			apply_central_force(Vector3(direction * steer_force * mass, 0, 0))
		elif delta_y < -80.0:
			_jump()

func _jump() -> void:
	if is_grounded:
		apply_central_impulse(Vector3(0, jump_impulse * mass, 0))
		is_grounded = false

func _on_body_entered(_body: Node) -> void:
	is_grounded = true
