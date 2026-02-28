#!/bin/bash
#
# Build mpg123 for all required Android ABIs
# Output:
#   - Shared libraries: jniLibs/<ABI>/libmpg123.so
#   - Static libraries: libs/<ABI>/libmpg123.a
#   - Headers: include/mpg123.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"

# All required ABIs
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building mpg123 for all Android ABIs"
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
    echo "Building mpg123 for ABI: $abi"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    export ANDROID_ABI="$abi"
    
    # Run the single-ABI build script
    if "$WORKSPACE_ROOT/build-mpg123.sh"; then
        echo "✓ Successfully built mpg123 for $abi"
    else
        echo "✗ Failed to build mpg123 for $abi"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "mpg123 Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$abi/libmpg123.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$abi/libmpg123.so" | awk '{print $5}')
        echo "    ├── $abi/libmpg123.so ($size)"
    fi
done
echo ""
echo "  libs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$abi/libmpg123.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$abi/libmpg123.a" | awk '{print $5}')
        echo "    ├── $abi/libmpg123.a ($size)"
    fi
done
echo ""
echo "  include/"
echo "    └── mpg123.h"
echo ""
