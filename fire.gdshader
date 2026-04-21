shader_type spatial;

render_mode unshaded, cull_disabled;

uniform float speed = 1.5;
uniform float height = 1.0;
uniform vec3 color_bottom : source_color = vec3(1.0, 0.5, 0.0);
uniform vec3 color_top : source_color = vec3(1.0, 1.0, 0.0);

void fragment() {
    float t = TIME * speed;

    // Coordonnées UV
    vec2 uv = UV;

    // Animation verticale
    float wave = sin(uv.y * 10.0 + t * 5.0) * 0.1;

    // Bruit simple
    float noise = fract(sin(dot(uv * 10.0, vec2(12.9898,78.233))) * 43758.5453);

    // Forme du feu (plus fin en haut)
    float shape = smoothstep(0.0, 1.0, uv.y + wave + noise * 0.2);
    shape *= (1.0 - uv.y);

    // Dégradé couleur
    vec3 color = mix(color_bottom, color_top, uv.y);

    ALBEDO = color;
    ALPHA = shape;
}