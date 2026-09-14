extends Node

signal game_over

var is_game_over: bool = false
var coin_score: int = 0

func reset() -> void:
	is_game_over = false
	coin_score = 0

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	SFX.play_gameover()
	emit_signal("game_over")

func add_coin_score(amount: int) -> void:
	if not is_game_over:
		coin_score += amount
		SFX.play_coin()
