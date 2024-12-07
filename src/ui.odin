package fast_noise_lite_preview_app

import "core:math"
import "core:time"
import gl "vendor:OpenGL"
import fnl "shared:fast_noise_lite"
import "shared:imgui"
import "core:fmt"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fast_noise_lite_ui - constants
FNL_VERSION : cstring : "v1.1.1 (WIP Port)"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fast_noise_lite_ui - types
UI_State :: struct {
    noise_tex: u32,
    noise_tex_size: imgui.Vec2,
    noise_tex_size_gen_x: i32,
    noise_tex_size_gen_y: i32,
    noise_tex_min: f32,
    noise_tex_max: f32,

    preview_size: [2]i32,
    preview_3d: bool,
    preview_scroll: f32,
    preview_pos_z: f64,
    preview_domain_warp: bool,
    preview_auto_size: bool,

    preview_gen_time: f64,
    preview_gen_time_final: f64,
    preview_min: f32,
    preview_min_final: f32,
    preview_max: f32,
    preview_max_final: f32,
    preview_mean: f32,
    preview_mean_final: f32,
    preview_trigger_save: bool,
    preview_pixel_y: i32, 
    preview_pixel_array: [dynamic]u8,
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fast_noise_lite_ui - procs
ui_init :: proc (s: ^App_State) {
    s.ui = {
        noise_tex = 0,
        noise_tex_size = 0,
        noise_tex_size_gen_x = 0,
        noise_tex_size_gen_y = 0,
        noise_tex_min = -1,
        noise_tex_max = 1,

        preview_size = {768, 768},
        preview_3d = false,
        preview_scroll = 0,
        preview_pos_z = 0,
        preview_domain_warp = false,
        preview_auto_size = false,
    }

    //TODO: cleanup
    //not required as we are using const cstr names now
    // noise_type_names := reflect.enum_field_names(fnl.Noise_Type)
    // s.ui.noise_type_count = i32(len(noise_type_names))
    // s.ui.noise_type_names = make([]cstring, s.ui.noise_type_count)
    // for str, i in noise_type_names do s.ui.noise_type_names[i] = strings.clone_to_cstring(str)
}

ui_cleanup :: proc (s: ^App_State) {
    //TODO: cleanup
    // for cstr in s.ui.noise_type_names do delete(cstr)
    // delete(s.ui.noise_type_names)
    delete(s.ui.preview_pixel_array)
}

ui_draw :: proc (s: ^App_State) {
    enum_noise_type                     : cstring : "OpenSimplex2\x00OpenSimplex2S\x00Cellular\x00Perlin\x00Value Cubic\x00Value\x00"
    enum_noise_type_len                 :: 6
    enum_rotation_type                  : cstring : "None\x00Improve XY Planes\x00Improve XZ Planes\x00"
    enum_rotation_type_len              :: 3
    enum_fractal_type                   : cstring : "None\x00FBm\x00Ridged\x00Ping Pong\x00"
    enum_fractal_type_len               :: 4
    enum_cellular_type                  : cstring : "Euclidean\x00Euclidean Sq\x00Manhattan\x00Hybrid"
    enum_cellular_type_len              :: 4 
    enum_cellular_return_type           : cstring : "Cell Value\x00Distance\x00Distance 2\x00Distance 2 Add\x00Distance 2 Sub\x00Distance 2 Mul\x00Distance 2 Div"
    enum_cellular_return_type_len       :: 7
    enum_domain_warp_type               : cstring : "None\x00OpenSimplex2\x00OpenSimplex2 Reduced\x00Basic Grid\x00"
    enum_domain_warp_type_len           :: 4
    enum_domain_warp_fractal_type       : cstring : "None\x00Progressive\x00Independent\x00"
    enum_domain_warp_fractal_type_len   :: 3

    tex_update := false

    imgui.Begin("Settings")
    imgui.PushItemWidth(120)

    imgui.BeginTabBar("Tabs")
    if imgui.BeginTabItem("FastNoise Lite") {
        using s.preview
        /// General
        imgui.TextUnformatted("General")

        if imgui.Combo("Noise Type", &noise_type, enum_noise_type, enum_noise_type_len) {
            s.fnl.noise_type = fnl.Noise_Type(noise_type)
            tex_update = true
        }

        imgui.BeginDisabled(!preview_3d)
        if imgui.Combo("Rotation Type 3D", &rotation_type, enum_rotation_type, enum_rotation_type_len) {
            s.fnl.rotation_type_3d = fnl.Rotation_Type_3d(rotation_type)
            tex_update = true
        }
        imgui.EndDisabled()

        if imgui.DragInt("Seed", &seed) {
            s.fnl.seed = int(seed)
            tex_update = true
        }
        if imgui.DragFloat("Frequency", &frequency, 0.0002) {
            s.fnl.frequency = frequency
            tex_update = true
        }

        /// Fractal
        imgui.TextUnformatted("Fractal")

        if imgui.Combo("Type", &fractal_type, enum_fractal_type, enum_fractal_type_len) {
            s.fnl.fractal_type = fnl.Fractal_Type(fractal_type)
            tex_update = true
        }

        imgui.BeginDisabled(fractal_type == 0)
        if (imgui.DragInt("Octaves", &fractal_octaves, 0.1, 1, 20)) {
            s.fnl.octaves = int(fractal_octaves)
            tex_update = true
        }
        if imgui.DragFloat("Lacunarity", &fractal_lacunarity, 0.01) {
            s.fnl.lacunarity = fractal_lacunarity
            tex_update = true
        }
        if imgui.DragFloat("Gain", &fractal_gain, 0.01) {
            s.fnl.gain = fractal_gain
            tex_update = true
        }
        if imgui.DragFloat("Weighted Strength", &fractal_weighted_strength, 0.01) {
            s.fnl.weighted_strength = fractal_weighted_strength
            tex_update = true
        }
        imgui.BeginDisabled(fractal_type != i32(fnl.Fractal_Type.Ping_Pong))
        if imgui.DragFloat("Ping Pong Strength", &fractal_ping_pong_strength, 0.01) {
            s.fnl.ping_pong_strength = fractal_ping_pong_strength
            tex_update = true
        }
        imgui.EndDisabled()
        imgui.EndDisabled()

        /// Cellular
        imgui.TextUnformatted("Cellular")

        imgui.BeginDisabled(noise_type != i32(fnl.Noise_Type.Cellular))
        if imgui.Combo("Distance Function", &cellular_type, enum_cellular_type, enum_cellular_type_len) {
            s.fnl.cellular_distance_func = fnl.Cellular_Distance_Func(cellular_type)
            tex_update = true
        }
        if imgui.Combo("Return Type", &cellular_return_type, enum_cellular_return_type, enum_cellular_return_type_len) {
            s.fnl.cellular_return_type = fnl.Cellular_Return_Type(cellular_return_type)
            tex_update = true
        }
        if imgui.DragFloat("Jitter", &cellular_jitter, 0.01) {
            s.fnl.cellular_jitter_mod = cellular_jitter
            tex_update = true
        }
        imgui.EndDisabled()

        /// Domain Warp
        imgui.PushID("Domain Warp")
        imgui.TextUnformatted("Domain Warp")

        if imgui.Combo("Type", &domain_warp_type, enum_domain_warp_type, enum_domain_warp_type_len) {
            s.fnl_warp.domain_warp_type = fnl.Domain_Warp_Type(domain_warp_type - 1)
            tex_update = true
        }
        imgui.BeginDisabled(domain_warp_type == 0)
        imgui.BeginDisabled(!preview_3d)
        if imgui.Combo("Rotation Type 3D", &domain_warp_rotation_type, enum_rotation_type, enum_rotation_type_len) {
            s.fnl_warp.rotation_type_3d = fnl.Rotation_Type_3d(domain_warp_rotation_type)
            tex_update = true
        }
        imgui.EndDisabled()
        if imgui.DragFloat("Amplitude", &domain_warp_amplitude, 0.5) {
            s.fnl_warp.domain_warp_amp = domain_warp_amplitude
            tex_update = true
        }
        if imgui.DragInt("Seed", &domain_warp_seed) {
            s.fnl_warp.seed = int(domain_warp_seed)
            tex_update = true
        }
        if imgui.DragFloat("Frequency", &domain_warp_frequency, 0.001) {
            s.fnl_warp.frequency = domain_warp_frequency
            tex_update = true
        }

        /// Domain Warp Fractal
        imgui.PushID("Domain Warp Fractal")
        imgui.TextUnformatted("Domain Warp Fractal")

        if imgui.Combo("Type", &domain_warp_fractal_type, enum_domain_warp_fractal_type, enum_domain_warp_fractal_type_len) {
            s.fnl_warp.fractal_type = fnl.Fractal_Type(domain_warp_fractal_type > 0 ? domain_warp_fractal_type + 3 : 0)
            tex_update = true
        }
        imgui.BeginDisabled(domain_warp_fractal_type == 0)
        if imgui.DragInt("Octaves", &domain_warp_fractal_octaves, 0.1, 1, 20) {
            s.fnl_warp.octaves = int(domain_warp_fractal_octaves)
        }
        if imgui.DragFloat("Lacunarity", &domain_warp_fractal_lacunarity, 0.01) {
            s.fnl_warp.lacunarity = domain_warp_fractal_lacunarity
            tex_update = true
        }
        if imgui.DragFloat("Gain", &domain_warp_fractal_gain, 0.01){
            s.fnl_warp.gain = domain_warp_fractal_gain
            tex_update = true
        }
        imgui.EndDisabled()
        imgui.EndDisabled()
        imgui.PopID()
        imgui.PopID()

        imgui.NewLine()
        imgui.TextUnformatted(FNL_VERSION)

        imgui.EndTabItem()
    }

    if imgui.BeginTabItem("Preview Settings") {
        imgui.Checkbox("Auto Size", &s.ui.preview_auto_size)
        imgui.BeginDisabled(s.ui.preview_auto_size)
        imgui.DragInt2("Size", &s.ui.preview_size, 1, 32, 4096)
        imgui.EndDisabled()

        if imgui.DragFloat("Black Point", &s.ui.noise_tex_min, 0.01) do tex_update = true
        if imgui.DragFloat("White Point", &s.ui.noise_tex_max, 0.01) do tex_update = true
        if imgui.Checkbox("3D", &s.ui.preview_3d) do tex_update = true

        if (s.ui.preview_3d) {
            imgui.Indent()
            imgui.DragFloat("Scroll Speed", &s.ui.preview_scroll, 0.02)

            imgui.BeginDisabled(s.ui.preview_scroll != 0)
            floatPosZ := f32(s.ui.preview_pos_z)
            if (imgui.DragFloat("Z Position", &floatPosZ)) {
                s.ui.preview_pos_z = f64(floatPosZ)
                tex_update = true
            }
            imgui.EndDisabled()

            imgui.Unindent()
        }

        imgui.NewLine()
        if imgui.Button("Save Preview") do s.ui.preview_trigger_save = true

        imgui.EndTabItem()   
    }

    imgui.EndTabBar()
    imgui.PopItemWidth()
    imgui.End()

    imgui.Begin("Noise Texture")

    if s.ui.preview_auto_size {
        autoSize := imgui.GetContentRegionAvail()
        s.ui.preview_size.x = i32(autoSize.x)
        s.ui.preview_size.y = i32(autoSize.y)
    }

    if s.ui.preview_pixel_y == 0 {
        if s.ui.noise_tex_size_gen_x != s.ui.preview_size.x || s.ui.noise_tex_size_gen_y != s.ui.preview_size.y do tex_update = true
        if s.ui.preview_3d && s.ui.preview_scroll != 0 {
            s.ui.preview_pos_z += f64(s.ui.preview_scroll)
            tex_update = true
        }
    }

    update_texture(tex_update, s)

    //TODO: saving
    // if (previewTriggerSave && previewPixelArray && previewPixelY == 0)
    // {
    //     previewTriggerSave = false;
    //     std::string bmpFile = EncodeBMP((int)noiseTexSize.x, (int)noiseTexSize.y, previewPixelArray).str();
    //     emscripten_browser_file::download("FastNoiseLite.bmp", "image/bmp", bmpFile);
    // }

    imgui.Image(rawptr(uintptr(s.ui.noise_tex)), s.ui.noise_tex_size)
    imgui.End()


    window_flags :imgui.WindowFlags = {.NoScrollbar, .NoScrollWithMouse}
    //TODO: BeginViewportSideBar (currently solved with a normal imgui window)
    // imgui.BeginViewportSideBar("status", imgui.GetMainViewport(), imgui.Dir.Down, 32,  window_flags)
    imgui.Begin("Status", flags=window_flags)
    textOffset :f32= 200
    imgui.Text("Preview Stats: %0.02fms", s.ui.preview_gen_time_final)
    imgui.SameLine(textOffset)
    textOffset += 100
    imgui.Text("Min: %0.04f", s.ui.preview_min_final)
    imgui.SameLine(textOffset)
    textOffset += 200
    imgui.Text("Max: %0.04f", s.ui.preview_max_final)
    imgui.SameLine(textOffset)
    imgui.Text("Mean: %0.04f", s.ui.preview_mean_final)

    imgui.SameLine(imgui.GetWindowWidth() - imgui.CalcTextSize("GitHub").x - 15)
    imgui.SetCursorPosY(imgui.GetCursorPosY() - 2)

    //TODO:
    // if (imgui.Button("GitHub"))
    // {
    //     emscripten_run_script("window.open('https://github.com/Auburn/FastNoiseLite', '_blank').focus();");
    // }
    // imgui.PopStyleVar()

    imgui.End()
}

@(private="file") 
update_texture :: proc (new_preview: bool, s: ^App_State) {
    using s.ui
    if preview_pixel_y == 0 && !new_preview do return

    if new_preview {
        if preview_pixel_array != nil do delete(preview_pixel_array)

        preview_pixel_y = 0
        preview_gen_time = 0

        noise_tex_size_gen_x = preview_size.x
        noise_tex_size_gen_y = preview_size.y


        preview_min = math.F32_MAX
        preview_max = math.F32_MIN
        preview_mean = 0
        preview_pixel_array = make([dynamic]u8, noise_tex_size_gen_x * noise_tex_size_gen_y * 4)
    }
    
    index := noise_tex_size_gen_x * preview_pixel_y * 4
    scale := 255 / (noise_tex_max - noise_tex_min)

    timer : time.Stopwatch
    time.stopwatch_start(&timer)

    for y:= preview_pixel_y; y < noise_tex_size_gen_y; y+=1 {
        preview_pixel_y = y + 1
        for x:i32= 0; x < noise_tex_size_gen_x; x+=1 {
            noise: f32
            posX := f32(x - noise_tex_size_gen_x / 2)
            posY := f32(y - noise_tex_size_gen_y / 2)

            if preview_3d {
                posZ := f32(preview_pos_z)
                if s.preview.domain_warp_type > 0 do fnl.domain_warp_3d(&s.fnl_warp, &posX, &posY, &posZ)
                noise = fnl.get_noise_3d(&s.fnl, posX, posY, posZ)
            } else {
                if s.preview.domain_warp_type > 0 do fnl.domain_warp_2d(&s.fnl_warp, &posX, &posY)
                noise = fnl.get_noise_2d(&s.fnl, posX, posY)
            }

            c_noise := u8(math.max(0.0, math.min(255.0, (noise - noise_tex_min) * scale)))

            preview_pixel_array[index + 0] = c_noise
            preview_pixel_array[index + 1] = c_noise
            preview_pixel_array[index + 2] = c_noise
            preview_pixel_array[index + 3] = 255
            index += 4

            preview_min = math.min(preview_min, noise)
            preview_max = math.max(preview_max, noise)
            preview_mean += noise
        }

        duration := time.stopwatch_duration(timer)
        duration_ms := time.duration_milliseconds(duration)
        if y % 8 == 0 && duration_ms >= 80 do break
    }

    time.stopwatch_stop(&timer)
    preview_gen_time += time.duration_milliseconds(time.stopwatch_duration(timer))

    if preview_pixel_y < noise_tex_size_gen_y do return

    noise_tex_size.x = f32(noise_tex_size_gen_x)
    noise_tex_size.y = f32(noise_tex_size_gen_y)
    preview_pixel_y = 0
    preview_mean_final = preview_mean / (noise_tex_size.x * noise_tex_size.y)
    preview_min_final = preview_min
    preview_max_final = preview_max
    preview_gen_time_final = preview_gen_time

    if noise_tex != 0 do gl.DeleteTextures(1, &noise_tex)

    // Create a OpenGL texture identifier
    gl.GenTextures(1, &noise_tex)
    gl.BindTexture(gl.TEXTURE_2D, noise_tex)

    // Setup filtering parameters for display
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    // Upload pixels into texture
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, noise_tex_size_gen_x, noise_tex_size_gen_y, 0, gl.RGBA, gl.UNSIGNED_BYTE, &preview_pixel_array[0])

    fmt.printfln("Finish gl tex")
}