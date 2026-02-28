#!/bin/bash
#
# Build Vorbis for all required Android ABIs
# Output:
#   - Shared libraries: jniLibs/<ABI>/libvorbis.so
#   - Static libraries: libs/<ABI>/libvorbis.a
#   - Headers: include/vorbis/

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"

# All required ABIs
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building Vorbis for all Android ABIs"
echo "=========================================="
echo "NDK: $NDK_ROOT"
echo "API: $ANDROID_PLATFORM"
echo "ABIs: ${ABIS[@]}"
echo ""

# Verify NDK exists
if [ ! -d "$NDK_ROOT" ]; then
    echo "ERROR: NDK not found at $NDK_ROOT"
    exit 1
fi

# Build for each ABI
for abi in "${ABIS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building Vorbis for ABI: $abi"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    export ANDROID_ABI="$abi"
    
    # Run the single-ABI build script
    if "$WORKSPACE_ROOT/build-vorbis.sh"; then
        echo "✓ Successfully built Vorbis for $abi"
    else
        echo "✗ Failed to build Vorbis for $abi"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "Vorbis Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$abi/libvorbis.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$abi/libvorbis.so" | awk '{print $5}')
        echo "    ├── $abi/libvorbis.so ($size)"
    fi
done
echo ""
echo "  libs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$abi/libvorbis.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$abi/libvorbis.a" | awk '{print $5}')
        echo "    ├── $abi/libvorbis.a ($size)"
    fi
done
echo ""
echo "  include/"
echo "    └── vorbis/"
echo ""
