shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

uniform vec4 water_color : source_color = vec4(0.08, 0.45, 0.85, 0.75);
uniform vec4 water_color_deep : source_color = vec4(0.03, 0.2, 0.5, 0.85);
uniform float speed = 1.2;

void vertex() {
	VERTEX.y += sin(VERTEX.x * 6.0 + TIME * speed) * 0.025 + sin(VERTEX.z * 4.0 - TIME * speed * 0.8) * 0.02;
}

void fragment() {
	float wave1 = sin(UV.x * 14.0 + UV.y * 6.0 + TIME * speed * 1.5);
	float wave2 = sin(UV.x * 5.0 - UV.y * 11.0 - TIME * speed * 1.1);
	float wave3 = sin((UV.x + UV.y) * 9.0 + TIME * speed * 0.6);
	float pattern = (wave1 + wave2 + wave3) / 3.0;

	vec3 color = mix(water_color_deep.rgb, water_color.rgb, 0.5 + 0.5 * pattern);
	float sparkle = smoothstep(0.85, 1.0, wave1 * wave2);
	color += sparkle * 0.5;

	ALBEDO = color;
	EMISSION = color * 0.3;
	ALPHA = mix(water_color_deep.a, water_color.a, 0.5 + 0.5 * pattern);
}
