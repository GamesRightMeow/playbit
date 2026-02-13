#pragma language glsl3

extern vec4 white = vec4(176.0f / 255.0f, 174.0f / 255.0f, 167.0f / 255.0f, 1);
extern vec4 black = vec4( 49.0f / 255.0f,  47.0f / 255.0f,  40.0f / 255.0f, 1);

extern float inverted = 0;
extern vec2  flip = vec2(0, 0);

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    vec2 texCoords = mix(tex_coords, 1.0 - tex_coords, flip);

    vec4 texColor = Texel(tex, texCoords);

    float inColor = mix(texColor.r, 1.0 - texColor.r, inverted);

    return mix(black, white, inColor);
}