shader_type canvas_item;
uniform sampler2D noise_tex : repeat_enable;

void fragment() {
    vec2 moving_uv = UV + vec2(TIME * 0.01, TIME * 0.03);
    float n = texture(noise_tex, moving_uv).r;
    COLOR = vec4(vec3(0.05, 0.0, 0.15) + n * 0.1, 1.0);
}