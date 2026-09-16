extends Node3D

@export var track_piece_scene: PackedScene = preload("res://scenes/TrackPiece.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
@export var piece_length: float = 2.19
@export var pieces_ahead: int = 50
@export var min_pieces_between_obstacles: int = 5
@export var ball_path: NodePath

var building_scenes: Array[PackedScene] = [
	preload("res://assets/buildings/building-skyscraper-a.glb"),
	preload("res://assets/buildings/building-skyscraper-b.glb"),
	preload("res://assets/buildings/building-skyscraper-c.glb"),
	preload("res://assets/buildings/building-skyscraper-d.glb"),
	preload("res://assets/buildings/building-skyscraper-e.glb"),
]
static var cached_building_material: StandardMaterial3D = null

var ball: Node3D
var active_pieces: Array[Node3D] = []
var active_buildings: Array[Node3D] = []
var next_z: float = 0.0
var piece_count: int = 0
var pieces_since_obstacle: int = 999
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ball = get_node(ball_path)
	rng.randomize()
	if cached_building_material == null:
		cached_building_material = StandardMaterial3D.new()
		cached_building_material.albedo_color = Color(0.08, 0.05, 0.15)
		cached_building_material.roughness = 1.0
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

	while active_buildings.size() > 0 and active_buildings[0].global_position.z - ball.global_position.z > piece_length * 40.0:
		var old_building: Node3D = active_buildings.pop_front()
		old_building.queue_free()

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

	if piece_count % 3 == 0:
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		var chosen: PackedScene = building_scenes[rng.randi_range(0, building_scenes.size() - 1)]
		var building: Node3D = chosen.instantiate()
		add_child(building)
		var x_offset: float = side * rng.randf_range(12.0, 30.0)
		var scale_factor: float = rng.randf_range(3.5, 8.0)
		building.global_position = Vector3(x_offset, -1.2, next_z)
		building.scale = Vector3(scale_factor, scale_factor, scale_factor)
		_apply_building_material(building, cached_building_material)
		active_buildings.append(building)

	next_z -= piece_length

func _apply_building_material(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_building_material(child, mat)
