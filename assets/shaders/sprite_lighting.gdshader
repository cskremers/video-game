shader_type canvas_item;

uniform vec4 ambient_color : source_color = vec4(0.15, 0.18, 0.28, 1.0);
uniform vec4 highlight_color : source_color = vec4(1.0, 0.95, 0.85, 1.0);
uniform vec2 light_direction = vec2(-0.4, -0.9);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 lit = mix(ambient_color.rgb, highlight_color.rgb, clamp(dot(normalize(light_direction), vec2(0.0, -1.0)) * 0.5 + 0.5, 0.0, 1.0));
	COLOR = vec4(tex.rgb * lit, tex.a);
}
