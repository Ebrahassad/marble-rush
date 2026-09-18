extends Node3D

@export var track_piece_scene: PackedScene = preload("res://scenes/TrackPiece.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
@export var piece_length: float = 3.58
@export var pieces_ahead: int = 35
@export var min_pieces_between_obstacles: int = 5
@export var lane_offset: float = 1.0
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

func get_path_x(_z: float) -> float:
	return 0.0

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
	var piece: Node3D = track_piece_scene.instantiate()
	add_child(piece)
	piece.global_position = Vector3(0, 0, next_z)
	active_pieces.append(piece)

	piece_count += 1
	pieces_since_obstacle += 1

	if piece_count > 6:
		var roll: float = rng.randf()
		if roll < 0.16 and pieces_since_obstacle >= min_pieces_between_obstacles:
			var lane: float = float(rng.randi_range(-1, 1)) * lane_offset
			var obstacle: Node3D = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = Vector3(lane, 1.6, next_z)
			pieces_since_obstacle = 0
		elif roll < 0.38:
			var coin_lane: float = float(rng.randi_range(-1, 1)) * lane_offset
			var coin: Node3D = coin_scene.instantiate()
			add_child(coin)
			coin.global_position = Vector3(coin_lane, 2.1, next_z)

	if piece_count % 2 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen_tree: PackedScene = tree_scenes[rng.randi_range(0, tree_scenes.size() - 1)]
		var tree: Node3D = chosen_tree.instantiate()
		add_child(tree)
		var x_offset: float = side * rng.randf_range(4.0, 16.0)
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
		var g_offset: float = g_side * rng.randf_range(2.2, 5.0)
		var g_scale: float = rng.randf_range(2.0, 4.0)
		grass.global_position = Vector3(g_offset, -1.2, next_z + rng.randf_range(-1.0, 1.0))
		grass.scale = Vector3(g_scale, g_scale, g_scale)
		grass.rotate_y(rng.randf_range(0.0, TAU))
		active_grass.append(grass)

	next_z -= piece_length
