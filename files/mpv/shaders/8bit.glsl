//!HOOK MAIN
//!BIND HOOKED
//!DESC 8-bit pixelation effect

// Adjustable parameters
#define PIXEL_SIZE 8.0      // Higher = more pixelated (2.0 to 8.0 recommended)
#define COLOR_LEVELS 8.0    // Color quantization levels (4.0 to 16.0)
#define DITHERING 0.5       // Dithering amount (0.0 to 1.0)

vec4 hook() {
    vec2 tex_size = textureSize(HOOKED_raw, 0);
    vec2 uv = HOOKED_pos;
    
    // Pixelation effect
    vec2 pixel_size = vec2(PIXEL_SIZE) / tex_size;
    vec2 pixelated_uv = floor(uv / pixel_size) * pixel_size + pixel_size * 0.5;
    
    // Sample the texture
    vec4 color = texture(HOOKED_raw, pixelated_uv);
    
    // Simple ordered dithering pattern
    float dither_pattern = mod(gl_FragCoord.x + gl_FragCoord.y, 4.0) / 4.0;
    dither_pattern = (dither_pattern - 0.5) * DITHERING / COLOR_LEVELS;
    
    // Quantize colors to create 8-bit look
    color.rgb += vec3(dither_pattern);
    color.rgb = floor(color.rgb * COLOR_LEVELS) / COLOR_LEVELS;
    
    // Clamp to valid range
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    return color;
}
