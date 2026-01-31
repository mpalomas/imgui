#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Ensure errors in pipelines are caught

# Path to Dear ImGui files
IMGUI_PATH="."

# Output path
OUTPUT_PATH="generated"

# Create output directories if they don't exist
mkdir -p "$OUTPUT_PATH"
mkdir -p "$OUTPUT_PATH/backends"

# Process main imgui.h header
echo
echo "Processing imgui.h"
echo
python3 dear_bindings.py -o "$OUTPUT_PATH/dcimgui" "$IMGUI_PATH/imgui.h" || { echo "Processing failed"; exit 1; }

# Process imgui_internal.h header
echo
echo "Processing imgui_internal.h"
echo
python3 dear_bindings.py -o "$OUTPUT_PATH/dcimgui_internal" --include "$IMGUI_PATH/imgui.h" "$IMGUI_PATH/imgui_internal.h" || { echo "Processing failed"; exit 1; }
# Process backends
for backend in \
    sdl3 \
    sdlrenderer3 \
    vulkan \
    wgpu
do
    echo
    echo "Processing $backend"
    echo
    python3 dear_bindings.py --backend --include "$IMGUI_PATH/imgui.h" --imconfig-path "$IMGUI_PATH/imconfig.h" -o "$OUTPUT_PATH/backends/dcimgui_impl_$backend" "$IMGUI_PATH/backends/imgui_impl_$backend.h" || { echo "Processing failed"; exit 1; }
done

echo
echo "Processing completed"
