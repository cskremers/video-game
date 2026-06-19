shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float saturation : hint_range(0.0, 2.0) = 1.1;

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 centered = SCREEN_UV - 0.5;
	float vignette = 1.0 - dot(centered, centered) * vignette_strength * 4.0;
	float luma = dot(screen.rgb, vec3(0.299, 0.587, 0.114));
	vec3 grey = vec3(luma);
	vec3 color = mix(grey, screen.rgb, saturation) * vignette;
	COLOR = vec4(color, screen.a);
}
