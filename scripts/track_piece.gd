extends StaticBody3D


func _ready() -> void:
	var track_path := "res://assets/track/scene.gltf"
	if ResourceLoader.exists(track_path):
		var track_scene := load(track_path) as PackedScene
		if track_scene:
			var model := track_scene.instantiate()
			model.rotation_degrees.y = 90
			add_child(model)
