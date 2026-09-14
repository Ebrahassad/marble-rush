extends CanvasLayer

@export var ball_path: NodePath
var ball: Node3D

func _ready() -> void:
	ball = get_node(ball_path)
	GameManager.game_over.connect(_on_game_over)
	$GameOverPanel.visible = false

func _process(_delta: float) -> void:
	if ball and not GameManager.is_game_over:
		var distance: int = int(-ball.global_position.z)
		$ScoreLabel.text = "Score: %d" % max(distance, 0)

func _on_game_over() -> void:
	$GameOverPanel.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
