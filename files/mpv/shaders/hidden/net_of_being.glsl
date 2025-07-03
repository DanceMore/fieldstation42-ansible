//!HOOK MAIN
//!BIND HOOKED
//!DESC Fractal Video Tiling - Self-Similar Reality

#define TILE_SPEED 1.0
#define SCALE_BASE 0.4
#define NET_SIZE 8.0

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float time = frame / 60.0;
    
    vec4 result = vec4(0.0);
    float totalWeight = 0.0;
    
    // Layer 1: Main video
    vec4 mainVideo = HOOKED_tex(pos);
    result += mainVideo * 1.0;
    totalWeight += 1.0;
    
    // Layer 2: Scaled copies in hexagonal pattern
    for (int i = 0; i < 6; i++) {
        float angle = float(i) * 3.14159 / 3.0;
        float scale2 = SCALE_BASE;
        
        vec2 offset = vec2(cos(angle), sin(angle)) * scale2;
        vec2 center = vec2(0.5) + offset;
        vec2 scaledPos = (pos - center) / scale2 + vec2(0.5);
        
        vec4 sample2 = HOOKED_tex(scaledPos);
        float weight2 = exp(-length(pos - center) * 3.0) * scale2;
        
        result += sample2 * weight2;
        totalWeight += weight2;
    }
    
    // Layer 3: Smaller copies at intersections
    for (int i = 0; i < 12; i++) {
        float angle = float(i) * 3.14159 / 6.0 + time * TILE_SPEED;
        float scale3 = SCALE_BASE * 0.5;
        
        vec2 offset = vec2(cos(angle), sin(angle)) * scale3 * 1.5;
        vec2 center = vec2(0.5) + offset;
        vec2 scaledPos = (pos - center) / scale3 + vec2(0.5);
        
        vec4 sample3 = HOOKED_tex(scaledPos);
        float weight3 = exp(-length(pos - center) * 4.0) * scale3;
        
        result += sample3 * weight3;
        totalWeight += weight3;
    }
    
    // Layer 4: Tiny copies in grid pattern (Net of Being)
    vec2 gridPos = pos * NET_SIZE;
    vec2 gridId = floor(gridPos);
    vec2 gridUv = fract(gridPos);
    
    // Sample at grid intersections
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 neighborGrid = gridId + vec2(float(x), float(y));
            vec2 gridCenter = (neighborGrid + 0.5) / NET_SIZE;
            
            float scale4 = 0.08;
            vec2 miniPos = (pos - gridCenter) / scale4 + vec2(0.5);
            
            // Rotate each mini tile
            float rotAngle = time * TILE_SPEED + length(neighborGrid) * 0.5;
            vec2 rotCenter = vec2(0.5);
            vec2 rotated = rotCenter + mat2(cos(rotAngle), -sin(rotAngle), 
                                           sin(rotAngle), cos(rotAngle)) * (miniPos - rotCenter);
            
            vec4 miniSample = HOOKED_tex(rotated);
            float miniDist = length(pos - gridCenter);
            float miniWeight = exp(-miniDist * NET_SIZE * 2.0) * scale4;
            
            result += miniSample * miniWeight;
            totalWeight += miniWeight;
        }
    }
    
    // Normalize
    result /= totalWeight;
    
    // Mandala effect - radial mirroring
    vec2 center = pos - vec2(0.5);
    float radius = length(center);
    float angle = atan(center.y, center.x);
    
    // Create 8-fold symmetry
    float mirrorAngle = mod(angle + time * TILE_SPEED * 0.5, 3.14159 / 4.0);
    vec2 mirrorPos = vec2(cos(mirrorAngle), sin(mirrorAngle)) * radius + vec2(0.5);
    vec4 mirrorSample = HOOKED_tex(mirrorPos);
    
    // Blend with mirrored version based on radius
    float mirrorWeight = exp(-radius * 2.0) * 0.3;
    result = mix(result, mirrorSample, mirrorWeight);
    
    // DMT color enhancement
    float colorPulse = sin(time * 2.0) * 0.2 + 0.8;
    result.rgb *= colorPulse;
    
    // Electric colors
    result.r += sin(pos.x * 50.0 + time * 3.0) * 0.1;
    result.g += sin(pos.y * 40.0 + time * 2.5) * 0.1;
    result.b += sin((pos.x + pos.y) * 30.0 + time * 2.0) * 0.1;
    
    // Boost saturation
    float gray = dot(result.rgb, vec3(0.299, 0.587, 0.114));
    result.rgb = mix(vec3(gray), result.rgb, 1.5);
    
    // Consciousness breakthrough flicker
    float breakthrough = sin(time * 6.0) * 0.05 + 0.95;
    result.rgb *= breakthrough;
    
    return result;
}
