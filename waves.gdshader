shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 20.0) = 2; // wave height
uniform float frequency : hint_range(0.0, 10.0) = 10.0; // wave density
uniform float speed : hint_range(0.0, 10.0) = 0.25;     // wave speed

void fragment() {
    float t = TIME * speed;

    float wave_x = sin(UV.y * frequency + t) * amplitude / 100.0;
    float wave_y = cos(UV.x * frequency + t) * amplitude / 100.0;

    vec2 distorted_uv = UV + vec2(wave_x, wave_y);

    COLOR = texture(TEXTURE, distorted_uv);
}
