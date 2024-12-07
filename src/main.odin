package fast_noise_lite_preview_app

import "core:fmt"
import "core:mem"
import fnl "shared:fast_noise_lite"

main :: proc() {
    // Tracking Allocator  /////////////////////////////////////////////////////////////////////////////////////////////
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)
    
        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }
            if len(track.bad_free_array) > 0 {
                fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
                for entry in track.bad_free_array {
                    fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
                }
            }
            mem.tracking_allocator_destroy(&track)
        }
    }

    // Initialization //////////////////////////////////////////////////////////////////////////////////////////////////
    s : App_State = {}

    if !window_init() do return
    defer window_cleanup()

    if !imgui_init(&s) do return
    defer imgui_cleanup(&s)

    s.preview = preview_make()
    s.fnl = fnl.create_state()
    s.fnl_warp = fnl.create_state()

    ui_init(&s)
    defer ui_cleanup(&s)

    // Main Loop ///////////////////////////////////////////////////////////////////////////////////////////////////////
    
    for !s.window.close_requested {
        window_clear()
        window_poll_events(&s)

        imgui_new_frame()
        ui_draw(&s)
        imgui_render()

        window_swap()
    }
}

