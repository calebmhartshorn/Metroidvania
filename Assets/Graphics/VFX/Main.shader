shader_type canvas_item;

uniform float hdr_threshold = 0.1;
uniform bool flip = false;

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
	return max(textureLod(tex, uv, 3) - hdr_threshold, vec4(0.0));
}

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	// Get blurred color from pixels considered glowing
	vec4 col0 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
	vec4 col1 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
	vec4 col2 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
	vec4 col3 = sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));
	
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 glowing_col = 0.25 * (col0 + col1 + col2 + col3);
	
	col = vec4(col.rgb + glowing_col.rgb, col.a);
	
	col.rgb += vec3(0.015, 0.0095, 0.015);
	
	col.rgb = pow(col.rgb, vec3(1));

	col.rgb *= vec3(1.5);

	
	vec2 offset = (SCREEN_UV - 0.5) ;
	col.rgb -= vec3(length(offset) * 0.1);
	
	if (flip) {
		COLOR = vec4(vec3(1) - col.rgb, 1);
	} else {
		COLOR = vec4(col.rgb,1);
	}
}