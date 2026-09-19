extends StaticBody3D


func _ready() -> void:
	add_to_group("obstacles")
	_load_barrier_model()


func _load_barrier_model() -> void:
	var barrier_path := "res://assets/barriers/barrier.gltf"
	if ResourceLoader.exists(barrier_path):
		var barrier_scene := load(barrier_path) as PackedScene
		if barrier_scene:
			var model := barrier_scene.instantiate()
			add_child(model)
