shader_type spatial;
render_mode blend_mix, cull_disabled;

uniform vec4 water_color : source_color = vec4(0.08, 0.45, 0.85, 0.75);
uniform vec4 water_color_deep : source_color = vec4(0.03, 0.2, 0.5, 0.85);
uniform float speed = 1.2;
uniform float wave_scale = 8.0;

float wave_height(vec2 pos, float t) {
	return sin(pos.x * wave_scale + t) * 0.5 + sin(pos.y * wave_scale * 0.7 - t * 1.3) * 0.5;
}

void vertex() {
	float h = wave_height(VERTEX.xz, TIME * speed);
	VERTEX.y += h * 0.04;
}

void fragment() {
	float t = TIME * speed;
	float eps = 0.05;
	float h_c = wave_height(UV * 10.0, t);
	float h_x = wave_height(UV * 10.0 + vec2(eps, 0.0), t);
	float h_z = wave_height(UV * 10.0 + vec2(0.0, eps), t);
	vec3 fake_normal = normalize(vec3(-(h_x - h_c), eps * 4.0, -(h_z - h_c)));

	NORMAL = fake_normal;
	float pattern = h_c * 0.5 + 0.5;
	ALBEDO = mix(water_color_deep.rgb, water_color.rgb, pattern);
	ROUGHNESS = 0.15;
	METALLIC = 0.1;
	SPECULAR = 0.8;
	ALPHA = mix(water_color_deep.a, water_color.a, pattern);
}
