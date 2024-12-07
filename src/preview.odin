package fast_noise_lite_preview_app

import fnl "shared:fast_noise_lite"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fast_noise_lite - types
Preview_State :: struct {
    preview_3d: bool,

    noise_type: i32,
    rotation_type: i32,
    seed: i32,
    frequency: f32,

    fractal_type: i32,
    fractal_octaves: i32,
    fractal_lacunarity: f32,
    fractal_gain: f32,
    fractal_weighted_strength: f32,
    fractal_ping_pong_strength: f32,

    cellular_type: i32,
    cellular_return_type: i32,
    cellular_jitter: f32,

    domain_warp_seed: i32,
    domain_warp_frequency: f32,
    domain_warp_type: i32,
    domain_warp_rotation_type: i32,
    domain_warp_amplitude: f32,

    domain_warp_fractal_type: i32,
    domain_warp_fractal_octaves: i32,
    domain_warp_fractal_lacunarity: f32,
    domain_warp_fractal_gain: f32,
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fast_noise_lite - procs
preview_make :: proc() -> Preview_State {
    return {
        preview_3d = false,

        noise_type = 0,
        rotation_type = 0,
        seed = 1337,
        frequency = 0.01,

        fractal_type = 0,
        fractal_octaves = 3,
        fractal_lacunarity = 2.0,
        fractal_gain = 0.5,
        fractal_weighted_strength = 0.0,
        fractal_ping_pong_strength = 2.0,

        cellular_type = 1,
        cellular_return_type = 1,
        cellular_jitter = 1.0,

        domain_warp_seed = 1337,
        domain_warp_frequency = 0.01,
        domain_warp_type = 0,
        domain_warp_rotation_type = 0,
        domain_warp_amplitude = 1.0,

        domain_warp_fractal_type = 0,
        domain_warp_fractal_octaves = 3,
        domain_warp_fractal_lacunarity = 2.0,
        domain_warp_fractal_gain = 0.5,
    }
}

preview_init :: proc(s: ^App_State) {
    s.preview = preview_make()
    s.fnl = fnl.create_state()
    s.fnl_warp = fnl.create_state()
}