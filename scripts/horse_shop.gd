extends Control

var preview_model: Node3D = null
var stable_model: Node3D = null


func _ready() -> void:
	_update_buttons()
	_load_stable_environment()
	_load_preview(HorseManager.selected_horse)


func _load_stable_environment() -> void:
	var stable_path := "res://assets/stable/scene.gltf"
	if ResourceLoader.exists(stable_path):
		var stable_scene := load(stable_path) as PackedScene
		if stable_scene:
			stable_model = stable_scene.instantiate()
			stable_model.position = Vector3(0, -1.5, 0)
			$StableViewportContainer/StableViewport/PreviewAnchor.add_child(stable_model)


func _process(delta: float) -> void:
	if preview_model:
		preview_model.rotate_y(0.7 * delta)


func _update_buttons() -> void:
	for i in range(4):
		var btn: Button = get_node("Horse%d" % (i + 1))
		var label: String = HorseManager.horse_names[i]
		if i == HorseManager.selected_horse:
			label += "  ★"
		btn.text = label


func _load_preview(index: int) -> void:
	if preview_model:
		preview_model.queue_free()
		preview_model = null
	var horse_scene: PackedScene = load(HorseManager.horse_paths[index])
	preview_model = horse_scene.instantiate()
	preview_model.scale = Vector3(2.6, 2.6, 2.6)
	preview_model.position = Vector3(0, -1.6, 2.5)
	$StableViewportContainer/StableViewport/PreviewAnchor.add_child(preview_model)
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
