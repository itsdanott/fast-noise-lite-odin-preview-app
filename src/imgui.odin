package fast_noise_lite_preview_app

import "shared:imgui"
import "shared:imgui/imgui_impl_glfw"
import "shared:imgui/imgui_impl_opengl3"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// imgui - types
Imgui_State :: struct {
    io: ^imgui.IO,
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// imgui - procs
imgui_init :: proc(s : ^App_State) -> bool {
    imgui.CHECKVERSION()
    imgui.CreateContext()
    s.imgui.io = imgui.GetIO()
    s.imgui.io.ConfigFlags += {.NavEnableKeyboard, .NavEnableGamepad}    
    s.imgui.io.ConfigFlags += { .DockingEnable}
    style := imgui.GetStyle()
    style.WindowRounding = 0
    style.Colors[imgui.Col.WindowBg].w = 1
    imgui.StyleColorsDark()

    if !imgui_impl_glfw.InitForOpenGL(glfw_window, true) do return false
    if !imgui_impl_opengl3.Init("#version 150") do return false

    return true
}

imgui_cleanup :: proc(s : ^App_State) {
    imgui_impl_opengl3.Shutdown()
    imgui_impl_glfw.Shutdown()
    imgui.DestroyContext()
}

imgui_new_frame :: proc () {
    imgui_impl_opengl3.NewFrame()
    imgui_impl_glfw.NewFrame()
    imgui.NewFrame()
}

imgui_render :: proc () {
    imgui.Render()
    imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())
}