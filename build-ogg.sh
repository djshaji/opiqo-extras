#!/bin/bash
#
# Build OGG for Android NDK
# Usage: ANDROID_ABI=arm64-v8a ./build-ogg.sh
# Output:
#   - Shared: jniLibs/<ABI>/libogg.so
#   - Static: libs/<ABI>/libogg.a
#   - Headers: include/ogg/*.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"
export BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

SHARED_LIB_DIR="$WORKSPACE_ROOT/jniLibs/$ANDROID_ABI"
STATIC_LIB_DIR="$WORKSPACE_ROOT/libs/$ANDROID_ABI"
INCLUDE_DIR="$WORKSPACE_ROOT/include"

echo "OGG Build Configuration:"
echo "  Workspace: $WORKSPACE_ROOT"
echo "  NDK: $NDK_ROOT"
echo "  ABI: $ANDROID_ABI"
echo "  Platform: $ANDROID_PLATFORM"
echo "  Output (shared): $SHARED_LIB_DIR"
echo "  Output (static): $STATIC_LIB_DIR"
echo "  Headers: $INCLUDE_DIR"
echo ""

# Validate NDK exists
if [ ! -d "$NDK_ROOT" ]; then
    echo "ERROR: NDK not found at $NDK_ROOT"
    exit 1
fi

# Create directories
mkdir -p "$WORKSPACE_ROOT/build/ogg-shared-$ANDROID_ABI"
mkdir -p "$WORKSPACE_ROOT/build/ogg-static-$ANDROID_ABI"
mkdir -p "$SHARED_LIB_DIR"
mkdir -p "$STATIC_LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# ============================================================================
# SHARED LIBRARY BUILD
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building OGG Shared Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/ogg-shared-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    "$WORKSPACE_ROOT/src/ogg"

cmake --build . -j"$BUILD_JOBS"

# Install shared library
if [ -f "libogg.so" ]; then
    cp libogg.so "$SHARED_LIB_DIR/"
    echo "✓ Shared library: $SHARED_LIB_DIR/libogg.so ($(ls -lh libogg.so | awk '{print $5}'))"
else
    echo "✗ Shared library not found!"
    exit 1
fi

# ============================================================================
# STATIC LIBRARY BUILD
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building OGG Static Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/ogg-static-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    "$WORKSPACE_ROOT/src/ogg"

cmake --build . -j"$BUILD_JOBS"

# Install static library
if [ -f "libogg.a" ]; then
    cp libogg.a "$STATIC_LIB_DIR/"
    echo "✓ Static library: $STATIC_LIB_DIR/libogg.a ($(ls -lh libogg.a | awk '{print $5}'))"
else
    echo "✗ Static library not found!"
    exit 1
fi

# ============================================================================
# HEADERS (only copy once since they're the same for all ABIs)
# ============================================================================
if [ "$ANDROID_ABI" = "arm64-v8a" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Installing Headers"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -d "$WORKSPACE_ROOT/src/ogg/include/ogg" ]; then
        cp -r "$WORKSPACE_ROOT/src/ogg/include/ogg" "$INCLUDE_DIR/"
        echo "✓ Headers installed: $INCLUDE_DIR/ogg/"
    else
        echo "✗ Header files not found!"
        exit 1
    fi
fi

echo ""
echo "✓ OGG build complete for ABI: $ANDROID_ABI"
