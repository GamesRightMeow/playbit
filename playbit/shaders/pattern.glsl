#pragma language glsl3

extern float pattern[64];

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    // Use mod() to get the position of the current pixel within the 8x8 pattern
    int x = int(mod(screen_coords.x, 8.0));
    int y = int(mod(screen_coords.y, 8.0));

    float outColor = pattern[x + y * 8];
    float outAlpha = 1;

    return vec4(outColor, outColor, outColor, outAlpha);
}
