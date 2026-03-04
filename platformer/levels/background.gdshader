shader_type canvas_item;
uniform sampler2D noise_tex : repeat_enable;

uniform vec3 base_color = vec3(0.05, 0.0, 0.15);
uniform vec3 target_color = vec3(0.0, 0.45, 0.8);
uniform float blend_amount : hint_range(0.0, 1.0) = 0.0;
uniform float strength: hint_range(0.1, 1.0) = 0.1;

void fragment() {
	vec2 moving_uv = UV + vec2(TIME * 0.01, TIME * 0.03);
	float n = texture(noise_tex, moving_uv).r;
	
	vec3 color_from_noise = base_color + n * strength;
	vec3 blended_color = mix(color_from_noise, target_color + n * clamp(strength, 0.1, 0.4), blend_amount);
	
	COLOR = vec4(blended_color, 1.0);
}