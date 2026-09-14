extends Node

signal game_over

var is_game_over: bool = false

func reset() -> void:
	is_game_over = false

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	emit_signal("game_over")
