#pragma language glsl3

extern vec4 drawColor;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    float outColor = drawColor.r;
    float outAlpha = drawColor.a;

    return vec4(outColor, outColor, outColor, outAlpha);
}
