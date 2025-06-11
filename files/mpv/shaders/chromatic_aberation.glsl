//!HOOK MAIN
//!BIND HOOKED
//!DESC Chromatic Aberration Psychedelic

#define ABERRATION_STRENGTH 0.01
#define PULSE_SPEED 3.0
#define COLOR_SHIFT_SPEED 2.0

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
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    // Pulsing aberration strength
    float pulse = sin(time * PULSE_SPEED) * 0.5 + 0.5;
    float aberration = ABERRATION_STRENGTH * (1.0 + pulse);
    
    // Center offset for radial aberration
    vec2 center = pos - 0.5;
    float dist = length(center);
    vec2 offset = normalize(center) * aberration * dist;
    
    // Sample RGB channels at different positions
    float r = HOOKED_tex(pos + offset * 0.5).r;
    float g = HOOKED_tex(pos).g;
    float b = HOOKED_tex(pos - offset * 0.5).b;
    
    vec3 color = vec3(r, g, b);
    
    // Add psychedelic hue shift based on position and time
    vec3 hsv = rgb2hsv(color);
    float hue_offset = sin(time * COLOR_SHIFT_SPEED + pos.x * 10.0 + pos.y * 8.0) * 0.5;
    hsv.x = mod(hsv.x + hue_offset, 1.0);
    
    // Boost saturation for more vivid colors
    hsv.y = min(hsv.y * 1.3, 1.0);
    
    color = hsv2rgb(hsv);
    
    return vec4(color, 1.0);
}
