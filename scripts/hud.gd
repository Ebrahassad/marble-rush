extends CanvasLayer

@export var ball_path: NodePath
var ball: Node3D
var current_total: int = 0

func _ready() -> void:
	ball = get_node(ball_path)
	GameManager.game_over.connect(_on_game_over)
	GameManager.hit_taken.connect(_on_hit_taken)
	$GameOverPanel.visible = false
	$PausePanel.visible = false
	$PausePanel.process_mode = Node.PROCESS_MODE_ALWAYS
	$PauseButton.process_mode = Node.PROCESS_MODE_ALWAYS
	_on_hit_taken()

func _process(_delta: float) -> void:
	if ball and not GameManager.is_game_over:
		var distance: int = int(-ball.global_position.z)
		current_total = max(distance, 0) + GameManager.coin_score
		$ScoreLabel.text = "Score: %d" % current_total

func _on_hit_taken() -> void:
	$HitsLabel.text = "Hits: %d" % GameManager.hit_points

func _on_game_over() -> void:
	GameManager.report_final_score(current_total)
	$GameOverPanel/FinalScoreLabel.text = "Score: %d\nBest: %d" % [current_total, GameManager.best_score]
	$GameOverPanel.visible = true

func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_pause_pressed() -> void:
	if GameManager.is_game_over:
		return
	get_tree().paused = true
	$PausePanel.visible = true

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$PausePanel.visible = false

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
