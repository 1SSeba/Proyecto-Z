shader_type canvas_item;

// Background Procedural Shader
// Professional animated background for game menus
// @author: Senior Graphics Developer (10+ years experience)

// ============================================================================
//  UNIFORMS - PROFESSIONAL CONTROLS
// ============================================================================

uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform float star_count : hint_range(100.0, 2000.0) = 800.0;
uniform float star_speed : hint_range(0.1, 3.0) = 1.0;
uniform float nebula_intensity : hint_range(0.0, 1.0) = 0.3;
uniform vec3 nebula_color : source_color = vec3(0.2, 0.1, 0.4);
uniform vec3 star_color : source_color = vec3(1.0, 1.0, 0.9);
uniform float gradient_intensity : hint_range(0.0, 1.0) = 0.6;
uniform vec3 gradient_top : source_color = vec3(0.05, 0.05, 0.15);
uniform vec3 gradient_bottom : source_color = vec3(0.15, 0.1, 0.2);

// Performance settings
uniform bool enable_parallax : hint_default(true) = true;
uniform bool enable_nebula : hint_default(true) = true;
uniform bool enable_twinkle : hint_default(true) = true;

// ============================================================================
//  NOISE FUNCTIONS - OPTIMIZED
// ============================================================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

// ============================================================================
//  STAR GENERATION - PROFESSIONAL
// ============================================================================

float star_field(vec2 uv, float layer_speed) {
    vec2 star_uv = uv * star_count;
    star_uv.x += TIME * star_speed * layer_speed * time_scale;
    
    vec2 cell = floor(star_uv);
    vec2 local_uv = fract(star_uv);
    
    float star_hash = hash(cell);
    
    // Star probability and positioning
    if (star_hash < 0.15) {  // 15% chance for star
        vec2 star_pos = vec2(
            hash(cell + vec2(1.0, 0.0)),
            hash(cell + vec2(0.0, 1.0))
        );
        
        float dist = length(local_uv - star_pos);
        
        // Star size based on hash
        float star_size = 0.001 + hash(cell + vec2(2.0, 2.0)) * 0.003;
        
        // Twinkle effect
        float twinkle = 1.0;
        if (enable_twinkle) {
            twinkle = 0.5 + 0.5 * sin(TIME * 3.0 * time_scale + star_hash * 6.28);
        }
        
        // Star intensity
        float star_intensity = smoothstep(star_size, 0.0, dist) * twinkle;
        
        return star_intensity;
    }
    
    return 0.0;
}

// ============================================================================
//  NEBULA GENERATION - FRACTAL
// ============================================================================

vec3 generate_nebula(vec2 uv) {
    if (!enable_nebula) return vec3(0.0);
    
    vec2 nebula_uv = uv * 2.0;
    nebula_uv.x += TIME * 0.05 * time_scale;
    nebula_uv.y += sin(TIME * 0.1 * time_scale) * 0.1;
    
    float nebula_noise = fbm(nebula_uv * 3.0);
    nebula_noise += fbm(nebula_uv * 6.0) * 0.5;
    nebula_noise += fbm(nebula_uv * 12.0) * 0.25;
    
    // Color variation
    vec3 nebula_color_var = nebula_color;
    nebula_color_var.r += sin(TIME * 0.3 * time_scale + uv.x * 2.0) * 0.1;
    nebula_color_var.g += cos(TIME * 0.4 * time_scale + uv.y * 3.0) * 0.1;
    
    return nebula_color_var * nebula_noise * nebula_intensity;
}

// ============================================================================
//  MAIN FRAGMENT SHADER
// ============================================================================

void fragment() {
    vec2 uv = UV;
    
    // Base gradient background
    vec3 background = mix(gradient_bottom, gradient_top, uv.y);
    background *= gradient_intensity;
    
    // Multiple star layers for parallax effect
    vec3 stars = vec3(0.0);
    
    if (enable_parallax) {
        // Layer 1 - Far stars (slow)
        stars += star_color * star_field(uv, 0.3) * 0.6;
        
        // Layer 2 - Medium stars
        stars += star_color * star_field(uv * 1.3, 0.7) * 0.8;
        
        // Layer 3 - Near stars (fast)
        stars += star_color * star_field(uv * 0.7, 1.2) * 1.0;
    } else {
        // Single layer for performance
        stars += star_color * star_field(uv, 1.0);
    }
    
    // Nebula clouds
    vec3 nebula = generate_nebula(uv);
    
    // Combine all elements
    vec3 final_color = background + stars + nebula;
    
    // Subtle vignette effect
    float vignette = 1.0 - length(uv - 0.5) * 0.5;
    final_color *= vignette;
    
    COLOR = vec4(final_color, 1.0);
}
