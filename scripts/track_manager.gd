extends Node3D

@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Apple.tscn")
@export var spawn_step: float = 4.18
@export var spawn_ahead: int = 35
@export var min_steps_between_obstacles: int = 5
@export var lane_offset: float = 1.3
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

func _despawn_far(list: Array[Node3D], despawn_distance: float) -> void:
	while list.size() > 0 and is_instance_valid(list[0]) == false:
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
		if roll < 0.16 and steps_since_obstacle >= min_steps_between_obstacles:
			var lane: float = float(rng.randi_range(-1, 1)) * lane_offset
			var obstacle: Node3D = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = Vector3(lane, 1.87, next_z)
			active_obstacles.append(obstacle)
			steps_since_obstacle = 0
		elif roll < 0.38:
			var coin_lane: float = float(rng.randi_range(-1, 1)) * lane_offset
			var coin: Node3D = coin_scene.instantiate()
			add_child(coin)
			coin.global_position = Vector3(coin_lane, 2.6, next_z)
			active_coins.append(coin)

	if step_count % 2 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_tree: PackedScene = tree_scenes[rng.randi_range(0, tree_scenes.size() - 1)]
		var tree: Node3D = chosen_tree.instantiate()
		add_child(tree)
		var x_offset: float = side * rng.randf_range(5.0, 18.0)
		var scale_factor: float = rng.randf_range(2.5, 5.0)
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

	next_z -= spawn_step
