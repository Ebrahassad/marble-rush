shader_type sky;

uniform vec4 sky_top_color : source_color = vec4(0.15, 0.45, 0.85, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.75, 0.85, 0.95, 1.0);
uniform vec3 sun_direction = vec3(0.3, 0.5, 0.8);
uniform float sun_size = 0.015;
uniform float cloud_coverage = 0.55;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amp * value_noise(p);
		p *= 2.0;
		amp *= 0.5;
	}
	return value;
}

void sky() {
	float t = clamp(EYEDIR.y, 0.0, 1.0);
	vec3 base = mix(sky_horizon_color.rgb, sky_top_color.rgb, pow(t, 0.45));

	float sun_dot = max(dot(EYEDIR, normalize(sun_direction)), 0.0);
	float sun_disc = smoothstep(1.0 - sun_size, 1.0 - sun_size * 0.4, sun_dot);
	float corona = pow(sun_dot, 128.0) * 0.6 + pow(sun_dot, 8.0) * 0.25;

	vec2 cloud_uv = EYEDIR.xz / max(EYEDIR.y, 0.05) * 0.15;
	float cloud_density = fbm(cloud_uv);
	float cloud_mask = smoothstep(cloud_coverage, cloud_coverage + 0.25, cloud_density) * smoothstep(0.02, 0.25, EYEDIR.y);

	vec3 color = base + vec3(1.0, 0.98, 0.92) * (sun_disc * 3.0 + corona);
	color = mix(color, vec3(1.0, 1.0, 1.0), cloud_mask * 0.85);

	COLOR = color;
}
