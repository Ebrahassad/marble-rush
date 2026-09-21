extends Node3D

@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Apple.tscn")
@export var spawn_step: float = 4.18
@export var spawn_ahead: int = 35
@export var min_steps_between_obstacles: int = 6
@export var ball_path: NodePath

var tree_scenes: Array[PackedScene] = [
	preload("res://assets/trees/tree_pineTallA.glb"),
	preload("res://assets/trees/tree_default.glb"),
	preload("res://assets/trees/tree_oak.glb"),
]
var grass_scenes: Array[PackedScene] = [
	preload("res://assets/grass/grass.glb"),
	preload("res://assets/grass/grass_leafs.glb"),
]

var ball: Node3D
var active_trees: Array[Node3D] = []
var active_grass: Array[Node3D] = []
var active_obstacles: Array[Node3D] = []
var active_coins: Array[Node3D] = []
var active_scenery: Array[Node3D] = []
var next_z: float = 0.0
var step_count: int = 0
var steps_since_obstacle: int = 999
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ball = get_node(ball_path)
	rng.randomize()
	for i in range(spawn_ahead):
		_spawn_step()

func get_path_x(_z: float) -> float:
	return 0.0

func _process(_delta: float) -> void:
	if ball == null:
		return

	var despawn_distance: float = spawn_step * spawn_ahead

	if ball.global_position.z - next_z < despawn_distance:
		_spawn_step()

	_despawn_far(active_trees, despawn_distance)
	_despawn_far(active_grass, despawn_distance)
	_despawn_far(active_obstacles, despawn_distance)
	_despawn_far(active_coins, despawn_distance)
	_despawn_far(active_scenery, despawn_distance)

func _despawn_far(list: Array[Node3D], despawn_distance: float) -> void:
	while list.size() > 0 and not is_instance_valid(list[0]):
		list.pop_front()
	while list.size() > 0 and list[0].global_position.z - ball.global_position.z > despawn_distance:
		var old: Node3D = list.pop_front()
		if is_instance_valid(old):
			old.queue_free()

func _spawn_step() -> void:
	step_count += 1
	steps_since_obstacle += 1

	if step_count > 6:
		var roll: float = rng.randf()
		if roll < 0.14 and steps_since_obstacle >= min_steps_between_obstacles:
			var obstacle: Node3D = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = Vector3(0, 1.87, next_z)
			var width_scale: float = rng.randf_range(0.8, 1.5)
			obstacle.scale = Vector3(width_scale, 1.0, 1.0)
			var hurdle_colors: Array[Color] = [Color(0.85, 0.15, 0.12), Color(0.15, 0.4, 0.8), Color(0.9, 0.75, 0.1)]
			var rail_mat := StandardMaterial3D.new()
			rail_mat.albedo_color = hurdle_colors[rng.randi_range(0, hurdle_colors.size() - 1)]
			rail_mat.roughness = 0.6
			var rail: MeshInstance3D = obstacle.get_node("Rail")
			rail.set_surface_override_material(0, rail_mat)
			active_obstacles.append(obstacle)
			steps_since_obstacle = 0
		elif roll < 0.36:
			var coin: Node3D = coin_scene.instantiate()
			add_child(coin)
			coin.global_position = Vector3(0, 2.6, next_z)
			active_coins.append(coin)

	if step_count % 2 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_tree: PackedScene = tree_scenes[rng.randi_range(0, tree_scenes.size() - 1)]
		var tree: Node3D = chosen_tree.instantiate()
		add_child(tree)
		var x_offset: float = side * rng.randf_range(5.0, 18.0)
		var scale_factor: float = rng.randf_range(3.5, 6.5)
		tree.global_position = Vector3(x_offset, 1.87, next_z)
		tree.scale = Vector3(scale_factor, scale_factor, scale_factor)
		tree.rotate_y(rng.randf_range(0.0, TAU))
		active_trees.append(tree)

	for k in range(2):
		var g_side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_grass: PackedScene = grass_scenes[rng.randi_range(0, grass_scenes.size() - 1)]
		var grass: Node3D = chosen_grass.instantiate()
		add_child(grass)
		var g_offset: float = g_side * rng.randf_range(2.8, 6.0)
		var g_scale: float = rng.randf_range(3.0, 6.0)
		grass.global_position = Vector3(g_offset, 1.87, next_z + rng.randf_range(-1.0, 1.0))
		grass.scale = Vector3(g_scale, g_scale, g_scale)
		grass.rotate_y(rng.randf_range(0.0, TAU))
		active_grass.append(grass)

	if step_count % 5 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var x_offset: float = side * rng.randf_range(30.0, 60.0)
		if rng.randf() < 0.5:
			active_scenery.append(_spawn_mountain(x_offset, next_z))
		else:
			active_scenery.append(_spawn_house(x_offset, next_z))

func _spawn_mountain(x_offset: float, z: float) -> Node3D:
	var mountain := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = 12.0
	mesh.height = 28.0
	mountain.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.3, 0.34)
	mat.roughness = 1.0
	mountain.set_surface_override_material(0, mat)
	add_child(mountain)
	mountain.global_position = Vector3(x_offset, 1.87 + 12.0, z)
	return mountain

func _spawn_house(x_offset: float, z: float) -> Node3D:
	var house := Node3D.new()
	add_child(house)
	house.global_position = Vector3(x_offset, 1.87, z)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(4.0, 3.0, 4.0)
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.75, 0.68, 0.55)
	body_mat.roughness = 0.9
	body.set_surface_override_material(0, body_mat)
	body.position = Vector3(0, 1.5, 0)
	house.add_child(body)

	var roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.0
	roof_mesh.bottom_radius = 3.2
	roof_mesh.height = 2.2
	roof_mesh.radial_segments = 4
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.45, 0.18, 0.14)
	roof_mat.roughness = 0.85
	roof.set_surface_override_material(0, roof_mat)
	roof.rotate_y(PI / 4.0)
	roof.position = Vector3(0, 4.1, 0)
	house.add_child(roof)

	return house
