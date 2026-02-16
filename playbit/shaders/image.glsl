#pragma language glsl3

extern Image canvas;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    vec4  texColor   = Texel(tex, tex_coords);
    float grayscale  = dot(texColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    float inColor    = step(0.5, grayscale);
    float inAlpha    = step(0.5, texColor.a);

#if DRAW_MODE == 1   // White Transparent
    float outColor   = inColor;
    float outAlpha   = inAlpha * (1.0 - inColor);

#elif DRAW_MODE == 2 // Black Transparent
    float outColor   = inColor;
    float outAlpha   = inAlpha * inColor;

#elif DRAW_MODE == 3 // Fill White
    float outColor   = 1;
    float outAlpha   = inAlpha;

#elif DRAW_MODE == 4 // Fill Black
    float outColor   = 0;
    float outAlpha   = inAlpha;

#elif DRAW_MODE == 5 // XOR
    vec4 canvasColor = Texel(canvas, screen_coords / love_ScreenSize.xy);
    float outColor   = abs(canvasColor.r - inColor);
    float outAlpha   = inAlpha;

#elif DRAW_MODE == 6 // NXOR
    vec4 canvasColor = Texel(canvas, screen_coords / love_ScreenSize.xy);
    float outColor   = 1.0 - abs(canvasColor.r - inColor);
    float outAlpha   = inAlpha;

#elif DRAW_MODE == 7 // Inverted
    float outColor   = 1.0 - inColor;
    float outAlpha   = inAlpha;

#else                // Copy
    float outColor   = inColor;
    float outAlpha   = inAlpha;

#endif

    return vec4(outColor, outColor, outColor,  outAlpha);
}
