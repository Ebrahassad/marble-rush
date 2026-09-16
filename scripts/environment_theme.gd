extends WorldEnvironment

func _ready() -> void:
	var theme_data: Dictionary = ThemeManager.get_current_theme()
	var sky_shader: Shader = load("res://shaders/sky.gdshader")
	var sky_material := ShaderMaterial.new()
	sky_material.shader = sky_shader
	sky_material.set_shader_parameter("sky_top_color", theme_data.sky_top)
	sky_material.set_shader_parameter("sky_horizon_color", theme_data.sky_horizon)

	var sky := Sky.new()
	sky.sky_material = sky_material

	var new_environment := Environment.new()
	new_environment.background_mode = Environment.BG_SKY
	new_environment.sky = sky
	new_environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	new_environment.ambient_light_energy = 0.7

	new_environment.fog_enabled = true
	new_environment.fog_light_color = theme_data.sky_horizon
	new_environment.fog_light_energy = 1.0
	new_environment.fog_depth_begin = 20.0
	new_environment.fog_depth_end = 95.0

	environment = new_environment
