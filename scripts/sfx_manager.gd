extends Node

var jump_sound: AudioStream = preload("res://assets/sounds/jump.ogg")
var coin_sound: AudioStream = preload("res://assets/sounds/coin.ogg")
var gameover_sound: AudioStream = preload("res://assets/sounds/gameover.ogg")

func play_jump() -> void:
	_play(jump_sound)

func play_coin() -> void:
	_play(coin_sound)

func play_gameover() -> void:
	_play(gameover_sound)

func _play(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)
