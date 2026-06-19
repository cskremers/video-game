shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 4.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.05, 0.08, 0.15, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	float a = tex.a;
	a = max(a, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV + vec2(-px.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
	a = max(a, texture(TEXTURE, UV + vec2(0.0, -px.y)).a);
	vec4 outline = mix(outline_color, tex * tint_color, tex.a);
	COLOR = vec4(outline.rgb, max(tex.a, a * 0.85));
}
