cmake_minimum_required(VERSION 3.20)
project(imgui VERSION 1.92.6 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Options
option(IMGUI_BUILD_SHARED "Build as shared library" OFF)
option(IMGUI_BUILD_BACKEND_SDL3 "Build SDL3 backend" ON)
option(IMGUI_BUILD_BACKEND_SDL3_RENDERER "Build SDL3 Renderer backend" ON)
option(IMGUI_BUILD_BACKEND_VULKAN "Build Vulkan backend" ON)
option(IMGUI_BUILD_BACKEND_WGPU "Build WebGPU backend" ON)

# Required paths for dependencies
set(SDL3_DIR "" CACHE PATH "Path to SDL3 CMake config directory")
set(WEBGPU_DAWN_DIR "" CACHE PATH "Path to Dawn WebGPU CMake config directory")

# Determine library type
if(IMGUI_BUILD_SHARED)
    set(IMGUI_LIB_TYPE SHARED)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
    set(IMGUI_LIB_TYPE STATIC)
endif()

# =============================================================================
# Core ImGui Library
# =============================================================================

set(IMGUI_CORE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui_demo.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui_draw.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui_tables.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui_widgets.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/dcimgui.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/dcimgui_internal.cpp
)

set(IMGUI_CORE_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui_internal.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imstb_rectpack.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imstb_textedit.h
    ${CMAKE_CURRENT_SOURCE_DIR}/imstb_truetype.h
    ${CMAKE_CURRENT_SOURCE_DIR}/dcimgui.h
    ${CMAKE_CURRENT_SOURCE_DIR}/dcimgui_internal.h
)

add_library(imgui ${IMGUI_LIB_TYPE} ${IMGUI_CORE_SOURCES} ${IMGUI_CORE_HEADERS})
add_library(imgui::imgui ALIAS imgui)

target_include_directories(imgui
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

# Export symbols for shared library
if(IMGUI_BUILD_SHARED)
    target_compile_definitions(imgui
        PRIVATE IMGUI_API=__declspec\(dllexport\)
        INTERFACE IMGUI_API=__declspec\(dllimport\)
    )
    if(NOT WIN32)
        target_compile_definitions(imgui
            PRIVATE IMGUI_API=__attribute__\(\(visibility\(\"default\"\)\)\)
            INTERFACE IMGUI_API=
        )
    endif()
endif()

# =============================================================================
# SDL3 Backend
# =============================================================================

if(IMGUI_BUILD_BACKEND_SDL3)
    if(NOT SDL3_DIR)
        message(FATAL_ERROR "SDL3_DIR must be set when IMGUI_BUILD_BACKEND_SDL3 is ON")
    endif()

    find_package(SDL3 REQUIRED CONFIG PATHS ${SDL3_DIR} NO_DEFAULT_PATH)

    set(IMGUI_SDL3_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdl3.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_sdl3.cpp
    )

    set(IMGUI_SDL3_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdl3.h
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_sdl3.h
    )

    add_library(imgui_backend_sdl3 ${IMGUI_LIB_TYPE} ${IMGUI_SDL3_SOURCES} ${IMGUI_SDL3_HEADERS})
    add_library(imgui::backend_sdl3 ALIAS imgui_backend_sdl3)

    target_link_libraries(imgui_backend_sdl3
        PUBLIC imgui
        PUBLIC SDL3::SDL3
    )

    target_include_directories(imgui_backend_sdl3
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/backends>
            $<INSTALL_INTERFACE:include>
    )
endif()

# =============================================================================
# SDL3 Renderer Backend
# =============================================================================

if(IMGUI_BUILD_BACKEND_SDL3_RENDERER)
    if(NOT SDL3_DIR)
        message(FATAL_ERROR "SDL3_DIR must be set when IMGUI_BUILD_BACKEND_SDL3_RENDERER is ON")
    endif()

    if(NOT TARGET SDL3::SDL3)
        find_package(SDL3 REQUIRED CONFIG PATHS ${SDL3_DIR} NO_DEFAULT_PATH)
    endif()

    set(IMGUI_SDL3_RENDERER_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlrenderer3.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_sdlrenderer3.cpp
    )

    set(IMGUI_SDL3_RENDERER_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlrenderer3.h
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_sdlrenderer3.h
    )

    add_library(imgui_backend_sdlrenderer3 ${IMGUI_LIB_TYPE} ${IMGUI_SDL3_RENDERER_SOURCES} ${IMGUI_SDL3_RENDERER_HEADERS})
    add_library(imgui::backend_sdlrenderer3 ALIAS imgui_backend_sdlrenderer3)

    target_link_libraries(imgui_backend_sdlrenderer3
        PUBLIC imgui
        PUBLIC SDL3::SDL3
    )

    target_include_directories(imgui_backend_sdlrenderer3
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/backends>
            $<INSTALL_INTERFACE:include>
    )
endif()

# =============================================================================
# Vulkan Backend
# =============================================================================

if(IMGUI_BUILD_BACKEND_VULKAN)
    find_package(Vulkan REQUIRED)

    set(IMGUI_VULKAN_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_vulkan.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_vulkan.cpp
    )

    set(IMGUI_VULKAN_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_vulkan.h
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_vulkan.h
    )

    add_library(imgui_backend_vulkan ${IMGUI_LIB_TYPE} ${IMGUI_VULKAN_SOURCES} ${IMGUI_VULKAN_HEADERS})
    add_library(imgui::backend_vulkan ALIAS imgui_backend_vulkan)

    target_link_libraries(imgui_backend_vulkan
        PUBLIC imgui
        PUBLIC Vulkan::Vulkan
    )

    target_include_directories(imgui_backend_vulkan
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/backends>
            $<INSTALL_INTERFACE:include>
    )
endif()

# =============================================================================
# WebGPU Backend (Dawn)
# =============================================================================

if(IMGUI_BUILD_BACKEND_WGPU)
    if(NOT WEBGPU_DAWN_DIR)
        message(FATAL_ERROR "WEBGPU_DAWN_DIR must be set when IMGUI_BUILD_BACKEND_WGPU is ON")
    endif()

    find_package(webgpu REQUIRED CONFIG PATHS ${WEBGPU_DAWN_DIR} NO_DEFAULT_PATH)

    set(IMGUI_WGPU_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_wgpu.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_wgpu.cpp
    )

    set(IMGUI_WGPU_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_wgpu.h
        ${CMAKE_CURRENT_SOURCE_DIR}/backends/dcimgui_impl_wgpu.h
    )

    add_library(imgui_backend_wgpu ${IMGUI_LIB_TYPE} ${IMGUI_WGPU_SOURCES} ${IMGUI_WGPU_HEADERS})
    add_library(imgui::backend_wgpu ALIAS imgui_backend_wgpu)

    target_link_libraries(imgui_backend_wgpu
        PUBLIC imgui
        PUBLIC webgpu
    )

    target_include_directories(imgui_backend_wgpu
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/backends>
            $<INSTALL_INTERFACE:include>
    )
endif()

# =============================================================================
# Installation
# =============================================================================

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Collect all targets to install
set(IMGUI_INSTALL_TARGETS imgui)

if(IMGUI_BUILD_BACKEND_SDL3)
    list(APPEND IMGUI_INSTALL_TARGETS imgui_backend_sdl3)
endif()

if(IMGUI_BUILD_BACKEND_SDL3_RENDERER)
    list(APPEND IMGUI_INSTALL_TARGETS imgui_backend_sdlrenderer3)
endif()

if(IMGUI_BUILD_BACKEND_VULKAN)
    list(APPEND IMGUI_INSTALL_TARGETS imgui_backend_vulkan)
endif()

if(IMGUI_BUILD_BACKEND_WGPU)
    list(APPEND IMGUI_INSTALL_TARGETS imgui_backend_wgpu)
endif()

# Install targets
install(TARGETS ${IMGUI_INSTALL_TARGETS}
    EXPORT imguiTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install core headers
install(FILES ${IMGUI_CORE_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install backend headers
if(IMGUI_BUILD_BACKEND_SDL3)
    install(FILES ${IMGUI_SDL3_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

if(IMGUI_BUILD_BACKEND_SDL3_RENDERER)
    install(FILES ${IMGUI_SDL3_RENDERER_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

if(IMGUI_BUILD_BACKEND_VULKAN)
    install(FILES ${IMGUI_VULKAN_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

if(IMGUI_BUILD_BACKEND_WGPU)
    install(FILES ${IMGUI_WGPU_HEADERS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

# Export targets
install(EXPORT imguiTargets
    FILE imguiTargets.cmake
    NAMESPACE imgui::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/imgui
)

# Generate config file
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/imguiConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/imguiConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/imgui
)

# Generate version file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/imguiConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/imguiConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/imguiConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/imgui
)
