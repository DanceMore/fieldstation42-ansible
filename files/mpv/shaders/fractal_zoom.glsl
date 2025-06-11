//!HOOK MAIN
//!BIND HOOKED
//!DESC Fractal Color Zoom

#define ZOOM_SPEED 0.3
#define SPIRAL_SPEED 1.0
#define COLOR_LAYERS 3.0

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    // Center coordinates
    vec2 center = pos - 0.5;
    
    // Rotating zoom effect
    float angle = atan(center.y, center.x) + time * SPIRAL_SPEED;
    float radius = length(center);
    
    // Fractal-like layering with different zoom levels
    vec3 final_color = vec3(0.0);
    
    for (float i = 0.0; i < COLOR_LAYERS; i++) {
        float layer_zoom = pow(2.0, i) * (1.0 + sin(time * ZOOM_SPEED) * 0.5);
        float layer_angle = angle + i * 2.0;
        
        vec2 layer_pos = vec2(cos(layer_angle), sin(layer_angle)) * radius * layer_zoom;
        layer_pos = mod(layer_pos + 0.5, 1.0);
        
        vec4 layer_color = HOOKED_tex(layer_pos);
        
        // Generate different hue for each layer
        float hue = mod(i / COLOR_LAYERS + time * 0.5 + radius * 2.0, 1.0);
        vec3 tint = hsv2rgb(vec3(hue, 0.7, 1.0));
        
        final_color += layer_color.rgb * tint / COLOR_LAYERS;
    }
    
    // Mix with original for subtle effect
    vec4 original = HOOKED_tex(pos);
    final_color = mix(original.rgb, final_color, 0.6);
    
    return vec4(final_color, 1.0);
}
