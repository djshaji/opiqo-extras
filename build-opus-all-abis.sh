#!/bin/bash
#
# Build Opus for all Android NDK ABIs
# Outputs:
#   - Shared: jniLibs/{ABI}/libopus.so
#   - Static: libs/{ABI}/libopus.a
#   - Headers: include/opus/*.h

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"

ABIs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building Opus for all Android ABIs"
echo "=========================================="
echo "NDK: $NDK_ROOT"
echo "API: android-34"
echo "ABIs: ${ABIs[@]}"
echo ""

for ABI in "${ABIs[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building Opus for ABI: $ABI"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ANDROID_ABI="$ABI" "$WORKSPACE_ROOT/build-opus.sh"; then
        echo "✓ Successfully built Opus for $ABI"
    else
        echo "✗ Failed to build Opus for $ABI"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "Opus Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"

for ABI in "${ABIs[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$ABI/libopus.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$ABI/libopus.so" | awk '{print $5}')
        echo "    ├── $ABI/libopus.so ($size)"
    fi
done

echo ""
echo "  libs/"

for ABI in "${ABIs[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$ABI/libopus.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$ABI/libopus.a" | awk '{print $5}')
        echo "    ├── $ABI/libopus.a ($size)"
    fi
done

echo ""
echo "  include/"
if [ -d "$WORKSPACE_ROOT/include/opus" ]; then
    echo "    └── opus/"
fi
echo ""
