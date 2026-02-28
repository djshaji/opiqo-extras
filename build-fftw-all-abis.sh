#!/bin/bash
#
# Build FFTW3 for all required Android ABIs
# Output:
#   - Shared libraries: jniLibs/<ABI>/libfftw3.so
#   - Static libraries: libs/<ABI>/libfftw3.a
#   - Header: include/fftw3.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"

ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

echo "=========================================="
echo "Building FFTW3 for all Android ABIs"
echo "=========================================="
echo "NDK: $NDK_ROOT"
echo "API: $ANDROID_PLATFORM"
echo "ABIs: ${ABIS[*]}"
echo ""

if [ ! -d "$NDK_ROOT" ]; then
    echo "ERROR: NDK not found at $NDK_ROOT"
    exit 1
fi

for abi in "${ABIS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building FFTW3 for ABI: $abi"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    export ANDROID_ABI="$abi"

    if "$WORKSPACE_ROOT/build-fftw.sh"; then
        echo "✓ Successfully built FFTW3 for $abi"
    else
        echo "✗ Failed to build FFTW3 for $abi"
        exit 1
    fi
done

echo ""
echo "=========================================="
echo "FFTW3 Build Complete for All ABIs"
echo "=========================================="
echo ""
echo "Output Structure:"
echo "  jniLibs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/jniLibs/$abi/libfftw3.so" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/jniLibs/$abi/libfftw3.so" | awk '{print $5}')
        echo "    ├── $abi/libfftw3.so ($size)"
    fi
done

echo ""
echo "  libs/"
for abi in "${ABIS[@]}"; do
    if [ -f "$WORKSPACE_ROOT/libs/$abi/libfftw3.a" ]; then
        size=$(ls -lh "$WORKSPACE_ROOT/libs/$abi/libfftw3.a" | awk '{print $5}')
        echo "    ├── $abi/libfftw3.a ($size)"
    fi
done

echo ""
echo "  include/"
if [ -f "$WORKSPACE_ROOT/include/fftw3.h" ]; then
    echo "    └── fftw3.h"
fi
echo ""
