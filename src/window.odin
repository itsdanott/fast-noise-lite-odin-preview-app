package fast_noise_lite_preview_app

import "vendor:glfw"
import gl "vendor:OpenGL"
import "base:runtime"
import "core:fmt"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// window - constants
GL_VERSION_MAJOR : i32 : 4
GL_VERSION_MINOR : i32 : 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// window - globals
glfw_window : glfw.WindowHandle
framebuffer_size_x,framebuffer_size_y : i32
framebuffer_aspect : f32

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// window - types
Window_State :: struct {
    close_requested : bool,
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// window - procs
@(private="file")
glfw_error :: proc "c" (error : i32, description : cstring) {
    context = runtime.default_context()
    fmt.println("glfw_error:", error, "description:", description)
}

@(private="file")
glfw_framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height : i32) {
    framebuffer_size_x = width
    framebuffer_size_y = height

    context = runtime.default_context()
    assert(framebuffer_size_x > 0 && framebuffer_size_y > 0)
    framebuffer_aspect = f32(framebuffer_size_x) / f32(framebuffer_size_y)

    gl.Viewport(0,0, width, height)
}

window_init :: proc() -> bool {
    if !glfw.Init() do return false

    glfw.SetErrorCallback(glfw_error)
    set_window_hints()

    prim_monitor := glfw.GetPrimaryMonitor()
    video_mode := glfw.GetVideoMode(prim_monitor)

    glfw_window = glfw.CreateWindow(video_mode.width, video_mode.height, "FastNoise Lite GUI (Odin)", nil, nil)
    if glfw_window == nil {
        glfw.Terminate()
        return false
    }    

    glfw.MakeContextCurrent(glfw_window)
    glfw.SwapInterval(1)

    gl.load_up_to(int(GL_VERSION_MAJOR), int(GL_VERSION_MINOR), glfw.gl_set_proc_address)

    set_callbacks()

    return true

    set_window_hints :: proc() {
        glfw.WindowHint(glfw.RESIZABLE, 1)
        glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_VERSION_MAJOR)
        glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_VERSION_MINOR)
        glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    
        when ODIN_OS == .Darwin do glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, gl.TRUE)
    }

    set_callbacks :: proc() {
        framebuffer_size_x, framebuffer_size_y = glfw.GetFramebufferSize(glfw_window)
        glfw_framebuffer_size_callback(glfw_window, framebuffer_size_x, framebuffer_size_y)
        glfw.SetFramebufferSizeCallback(glfw_window, glfw_framebuffer_size_callback)
    }
}

window_cleanup :: proc() {
    glfw.Terminate()
}

window_clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

window_poll_events :: proc(s : ^App_State) {
    s.window.close_requested = bool(glfw.WindowShouldClose(glfw_window))
    glfw.PollEvents()
}

window_swap :: proc () {
    glfw.SwapBuffers(glfw_window)
}