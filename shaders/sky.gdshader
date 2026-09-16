shader_type sky;

uniform vec4 sky_top_color : source_color = vec4(0.101961, 0.043137, 0.180392, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.239216, 0.117647, 0.427451, 1.0);
uniform float star_density = 300.0;

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void sky() {
	float t = clamp(EYEDIR.y * 0.5 + 0.5, 0.0, 1.0);
	vec3 base = mix(sky_horizon_color.rgb, sky_top_color.rgb, pow(t, 0.5));

	vec3 cell = floor(EYEDIR * star_density);
	float h = hash(cell);
	float star = step(0.997, h) * step(0.0, EYEDIR.y);

	COLOR = base + vec3(star);
}
