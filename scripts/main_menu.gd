extends Control

func _ready() -> void:
	$BestLabel.text = "Best: %d" % GameManager.best_score

func _on_play_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
