shader_type spatial;
render_mode unshaded, depth_test_disabled, fog_disabled, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float blindfold_progress : hint_range(0.0, 1.0) = 0.0;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float dark_visibility : hint_range(0.0, 1.0) = 0;

// NOUVEAU : Réglage des distances de vue
uniform float blind_distance : hint_range(1.0, 15.0) = 2.0; // Portée quand aveuglé
uniform float open_distance : hint_range(5.0, 50.0) = 100.0; // Portée quand on regarde

float random(vec2 uv, float time) {
    return fract(sin(dot(uv ,vec2(12.9898,78.233)) + time) * 43758.5453);
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 0.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float noise = random(uv, TIME);
    
    // 1. CALCUL DE LA PROFONDEUR
    float raw_depth = texture(depth_texture, uv).x;
    vec3 ndc = vec3(uv * 2.0 - 1.0, raw_depth);
    vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view.xyz /= view.w;
    float linear_depth = -view.z;
    
    // Correction pour le vide absolu (ciel/éditeur)
    if (raw_depth < 0.00001) {
        linear_depth = 1000.0;
    }

    // 2. MASQUE DU BANDEAU
    float mask_threshold = 1.0 - blindfold_progress;
    float blindfold_mask = smoothstep(mask_threshold - 0.1, mask_threshold + 0.1, uv.y);
    
    // 3. DISTANCE DYNAMIQUE
    // Interpolation entre la distance courte (aveugle) et la distance longue (vue libre)
    float current_max_distance = mix(blind_distance, open_distance, blindfold_mask);
    
    // On calcule l'estompage dans le noir basé sur cette distance dynamique
    float depth_mask = clamp(1.0 - (linear_depth / current_max_distance), 0.0, 1.0);
    
    // 4. RENDU SOMBRE (Bandeau baissé)
    vec3 dark_color = vec3(depth_mask * noise * dark_visibility);
    
    // 5. RENDU CLAIR (Bandeau levé)
    vec3 normal_color = texture(screen_texture, uv).rgb;
    normal_color -= (noise * noise_intensity); 
    normal_color *= depth_mask;
    
    // 6. MÉLANGE FINAL
    ALBEDO = mix(dark_color, normal_color, blindfold_mask);
}