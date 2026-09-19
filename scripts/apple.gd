extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D or body.is_in_group("player"):
		GameManager.add_apples(1)
		if SfxManager:
			if SfxManager.has_method("play_apple"):
				SfxManager.play_apple()
			elif SfxManager.has_method("play_coin"):
				SfxManager.play_coin()
		queue_free()
