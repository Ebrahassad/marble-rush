extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HorseShop.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
