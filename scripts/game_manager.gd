extends Node

signal score_updated(new_score)
signal apples_updated(new_apples)
signal game_over

var score: int = 0
var apples: int = 0
var apple_score: int = 0
var best_score: int = 0
var is_game_over: bool = false

# متوافق مع واجهة HUD القديمة
var coin_score: int:
	get:
		return apple_score

const SAVE_PATH := "user://best_score.save"


func _ready() -> void:
	_load_best_score()
	reset_game()


func reset_game() -> void:
	score = 0
	apples = 0
	apple_score = 0
	is_game_over = false
	emit_signal("score_updated", score)
	emit_signal("apples_updated", apples)


func reset() -> void:
	reset_game()


func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_updated", score)


func add_apples(amount: int = 1) -> void:
	apples += amount
	apple_score += amount * 10
	emit_signal("apples_updated", apples)


func add_coins(amount: int) -> void:
	add_apples(1)


func add_coin_score(amount: int) -> void:
	add_apples(1)


func trigger_game_over() -> void:
	is_game_over = true
	emit_signal("game_over")


func report_final_score(final_score: int) -> void:
	if final_score > best_score:
		best_score = final_score
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
