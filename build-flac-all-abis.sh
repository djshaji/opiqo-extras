#!/bin/bash
#
# Build FLAC for all required Android ABIs
# Output:
#   - Shared libraries: jniLibs/<ABI>/libFLAC.so
#   - Static libraries: libs/<ABI>/libFLAC.a
#   - Headers: include/FLAC/

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"

# All required ABIs
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building FLAC for all Android ABIs"
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
    echo "Building FLAC for ABI: $abi"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    export ANDROID_ABI="$abi"
    
    # Run the single-ABI build script
    if "$WORKSPACE_ROOT/build-flac.sh"; then
        echo "✓ Successfully built FLAC for $abi"
    else
        echo "✗ Failed to build FLAC for $abi"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "FLAC Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$abi/libFLAC.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$abi/libFLAC.so" | awk '{print $5}')
        echo "    ├── $abi/libFLAC.so ($size)"
    fi
done
echo ""
echo "  libs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$abi/libFLAC.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$abi/libFLAC.a" | awk '{print $5}')
        echo "    ├── $abi/libFLAC.a ($size)"
    fi
done
echo ""
echo "  include/"
echo "    └── FLAC/"
echo ""
