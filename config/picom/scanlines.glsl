#version 330

in vec2 texcoord;
uniform sampler2D tex;

vec4 default_post_processing(vec4 c);

vec4 window_shader() {
    vec2 texsize = vec2(textureSize(tex, 0));
    vec4 c = texture(tex, texcoord / texsize);

    // Subtle CRT scanlines: darken alternating pixel rows.
    float row = mod(floor(texcoord.y / 3.0), 2.0);
    c.rgb *= mix(0.84, 1.0, row);

    return default_post_processing(c);
}
