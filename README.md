# FastNoise Lite Preview (Odin Port)

A desktop port of the FastNoise Lite Preview App written in Odin.

![screenshot](https://github.com/user-attachments/assets/668e61ba-c6cd-48b7-8418-c2ec4004e196)

## Current State

The app is in a working but unfinished state.  
It has been tested with Odin version **dev-2025-02** on **Windows** and **macOS**.

| Feature                                     | Status    |
|---------------------------------------------|----------|
| FNL Noise Generation & Texture Rendering   | ✅ Done  |
| Save Texture as Image                      | 🔧 Open  |
| ImGui Docking UX / QoL Improvements        | 🔧 Open  |

---

## Running the App

### ImGui Setup

The app uses the Odin ImGui bindings: [**gitlab.com/L-4/odin-imgui**](https://gitlab.com/L-4/odin-imgui)  

To set up ImGui, clone the repository into your Odin shared folder and build it with the following backend options:

```
wanted_backends = ["opengl3", "glfw"]
```

### FastNoise Lite Odin Package

The app uses the FNL Odin port: [**github.com/itsdanott/fast-noise-lite-odin**](github.com/itsdanott/fast-noise-lite-odin)

Copy the FastNoiseLite.odin file to a fast_noise_lite directory inside your Odin shared folder.
