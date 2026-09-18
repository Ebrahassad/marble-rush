extends Node

var themes: Dictionary = {
	"royal_gold": {
		"ball_color": Color(0.83, 0.68, 0.21),
		"ball_emission": Color(0.6, 0.45, 0.05),
		"track_color": Color(0.16, 0.08, 0.27),
		"sky_top": Color(0.15, 0.45, 0.85),
		"sky_horizon": Color(0.75, 0.85, 0.95),
	}
}

var current_theme: String = "royal_gold"

func get_current_theme() -> Dictionary:
	return themes[current_theme]

func set_theme(theme_name: String) -> void:
	if themes.has(theme_name):
		current_theme = theme_name
