extends Control

func _ready() -> void:
	_update_buttons()

func _update_buttons() -> void:
	for i in range(4):
		var btn: Button = get_node("Horse%d" % (i + 1))
		var label: String = "Horse %d" % (i + 1)
		if i == HorseManager.selected_horse:
			label += "  (Selected)"
		btn.text = label

func _select(index: int) -> void:
	HorseManager.select_horse(index)
	_update_buttons()

func _on_horse1_pressed() -> void:
	_select(0)

func _on_horse2_pressed() -> void:
	_select(1)

func _on_horse3_pressed() -> void:
	_select(2)

func _on_horse4_pressed() -> void:
	_select(3)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
