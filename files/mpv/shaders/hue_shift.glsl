//!HOOK MAIN
//!BIND HOOKED
//!DESC Dynamic Hue Shift

// Animation speed (higher = faster cycling)
#define SPEED 0.5

// Hue shift intensity (0-360 degrees maximum shift)
#define INTENSITY 360.0

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    
    // Get current time for animation
    float time = frame / 60.0; // Assuming 60fps, adjust as needed
    
    // Create sinusoidal hue shift
    float hue_offset = sin(time * SPEED) * (INTENSITY / 360.0);
    
    // Convert RGB to HSV
    vec3 hsv = rgb2hsv(color.rgb);
    
    // Apply animated hue shift
    hsv.x = mod(hsv.x + hue_offset, 1.0);
    
    // Convert back to RGB
    vec3 shifted = hsv2rgb(hsv);
    
    return vec4(shifted, color.a);
}
