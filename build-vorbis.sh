#!/bin/bash
#
# Build Vorbis for Android NDK
# Usage: ANDROID_ABI=arm64-v8a ./build-vorbis.sh
# Output:
#   - Shared: jniLibs/<ABI>/libvorbis.so
#   - Static: libs/<ABI>/libvorbis.a
#   - Headers: include/vorbis/*.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"
export BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

SHARED_LIB_DIR="$WORKSPACE_ROOT/jniLibs/$ANDROID_ABI"
STATIC_LIB_DIR="$WORKSPACE_ROOT/libs/$ANDROID_ABI"
INCLUDE_DIR="$WORKSPACE_ROOT/include"

echo "Vorbis Build Configuration:"
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

# Validate OGG libraries exist
if [ ! -f "$STATIC_LIB_DIR/libogg.a" ] || [ ! -f "$SHARED_LIB_DIR/libogg.so" ]; then
    echo "ERROR: OGG libraries not found!"
    echo "       Expected: $STATIC_LIB_DIR/libogg.a and $SHARED_LIB_DIR/libogg.so"
    echo "       Please build OGG/libogg first using: ./build-ogg.sh"
    exit 1
fi

# Validate OGG headers exist
if [ ! -d "$INCLUDE_DIR/ogg" ]; then
    echo "ERROR: OGG headers not found at $INCLUDE_DIR/ogg"
    echo "       Please build OGG/libogg first using: ./build-ogg.sh"
    exit 1
fi

# Create directories
mkdir -p "$WORKSPACE_ROOT/build/vorbis-shared-$ANDROID_ABI"
mkdir -p "$WORKSPACE_ROOT/build/vorbis-static-$ANDROID_ABI"
mkdir -p "$SHARED_LIB_DIR"
mkdir -p "$STATIC_LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# ============================================================================
# SHARED LIBRARY BUILD
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Vorbis Shared Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/vorbis-shared-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DINSTALL_CMAKE_PACKAGE_MODULE=OFF \
    -DOGG_LIBRARY="$SHARED_LIB_DIR/libogg.so" \
    -DOGG_INCLUDE_DIR="$INCLUDE_DIR" \
    "$WORKSPACE_ROOT/src/vorbis"

cmake --build . -j"$BUILD_JOBS"

# Install shared library
if [ -f "lib/libvorbis.so" ]; then
    cp lib/libvorbis.so "$SHARED_LIB_DIR/"
    echo "✓ Shared library: $SHARED_LIB_DIR/libvorbis.so ($(ls -lh lib/libvorbis.so | awk '{print $5}'))"
else
    echo "✗ Shared library not found!"
    exit 1
fi

# ============================================================================
# STATIC LIBRARY BUILD
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Vorbis Static Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/vorbis-static-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DINSTALL_CMAKE_PACKAGE_MODULE=OFF \
    -DOGG_LIBRARY="$STATIC_LIB_DIR/libogg.a" \
    -DOGG_INCLUDE_DIR="$INCLUDE_DIR" \
    "$WORKSPACE_ROOT/src/vorbis"

cmake --build . -j"$BUILD_JOBS"

# Install static library
if [ -f "lib/libvorbis.a" ]; then
    cp lib/libvorbis.a "$STATIC_LIB_DIR/"
    echo "✓ Static library: $STATIC_LIB_DIR/libvorbis.a ($(ls -lh lib/libvorbis.a | awk '{print $5}'))"
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
    
    if [ -d "$WORKSPACE_ROOT/src/vorbis/include/vorbis" ]; then
        cp -r "$WORKSPACE_ROOT/src/vorbis/include/vorbis" "$INCLUDE_DIR/"
        echo "✓ Headers installed: $INCLUDE_DIR/vorbis/"
    else
        echo "✗ Header files not found!"
        exit 1
    fi
fi

echo ""
echo "✓ Vorbis build complete for ABI: $ANDROID_ABI"
