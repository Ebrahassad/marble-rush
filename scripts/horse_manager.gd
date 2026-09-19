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

func _ready() -> void:
	_load()

func get_selected_path() -> String:
	return horse_paths[selected_horse]

func select_horse(index: int) -> void:
	selected_horse = clamp(index, 0, horse_paths.size() - 1)
	_save()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		selected_horse = file.get_32()
		file.close()

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(selected_horse)
	file.close()
