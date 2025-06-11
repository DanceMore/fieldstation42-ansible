//!HOOK MAIN
//!BIND HOOKED
//!DESC Rainbow Wave Distortion

#define WAVE_SPEED 2.0
#define WAVE_INTENSITY 0.3
#define COLOR_SPEED 1.5

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    // Create wave distortion
    float wave1 = sin(pos.y * 20.0 + time * WAVE_SPEED) * WAVE_INTENSITY;
    float wave2 = cos(pos.x * 15.0 + time * WAVE_SPEED * 0.7) * WAVE_INTENSITY;
    
    // Distort sampling position
    vec2 distorted_pos = pos + vec2(wave1, wave2) * 0.02;
    vec4 color = HOOKED_tex(distorted_pos);
    
    // Add rainbow overlay based on position and time
    float hue = mod(pos.x + pos.y + time * COLOR_SPEED, 1.0);
    vec3 rainbow = hsv2rgb(vec3(hue, 0.6, 1.0));
    
    // Blend with original color
    color.rgb = mix(color.rgb, rainbow * color.rgb, 0.4);
    
    return color;
}
