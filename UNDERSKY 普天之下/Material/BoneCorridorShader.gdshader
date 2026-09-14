shader_type canvas_item;

// ========== 基础扭曲 ==========
uniform float distort_strength: hint_range(0.0, 0.15) = 0.05;
uniform float wave_frequency: hint_range(1.0, 15.0) = 6.0;
uniform float flow_speed: hint_range(0.0, 3.0) = 1.0;
uniform float depth_falloff: hint_range(0.0, 1.0) = 0.6;
uniform float vertical_twist: hint_range(0.0, 0.08) = 0.02;

// ========== 故障撕裂 ==========
uniform float glitch_intensity: hint_range(0.0, 0.2) = 0.04;
uniform float split_offset: hint_range(0.0, 0.15) = 0.03;
uniform float edge_range: hint_range(0.0, 0.4) = 0.3;

void fragment() {
    vec2 uv = UV;
    float time = TIME * flow_speed;

    // 基础扭曲
    float depth = pow(uv.y, depth_falloff);
    float wave_x = sin(uv.y * wave_frequency + time) * distort_strength * depth;
    float wave_y = cos(uv.x * wave_frequency * 0.8 - time * 0.6) * vertical_twist * depth;
    vec2 distort_uv = uv + vec2(wave_x, wave_y);

    // 边缘撕裂
    float edge = 1.0 - smoothstep(0.0, edge_range, min(uv.x, 1.0 - uv.x));
    float glitch_shift = sin(time * 12.0 + uv.y * 20.0) * glitch_intensity * edge;
    distort_uv.x += glitch_shift;

    // 颜色采样 (RGB 分离)
    vec4 col_r = texture(TEXTURE, distort_uv + vec2(split_offset * edge, 0.0));
    vec4 col_gb = texture(TEXTURE, distort_uv - vec2(split_offset * edge, 0.0));
    vec4 tex_color;
    tex_color.r = col_r.r;
    tex_color.g = col_gb.g;
    tex_color.b = col_gb.b;
    tex_color.a = col_r.a;

    COLOR = tex_color;
}