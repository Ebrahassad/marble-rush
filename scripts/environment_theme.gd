extends WorldEnvironment

func _ready() -> void:
	var theme_data: Dictionary = ThemeManager.get_current_theme()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = theme_data.sky_top
	sky_material.sky_horizon_color = theme_data.sky_horizon
	sky_material.ground_bottom_color = theme_data.sky_top
	sky_material.ground_horizon_color = theme_data.sky_horizon

	var sky := Sky.new()
	sky.sky_material = sky_material

	var new_environment := Environment.new()
	new_environment.background_mode = Environment.BG_SKY
	new_environment.sky = sky
	new_environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	new_environment.ambient_light_energy = 0.7

	environment = new_environment
