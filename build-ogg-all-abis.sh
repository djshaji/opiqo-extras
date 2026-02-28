#!/bin/bash
#
# Build OGG for all required Android ABIs
# Output:
#   - Shared libraries: jniLibs/<ABI>/libogg.so
#   - Static libraries: libs/<ABI>/libogg.a
#   - Headers: include/ogg/

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"

# All required ABIs
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building OGG for all Android ABIs"
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
    echo "Building OGG for ABI: $abi"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    export ANDROID_ABI="$abi"
    
    # Run the single-ABI build script
    if "$WORKSPACE_ROOT/build-ogg.sh"; then
        echo "✓ Successfully built OGG for $abi"
    else
        echo "✗ Failed to build OGG for $abi"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "OGG Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$abi/libogg.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$abi/libogg.so" | awk '{print $5}')
        echo "    ├── $abi/libogg.so ($size)"
    fi
done
echo ""
echo "  libs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$abi/libogg.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$abi/libogg.a" | awk '{print $5}')
        echo "    ├── $abi/libogg.a ($size)"
    fi
done
echo ""
echo "  include/"
echo "    └── ogg/"
echo ""
