shader_type canvas_item;
render_mode blend_sub;

void fragment() {
    COLOR = vec4(1.0); // 纯白色，用于“相消”
}