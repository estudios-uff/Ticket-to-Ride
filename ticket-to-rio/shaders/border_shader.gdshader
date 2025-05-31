shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Azul Padrão
uniform float border_pixel_width : hint_range(0.0, 20.0) = 5.0;
uniform bool draw_border = false;

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE; // Tamanho de um pixel no espaço UV (0-1)
    vec4 original_color = texture(TEXTURE, UV); // Cor original da textura no pixel atual

    if (draw_border && textureSize(TEXTURE, 0).x > 0) {
        float border_uv_width_x = border_pixel_width * pixel_size.x;
        float border_uv_width_y = border_pixel_width * pixel_size.y;

        if (UV.x < border_uv_width_x || UV.x > 1.0 - border_uv_width_x ||
            UV.y < border_uv_width_y || UV.y > 1.0 - border_uv_width_y) {
            COLOR = border_color;
        } else {
            COLOR = original_color;
        }
    } else {
        COLOR = original_color;
    }
}