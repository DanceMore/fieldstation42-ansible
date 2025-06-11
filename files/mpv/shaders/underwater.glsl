//!HOOK MAIN
//!BIND HOOKED
//!DESC Underwater Enhanced

#define WAVE_SPEED 2.0
#define WAVE_INTENSITY 0.025
#define CAUSTIC_SPEED 1.2
#define DEPTH_TINT vec3(0.2, 0.6, 0.9)
#define REFRACTION_STRENGTH 0.035

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    // Enhanced water refraction with multiple wave layers
    // Primary wave - larger, slower undulation
    float wave1 = sin(pos.y * 15.0 + time * WAVE_SPEED) * WAVE_INTENSITY;
    float wave2 = cos(pos.x * 12.0 + time * WAVE_SPEED * 0.8) * WAVE_INTENSITY;
    
    // Secondary waves - faster, smaller ripples
    float wave3 = sin(pos.x * 45.0 + time * WAVE_SPEED * 2.5) * WAVE_INTENSITY * 0.6;
    float wave4 = cos(pos.y * 40.0 + time * WAVE_SPEED * 1.8) * WAVE_INTENSITY * 0.6;
    
    // Diagonal waves for more complex interaction
    float wave5 = sin((pos.x + pos.y) * 25.0 + time * WAVE_SPEED * 1.5) * WAVE_INTENSITY * 0.4;
    float wave6 = cos((pos.x - pos.y) * 30.0 - time * WAVE_SPEED * 1.2) * WAVE_INTENSITY * 0.4;
    
    // Combine waves with different directions for back-and-forth effect
    vec2 distortion = vec2(
        wave1 + wave3 + wave5 + sin(pos.y * 8.0 + time * WAVE_SPEED * 0.5) * REFRACTION_STRENGTH,
        wave2 + wave4 + wave6 + cos(pos.x * 10.0 + time * WAVE_SPEED * 0.7) * REFRACTION_STRENGTH
    );
    
    // Sample with distortion
    vec2 distorted = pos + distortion;
    vec4 color = HOOKED_tex(distorted);
    
    // Enhanced caustics with more variation
    float caustic1 = sin(pos.x * 50.0 + time * CAUSTIC_SPEED) * sin(pos.y * 35.0 + time * CAUSTIC_SPEED * 0.9);
    float caustic2 = cos(pos.x * 42.0 - time * CAUSTIC_SPEED * 0.7) * cos(pos.y * 38.0 - time * CAUSTIC_SPEED * 1.1);
    float caustic3 = sin((pos.x + pos.y) * 60.0 + time * CAUSTIC_SPEED * 1.3) * 0.5;
    
    float caustics = (caustic1 + caustic2 + caustic3) * 0.08 + 0.12;
    caustics = max(0.0, caustics);
    
    // Stronger underwater color grading
    color.rgb = mix(color.rgb, color.rgb * DEPTH_TINT, 0.6);
    
    // Dynamic caustic lighting with color variation
    vec3 caustic_color = vec3(0.3, 0.5, 0.8) + vec3(0.2, 0.3, 0.4) * sin(time * 2.0);
    color.rgb += caustics * caustic_color;
    
    // Depth gradient (more pronounced)
    float depth_fade = 1.0 - pow(pos.y, 1.5) * 0.4;
    color.rgb *= depth_fade;
    
    // Animated depth shimmer
    float shimmer = sin(pos.x * 100.0 + time * 3.0) * cos(pos.y * 80.0 + time * 2.5) * 0.03;
    color.rgb += vec3(shimmer * 0.5, shimmer, shimmer * 1.5);
    
    // Subtle vignette for immersion
    float vignette = 1.0 - length(pos - 0.5) * 0.8;
    color.rgb *= vignette;
    
    // Bubble effect (more subtle but present)
    float bubble_pattern = sin(pos.x * 180.0 + time * 5.0) * sin(pos.y * 120.0 + time * 4.0);
    if (bubble_pattern > 0.97) {
        color.rgb += vec3(0.05, 0.1, 0.15);
    }
    
    return color;
}
