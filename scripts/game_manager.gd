extends Node

signal game_over

var is_game_over: bool = false
var coin_score: int = 0
var best_score: int = 0
var last_score: int = 0

const SAVE_PATH := "user://highscore.save"

func _ready() -> void:
	_load_best_score()

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

func report_final_score(total: int) -> void:
	last_score = total
	if total > best_score:
		best_score = total
		_save_best_score()

func _load_best_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		best_score = file.get_32()
		file.close()

func _save_best_score() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(best_score)
	file.close()
