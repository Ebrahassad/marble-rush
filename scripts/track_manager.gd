extends Node3D

@export var track_piece_scene: PackedScene = preload("res://scenes/TrackPiece.tscn")
@export var piece_length: float = 2.6
@export var pieces_ahead: int = 10
@export var ball_path: NodePath

var ball: Node3D
var active_pieces: Array[Node3D] = []
var next_z: float = 0.0

func _ready() -> void:
	ball = get_node(ball_path)
	for i in range(pieces_ahead):
		_spawn_piece()

func _process(_delta: float) -> void:
	if ball == null:
		return

	if active_pieces.size() > 0:
		var last_piece_z: float = active_pieces[active_pieces.size() - 1].global_position.z
		if ball.global_position.z - last_piece_z < piece_length * 4.0:
			_spawn_piece()

	while active_pieces.size() > 0 and active_pieces[0].global_position.z - ball.global_position.z > piece_length * 4.0:
		var old_piece: Node3D = active_pieces.pop_front()
		old_piece.queue_free()

func _spawn_piece() -> void:
	var piece: Node3D = track_piece_scene.instantiate()
	add_child(piece)
	piece.global_position = Vector3(0, 0, next_z)
	active_pieces.append(piece)
	next_z -= piece_length
