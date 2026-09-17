extends Node3D

@export var track_piece_scene: PackedScene = preload("res://scenes/TrackPiece.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
@export var piece_length: float = 2.19
@export var pieces_ahead: int = 35
@export var min_pieces_between_obstacles: int = 5
@export var curve_amplitude: float = 3.2
@export var curve_frequency: float = 0.045
@export var curve_start_distance: float = 30.0
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
var active_pieces: Array[Node3D] = []
var active_trees: Array[Node3D] = []
var active_grass: Array[Node3D] = []
var next_z: float = 0.0
var piece_count: int = 0
var pieces_since_obstacle: int = 999
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ball = get_node(ball_path)
	rng.randomize()
	for i in range(pieces_ahead):
		_spawn_piece()

func get_path_x(z: float) -> float:
	var dist: float = max(-z, 0.0)
	if dist < curve_start_distance:
		return 0.0
	return sin((dist - curve_start_distance) * curve_frequency) * curve_amplitude

func _process(_delta: float) -> void:
	if ball == null:
		return

	if active_pieces.size() > 0:
		var last_piece_z: float = active_pieces[active_pieces.size() - 1].global_position.z
		if ball.global_position.z - last_piece_z < piece_length * 25.0:
			_spawn_piece()

	while active_pieces.size() > 0 and active_pieces[0].global_position.z - ball.global_position.z > piece_length * 25.0:
		var old_piece: Node3D = active_pieces.pop_front()
		old_piece.queue_free()

	while active_trees.size() > 0 and active_trees[0].global_position.z - ball.global_position.z > piece_length * 25.0:
		var old_tree: Node3D = active_trees.pop_front()
		old_tree.queue_free()

	while active_grass.size() > 0 and active_grass[0].global_position.z - ball.global_position.z > piece_length * 25.0:
		var old_grass: Node3D = active_grass.pop_front()
		old_grass.queue_free()

func _spawn_piece() -> void:
	var path_x: float = get_path_x(next_z)
	var piece: Node3D = track_piece_scene.instantiate()
	add_child(piece)
	piece.global_position = Vector3(path_x, 0, next_z)
	active_pieces.append(piece)

	piece_count += 1
	pieces_since_obstacle += 1

	if piece_count > 6:
		var roll: float = rng.randf()
		if roll < 0.12 and pieces_since_obstacle >= min_pieces_between_obstacles:
			var obstacle: Node3D = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = Vector3(path_x, 1.4, next_z)
			pieces_since_obstacle = 0
		elif roll < 0.32:
			var coin: Node3D = coin_scene.instantiate()
			add_child(coin)
			coin.global_position = Vector3(path_x, 1.5, next_z)

	if piece_count % 2 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_tree: PackedScene = tree_scenes[rng.randi_range(0, tree_scenes.size() - 1)]
		var tree: Node3D = chosen_tree.instantiate()
		add_child(tree)
		var x_offset: float = path_x + side * rng.randf_range(3.0, 14.0)
		var scale_factor: float = rng.randf_range(1.5, 3.0)
		tree.global_position = Vector3(x_offset, -1.2, next_z)
		tree.scale = Vector3(scale_factor, scale_factor, scale_factor)
		tree.rotate_y(rng.randf_range(0.0, TAU))
		active_trees.append(tree)

	for k in range(2):
		var g_side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_grass: PackedScene = grass_scenes[rng.randi_range(0, grass_scenes.size() - 1)]
		var grass: Node3D = chosen_grass.instantiate()
		add_child(grass)
		var g_offset: float = path_x + g_side * rng.randf_range(1.6, 4.0)
		var g_scale: float = rng.randf_range(2.0, 4.0)
		grass.global_position = Vector3(g_offset, -1.2, next_z + rng.randf_range(-1.0, 1.0))
		grass.scale = Vector3(g_scale, g_scale, g_scale)
		grass.rotate_y(rng.randf_range(0.0, TAU))
		active_grass.append(grass)

	next_z -= piece_length
