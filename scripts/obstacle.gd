extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body.is_in_group("player"):
		if SfxManager:
			SfxManager.play_gameover()
		GameManager.trigger_game_over()
