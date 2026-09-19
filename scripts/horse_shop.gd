extends Control

var preview_model: Node3D = null

func _ready() -> void:
	_update_buttons()
	_load_preview(HorseManager.selected_horse)

func _process(delta: float) -> void:
	if preview_model:
		preview_model.rotate_y(0.8 * delta)

func _update_buttons() -> void:
	for i in range(4):
		var btn: Button = get_node("Horse%d" % (i + 1))
		var label: String = "Horse %d" % (i + 1)
		if i == HorseManager.selected_horse:
			label += "  (Selected)"
		btn.text = label

func _load_preview(index: int) -> void:
	if preview_model:
		preview_model.queue_free()
		preview_model = null
	var horse_scene: PackedScene = load(HorseManager.horse_paths[index])
	preview_model = horse_scene.instantiate()
	preview_model.scale = Vector3(0.9, 0.9, 0.9)
	preview_model.position = Vector3(0, -1.1, 0)
	$PreviewViewportContainer/PreviewViewport.add_child(preview_model)
	var anim_player: AnimationPlayer = _find_animation_player(preview_model)
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
	_load_preview(index)

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
