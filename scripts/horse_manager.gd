extends Node

const SAVE_PATH := "user://horse_select.save"
var selected_horse: int = 0
var horse_paths: Array[String] = [
	"res://assets/horses/horse-01.glb",
	"res://assets/horses/horse-02.glb",
	"res://assets/horses/horse-03.glb",
	"res://assets/horses/horse-04.glb",
]
var horse_names: Array[String] = ["Thunder", "Blaze", "Storm", "Shadow"]
var horse_colors: Array[Color] = [
	Color(0.08, 0.07, 0.07),
	Color(0.55, 0.18, 0.08),
	Color(0.85, 0.85, 0.88),
	Color(0.32, 0.22, 0.12),
]

func _ready() -> void:
	_load()

func get_selected_path() -> String:
	return horse_paths[selected_horse]

func select_horse(index: int) -> void:
	selected_horse = clamp(index, 0, horse_paths.size() - 1)
	_save()

func apply_horse_color(model: Node, index: int) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = horse_colors[index]
	mat.roughness = 0.6
	mat.metallic = 0.05
	_tint_recursive(model, mat)

func _tint_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_tint_recursive(child, mat)

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		selected_horse = file.get_32()
		file.close()

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(selected_horse)
	file.close()
