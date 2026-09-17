extends Control

var loading: bool = false
var loading_start_time: int = 0
const MIN_LOADING_MS := 600

func _ready() -> void:
	$BestLabel.text = "Best: %d" % GameManager.best_score
	$LoadingPanel.visible = false

func _on_play_pressed() -> void:
	GameManager.reset()
	$PlayButton.disabled = true
	$LoadingPanel.visible = true
	$LoadingPanel/LoadingBar.value = 0.0
	loading_start_time = Time.get_ticks_msec()
	ResourceLoader.load_threaded_request("res://scenes/Main.tscn")
	loading = true

func _process(_delta: float) -> void:
	if not loading:
		return
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status("res://scenes/Main.tscn", progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if progress.size() > 0:
			$LoadingPanel/LoadingBar.value = progress[0] * 100.0
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var elapsed: int = Time.get_ticks_msec() - loading_start_time
		if elapsed < MIN_LOADING_MS:
			$LoadingPanel/LoadingBar.value = 100.0
			await get_tree().create_timer(float(MIN_LOADING_MS - elapsed) / 1000.0).timeout
		loading = false
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get("res://scenes/Main.tscn")
		get_tree().change_scene_to_packed(packed_scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		loading = false
		$LoadingPanel.visible = false
		$PlayButton.disabled = false
