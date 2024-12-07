package fast_noise_lite_preview_app

import fnl "shared:fast_noise_lite"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// app_state - types
App_State :: struct {
    window: Window_State,
    imgui: Imgui_State,
    ui: UI_State,
    preview: Preview_State,
    fnl, fnl_warp: fnl.FNL_State,
}