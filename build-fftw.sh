#!/bin/bash
#
# Build FFTW3 for Android NDK
# Usage: ANDROID_ABI=arm64-v8a ./build-fftw.sh
# Output:
#   - Shared: jniLibs/<ABI>/libfftw3.so
#   - Static: libs/<ABI>/libfftw3.a
#   - Headers: include/fftw3.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"
export BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

SHARED_LIB_DIR="$WORKSPACE_ROOT/jniLibs/$ANDROID_ABI"
STATIC_LIB_DIR="$WORKSPACE_ROOT/libs/$ANDROID_ABI"
INCLUDE_DIR="$WORKSPACE_ROOT/include"

echo "FFTW3 Build Configuration:"
echo "  Workspace: $WORKSPACE_ROOT"
echo "  NDK: $NDK_ROOT"
echo "  ABI: $ANDROID_ABI"
echo "  Platform: $ANDROID_PLATFORM"
echo "  Output (shared): $SHARED_LIB_DIR"
echo "  Output (static): $STATIC_LIB_DIR"
echo "  Headers: $INCLUDE_DIR"
echo ""

if [ ! -d "$NDK_ROOT" ]; then
    echo "ERROR: NDK not found at $NDK_ROOT"
    exit 1
fi

mkdir -p "$WORKSPACE_ROOT/build/fftw-shared-$ANDROID_ABI"
mkdir -p "$WORKSPACE_ROOT/build/fftw-static-$ANDROID_ABI"
mkdir -p "$SHARED_LIB_DIR"
mkdir -p "$STATIC_LIB_DIR"
mkdir -p "$INCLUDE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building FFTW3 Shared Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/fftw-shared-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_FLOAT=ON \
    -DENABLE_THREADS=OFF \
    -DENABLE_OPENMP=OFF \
    -DBUILD_TESTS=OFF \
    "$WORKSPACE_ROOT/src/fftw-3.3.10"

cmake --build . -j"$BUILD_JOBS"

SHARED_LIB_PATH=$(find . -maxdepth 2 -type f -name "libfftw3f.so" | head -n 1)
if [ -n "$SHARED_LIB_PATH" ] && [ -f "$SHARED_LIB_PATH" ]; then
    cp "$SHARED_LIB_PATH" "$SHARED_LIB_DIR/libfftw3f.so"
    echo "✓ Shared library: $SHARED_LIB_DIR/libfftw3f.so ($(ls -lh "$SHARED_LIB_DIR/libfftw3f.so" | awk '{print $5}'))"
else
    echo "✗ Shared library libfftw3f.so not found!"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building FFTW3 Static Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/fftw-static-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_FLOAT=ON \
    -DENABLE_THREADS=OFF \
    -DENABLE_OPENMP=OFF \
    -DBUILD_TESTS=OFF \
    "$WORKSPACE_ROOT/src/fftw-3.3.10"

cmake --build . -j"$BUILD_JOBS"

STATIC_LIB_PATH=$(find . -maxdepth 2 -type f -name "libfftw3f.a" | head -n 1)
if [ -n "$STATIC_LIB_PATH" ] && [ -f "$STATIC_LIB_PATH" ]; then
    cp "$STATIC_LIB_PATH" "$STATIC_LIB_DIR/libfftw3f.a"
    echo "✓ Static library: $STATIC_LIB_DIR/libfftw3f.a ($(ls -lh "$STATIC_LIB_DIR/libfftw3f.a" | awk '{print $5}'))"
else
    echo "✗ Static library libfftw3f.a not found!"
    exit 1
fi

if [ "$ANDROID_ABI" = "arm64-v8a" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Installing Headers"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$WORKSPACE_ROOT/src/fftw-3.3.10/api/fftw3.h" ]; then
        cp "$WORKSPACE_ROOT/src/fftw-3.3.10/api/fftw3.h" "$INCLUDE_DIR/fftw3.h"
        echo "✓ Headers installed: $INCLUDE_DIR/fftw3.h"
    else
        echo "✗ Header file fftw3.h not found!"
        exit 1
    fi
fi

echo ""
echo "✓ FFTW3 build complete for ABI: $ANDROID_ABI"
