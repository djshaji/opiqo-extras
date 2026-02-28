#!/bin/bash
#
# Build libsndfile for all Android NDK ABIs
# Dependencies: FLAC, Vorbis, OGG
# Outputs:
#   - Shared: jniLibs/{ABI}/libsndfile.so
#   - Static: libs/{ABI}/libsndfile.a
#   - Headers: include/sndfile.h

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"

ABIs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building libsndfile for all Android ABIs"
echo "=========================================="
echo "NDK: $NDK_ROOT"
echo "API: android-34"
echo "ABIs: ${ABIs[@]}"
echo ""

for ABI in "${ABIs[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building libsndfile for ABI: $ABI"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ANDROID_ABI="$ABI" "$WORKSPACE_ROOT/build-libsndfile.sh"; then
        echo "✓ Successfully built libsndfile for $ABI"
    else
        echo "✗ Failed to build libsndfile for $ABI"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "libsndfile Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"

for ABI in "${ABIs[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$ABI/libsndfile.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$ABI/libsndfile.so" | awk '{print $5}')
        echo "    ├── $ABI/libsndfile.so ($size)"
    fi
done

echo ""
echo "  libs/"

for ABI in "${ABIs[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$ABI/libsndfile.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$ABI/libsndfile.a" | awk '{print $5}')
        echo "    ├── $ABI/libsndfile.a ($size)"
    fi
done

echo ""
echo "  include/"
if [ -f "$WORKSPACE_ROOT/include/sndfile.h" ]; then
    echo "    └── sndfile.h"
fi
echo ""
