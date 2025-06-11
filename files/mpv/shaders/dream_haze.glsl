//!HOOK MAIN
//!BIND HOOKED
//!DESC Dream Haze

#define BLUR_AMOUNT 0.003
#define GLOW_INTENSITY 0.2
#define DRIFT_SPEED 0.5

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    // Soft blur effect
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    // Simple gaussian-like blur
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * BLUR_AMOUNT;
            float weight = 1.0 / (1.0 + length(offset) * 3.0);
            color += HOOKED_tex(pos + offset) * weight;
            total_weight += weight;
        }
    }
    color /= total_weight;
    
    // Dreamy glow
    vec4 bright_pass = max(color - 0.5, 0.0) * 2.0;
    color += bright_pass * GLOW_INTENSITY;
    
    // Soft color grading (slightly warm and desaturated)
    color.r *= 1.1;
    color.g *= 1.05;
    color.b *= 0.95;
    
    // Gentle floating motion
    float drift_x = sin(time * DRIFT_SPEED + pos.y * 3.0) * 0.001;
    float drift_y = cos(time * DRIFT_SPEED * 0.7 + pos.x * 2.0) * 0.001;
    vec4 drifted = HOOKED_tex(pos + vec2(drift_x, drift_y));
    
    color = mix(color, drifted, 0.3);
    
    // Soft vignette
    vec2 center = pos - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.5;
    color.rgb *= vignette;
    
    return color;
}
