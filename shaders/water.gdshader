shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

uniform vec4 water_color : source_color = vec4(0.1, 0.55, 0.9, 0.8);
uniform float speed = 1.6;

void vertex() {
	VERTEX.y += sin(VERTEX.x * 5.0 + TIME * speed) * 0.03 + sin(VERTEX.z * 3.0 + TIME * speed * 0.7) * 0.02;
}

void fragment() {
	float shimmer = sin((UV.x + UV.y) * 20.0 + TIME * speed * 2.0) * 0.08;
	ALBEDO = water_color.rgb + shimmer;
	EMISSION = water_color.rgb * 0.25;
	ALPHA = water_color.a;
}
