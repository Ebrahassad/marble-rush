extends StaticBody3D

var barrier_models: Array[String] = []


func _ready() -> void:
	add_to_group("obstacles")
	_load_random_barrier()


func _load_random_barrier() -> void:
	var dir := DirAccess.open("res://assets/barriers/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var ext := file_name.get_extension().to_lower()
				if ext in ["gltf", "glb", "tscn"]:
					barrier_models.append("res://assets/barriers/" + file_name)
			file_name = dir.get_next()

	if barrier_models.size() > 0:
		var random_path: String = barrier_models[randi() % barrier_models.size()]
		var barrier_scene := load(random_path) as PackedScene
		if barrier_scene:
			var model := barrier_scene.instantiate()
			add_child(model)
