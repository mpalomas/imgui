# Building ImGui

This fork provides a CMake build system supporting both static and shared library builds.

## Requirements

- CMake 3.20 or higher
- C++11 compatible compiler
- SDL3 (for SDL3 backends)
- Vulkan SDK (for Vulkan backend)
- Dawn WebGPU (for WebGPU backend)

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `IMGUI_BUILD_SHARED` | `OFF` | Build as shared library instead of static |
| `IMGUI_BUILD_BACKEND_SDL3` | `ON` | Build SDL3 platform backend |
| `IMGUI_BUILD_BACKEND_SDL3_RENDERER` | `ON` | Build SDL3 Renderer backend |
| `IMGUI_BUILD_BACKEND_VULKAN` | `ON` | Build Vulkan rendering backend |
| `IMGUI_BUILD_BACKEND_WGPU` | `ON` | Build WebGPU (Dawn) rendering backend |

## Required Paths

| Variable | Required When | Description |
|----------|---------------|-------------|
| `SDL3_DIR` | SDL3 backends enabled | Path to SDL3 CMake config directory |
| `WEBGPU_DAWN_DIR` | WebGPU backend enabled | Path to Dawn WebGPU CMake config directory |

## Build Examples

### Static library (default)

```bash
cmake -B build \
  -DSDL3_DIR=/path/to/SDL3/lib/cmake/SDL3 \
  -DWEBGPU_DAWN_DIR=/path/to/dawn/lib/cmake/webgpu

cmake --build build
```

### Shared library

```bash
cmake -B build \
  -DIMGUI_BUILD_SHARED=ON \
  -DSDL3_DIR=/path/to/SDL3/lib/cmake/SDL3 \
  -DWEBGPU_DAWN_DIR=/path/to/dawn/lib/cmake/webgpu

cmake --build build
```

### Minimal build (only SDL3 + Vulkan)

```bash
cmake -B build \
  -DSDL3_DIR=/path/to/SDL3/lib/cmake/SDL3 \
  -DIMGUI_BUILD_BACKEND_SDL3_RENDERER=OFF \
  -DIMGUI_BUILD_BACKEND_WGPU=OFF

cmake --build build
```

### Install

```bash
cmake --install build --prefix /path/to/install
```

## Consumer Usage

After installation, consumers can use `find_package` to locate and link against ImGui:

```cmake
find_package(imgui REQUIRED)

# Link core library only
target_link_libraries(myapp PRIVATE imgui::imgui)

# Link with SDL3 backend
target_link_libraries(myapp PRIVATE imgui::imgui imgui::backend_sdl3)

# Link with SDL3 + Vulkan backends
target_link_libraries(myapp PRIVATE
    imgui::imgui
    imgui::backend_sdl3
    imgui::backend_vulkan
)

# Link with SDL3 + WebGPU backends
target_link_libraries(myapp PRIVATE
    imgui::imgui
    imgui::backend_sdl3
    imgui::backend_wgpu
)
```

## Available Targets

| Target | Description |
|--------|-------------|
| `imgui::imgui` | Core ImGui library (includes C bindings) |
| `imgui::backend_sdl3` | SDL3 platform backend |
| `imgui::backend_sdlrenderer3` | SDL3 Renderer backend |
| `imgui::backend_vulkan` | Vulkan rendering backend |
| `imgui::backend_wgpu` | WebGPU (Dawn) rendering backend |
