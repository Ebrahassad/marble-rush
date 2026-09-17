shader_type sky;

uniform vec4 sky_top_color : source_color = vec4(0.25, 0.5, 0.85, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.95, 0.78, 0.55, 1.0);
uniform vec3 sun_direction = vec3(0.3, 0.35, 0.85);
uniform float sun_size = 0.02;

void sky() {
	float t = clamp(EYEDIR.y * 0.5 + 0.5, 0.0, 1.0);
	vec3 base = mix(sky_horizon_color.rgb, sky_top_color.rgb, pow(t, 0.6));

	float sun_dot = max(dot(EYEDIR, normalize(sun_direction)), 0.0);
	float sun_disc = smoothstep(1.0 - sun_size, 1.0 - sun_size * 0.3, sun_dot);
	float sun_glow = pow(sun_dot, 8.0) * 0.5;

	COLOR = base + vec3(1.0, 0.85, 0.5) * (sun_disc * 2.0 + sun_glow);
}
