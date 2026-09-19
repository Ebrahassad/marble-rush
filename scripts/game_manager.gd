extends Node

signal score_updated(new_score)
signal coins_updated(new_coins)
signal game_over

var score: int = 0
var coins: int = 0


func _ready() -> void:
	reset_game()


func reset_game() -> void:
	score = 0
	coins = 0
	emit_signal("score_updated", score)
	emit_signal("coins_updated", coins)


func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_updated", score)


func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_updated", coins)


func trigger_game_over() -> void:
	emit_signal("game_over")
