extends Control

var preview_models: Array[Node3D] = [null, null, null, null]

func _ready() -> void:
	_update_buttons()
	for i in range(4):
		_load_preview(i)

func _process(delta: float) -> void:
	for model in preview_models:
		if model:
			model.rotate_y(0.6 * delta)

func _update_buttons() -> void:
	for i in range(4):
		var btn: Button = get_node("Names/Horse%d" % (i + 1))
		var label: String = HorseManager.horse_names[i]
		if i == HorseManager.selected_horse:
			label += "  ★"
		btn.text = label

func _load_preview(index: int) -> void:
	var viewport: SubViewport = get_node("Previews/Slot%d/Viewport" % (index + 1))
	var horse_scene: PackedScene = load(HorseManager.horse_paths[index])
	var model: Node3D = horse_scene.instantiate()
	model.scale = Vector3(1.0, 1.0, 1.0)
	model.position = Vector3(0, -1.0, 0)
	viewport.add_child(model)
	preview_models[index] = model
	var anim_player: AnimationPlayer = _find_animation_player(model)
	if anim_player:
		for anim_name in anim_player.get_animation_list():
			if "idle" in anim_name.to_lower():
				anim_player.play(anim_name)
				break

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result: AnimationPlayer = _find_animation_player(child)
		if result:
			return result
	return null

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
