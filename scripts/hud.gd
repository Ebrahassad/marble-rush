extends CanvasLayer

@export var ball_path: NodePath
var ball: Node3D
var current_total: int = 0

func _ready() -> void:
	ball = get_node(ball_path)
	GameManager.game_over.connect(_on_game_over)
	$GameOverPanel.visible = false

func _process(_delta: float) -> void:
	if ball and not GameManager.is_game_over:
		var distance: int = int(-ball.global_position.z)
		current_total = max(distance, 0) + GameManager.coin_score
		$ScoreLabel.text = "Score: %d" % current_total

func _on_game_over() -> void:
	GameManager.report_final_score(current_total)
	$GameOverPanel/FinalScoreLabel.text = "Score: %d\nBest: %d" % [current_total, GameManager.best_score]
	$GameOverPanel.visible = true

func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()
