//!HOOK MAIN
//!BIND HOOKED
//!DESC Vintage Sepia

vec4 hook() {
    vec2 pos = HOOKED_pos;
    vec4 color = HOOKED_tex(pos);
    
    // Better sepia conversion with proper color mixing
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // More authentic sepia colors
    vec3 sepia = vec3(
        gray * 1.2,
        gray * 1.0, 
        gray * 0.8
    );
    
    // Blend sepia with original color
    color.rgb = mix(color.rgb, sepia, 0.75);
    
    // Smooth vignette that doesn't look harsh
    vec2 center = pos - 0.5;
    float dist = length(center);
    float vignette = 1.0 - dist * dist * 1.5;
    vignette = max(vignette, 0.3);
    color.rgb *= vignette;
    
    // Slight warmth boost
    color.r *= 1.05;
    color.g *= 1.02;
    
    return color;
}
