extends Node3D

@export var track_piece_scene: PackedScene = preload("res://scenes/TrackPiece.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
@export var piece_length: float = 2.19
@export var pieces_ahead: int = 50
@export var min_pieces_between_obstacles: int = 5
@export var ball_path: NodePath

var ball: Node3D
var active_pieces: Array[Node3D] = []
var next_z: float = 0.0
var piece_count: int = 0
var pieces_since_obstacle: int = 999
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ball = get_node(ball_path)
	rng.randomize()
	for i in range(pieces_ahead):
		_spawn_piece()

func _process(_delta: float) -> void:
	if ball == null:
		return

	if active_pieces.size() > 0:
		var last_piece_z: float = active_pieces[active_pieces.size() - 1].global_position.z
		if ball.global_position.z - last_piece_z < piece_length * 40.0:
			_spawn_piece()

	while active_pieces.size() > 0 and active_pieces[0].global_position.z - ball.global_position.z > piece_length * 40.0:
		var old_piece: Node3D = active_pieces.pop_front()
		old_piece.queue_free()

func _spawn_piece() -> void:
	var piece: Node3D = track_piece_scene.instantiate()
	add_child(piece)
	piece.global_position = Vector3(0, 0, next_z)
	active_pieces.append(piece)

	piece_count += 1
	pieces_since_obstacle += 1

	if piece_count > 6:
		var roll: float = rng.randf()
		if roll < 0.12 and pieces_since_obstacle >= min_pieces_between_obstacles:
			var obstacle: Node3D = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = Vector3(0, 1.55, next_z)
			pieces_since_obstacle = 0
		elif roll < 0.32:
			var coin: Node3D = coin_scene.instantiate()
			add_child(coin)
			coin.global_position = Vector3(0, 1.5, next_z)

	next_z -= piece_length
