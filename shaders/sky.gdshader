shader_type sky;

uniform vec4 sky_top_color : source_color = vec4(0.15, 0.45, 0.85, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.75, 0.85, 0.95, 1.0);
uniform vec3 sun_direction = vec3(0.3, 0.5, 0.8);
uniform float sun_size = 0.015;

void sky() {
	float t = clamp(EYEDIR.y, 0.0, 1.0);
	vec3 base = mix(sky_horizon_color.rgb, sky_top_color.rgb, pow(t, 0.45));

	float sun_dot = max(dot(EYEDIR, normalize(sun_direction)), 0.0);
	float sun_disc = smoothstep(1.0 - sun_size, 1.0 - sun_size * 0.4, sun_dot);
	float corona = pow(sun_dot, 128.0) * 0.6 + pow(sun_dot, 8.0) * 0.25;

	COLOR = base + vec3(1.0, 0.98, 0.92) * (sun_disc * 3.0 + corona);
}
