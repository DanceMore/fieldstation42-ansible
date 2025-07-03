//!HOOK MAIN
//!BIND HOOKED
//!DESC Bardo Realm - Tibetan Death Art

#define FLAME_SPEED 2.5
#define MANDALA_ROTATION 0.8
#define WRATHFUL_INTENSITY 0.15
#define JEWEL_COLORS vec3(0.9, 0.2, 0.8), vec3(0.2, 0.8, 0.9), vec3(0.9, 0.8, 0.2), vec3(0.8, 0.2, 0.2), vec3(0.2, 0.9, 0.3)

vec3 getJewelColor(int index) {
    vec3 colors[5] = vec3[5](JEWEL_COLORS);
    return colors[index % 5];
}

vec4 hook() {
    vec2 pos = HOOKED_pos;
    vec2 center = pos - 0.5;
    float time = frame / 60.0;
    float radius = length(center);
    float angle = atan(center.y, center.x);
    
    // Rotating mandala pattern (Wheel of Samsara)
    float mandala_angle = angle + time * MANDALA_ROTATION;
    float mandala_rings = sin(radius * 40.0 + time) * cos(mandala_angle * 8.0);
    float mandala_spokes = sin(mandala_angle * 16.0) * exp(-radius * 3.0);
    
    // Wrathful deity flames (dancing around edges)
    float flame1 = sin(angle * 6.0 + time * FLAME_SPEED + radius * 20.0) * exp(-radius * 2.0);
    float flame2 = cos(angle * 9.0 - time * FLAME_SPEED * 1.3 + radius * 15.0) * exp(-radius * 1.5);
    float flame3 = sin(angle * 12.0 + time * FLAME_SPEED * 0.7) * exp(-radius * 2.5);
    float flames = (flame1 + flame2 + flame3) * WRATHFUL_INTENSITY;
    
    // Skull motif pattern
    float skull_pattern = sin(pos.x * 25.0 + time * 0.5) * cos(pos.y * 20.0 + time * 0.7);
    skull_pattern *= sin(radius * 30.0 + time * 2.0) * 0.1;
    
    // Ethereal distortion (souls drifting)
    vec2 spirit_drift = vec2(
        sin(pos.y * 12.0 + time * 1.5) * 0.02,
        cos(pos.x * 15.0 + time * 1.2) * 0.02
    );
    spirit_drift += vec2(
        sin(pos.x * 8.0 + time * 0.8) * 0.015,
        cos(pos.y * 10.0 + time * 1.1) * 0.015
    );
    
    // Sample with spirit distortion
    vec4 color = HOOKED_tex(pos + spirit_drift);
    
    // Bardo color transformation (between life and death)
    float life_death_cycle = sin(time * 0.3) * 0.5 + 0.5;
    vec3 death_tint = vec3(0.6, 0.3, 0.8); // Deep purple
    vec3 rebirth_tint = vec3(0.9, 0.7, 0.3); // Golden
    vec3 void_tint = vec3(0.2, 0.2, 0.4); // Dark blue-gray
    
    // Cycle through death, void, rebirth
    vec3 bardo_color = mix(death_tint, void_tint, abs(sin(time * 0.2)));
    bardo_color = mix(bardo_color, rebirth_tint, abs(cos(time * 0.15)));
    
    color.rgb = mix(color.rgb, color.rgb * bardo_color, 0.4);
    
    // Add mandala energy
    float mandala_energy = (mandala_rings + mandala_spokes) * 0.1 + 0.05;
    int jewel_index = int(mod(angle * 2.0 + time, 5.0));
    color.rgb += mandala_energy * getJewelColor(jewel_index);
    
    // Wrathful flames overlay
    if (flames > 0.1) {
        vec3 flame_color = vec3(1.0, 0.3, 0.1) + vec3(0.5, 0.7, 0.2) * sin(time * 3.0);
        color.rgb += flames * flame_color;
    }
    
    // Skull shadow overlay
    if (skull_pattern > 0.05) {
        color.rgb *= 0.7; // Darken for skull shadows
        color.rgb += vec3(0.1, 0.05, 0.1) * skull_pattern * 5.0;
    }
    
    // Consciousness dissolution effect (center to edge)
    float dissolution = 1.0 - smoothstep(0.0, 0.7, radius);
    dissolution *= abs(sin(time * 0.4)) * 0.3 + 0.7;
    color.rgb *= dissolution;
    
    // Dharma wheel spokes (8-fold path)
    float dharma_spokes = sin(mandala_angle * 4.0) * exp(-radius * 4.0);
    if (dharma_spokes > 0.3 && radius < 0.4) {
        color.rgb += vec3(0.8, 0.6, 0.2) * 0.2; // Golden dharma light
    }
    
    // Intermediate state flickering
    float bardo_flicker = sin(time * 12.0) * cos(time * 8.0) * 0.05 + 0.95;
    color.rgb *= bardo_flicker;
    
    // Void meditation darkness at edges
    float void_meditation = smoothstep(0.4, 0.8, radius);
    color.rgb *= (1.0 - void_meditation * 0.6);
    
    // Jewel-like color separation (like thangka paintings)
    float jewel_separation = sin(pos.x * 100.0) * sin(pos.y * 100.0) * 0.02;
    color.rgb += vec3(jewel_separation, -jewel_separation * 0.5, jewel_separation * 0.8);
    
    return color;
}
