#!/bin/bash
#
# Build Opus for Android NDK
# Usage: ANDROID_ABI=arm64-v8a ./build-opus.sh
# Output:
#   - Shared: jniLibs/<ABI>/libopus.so
#   - Static: libs/<ABI>/libopus.a
#   - Headers: include/opus/*.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"
export BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

SHARED_LIB_DIR="$WORKSPACE_ROOT/jniLibs/$ANDROID_ABI"
STATIC_LIB_DIR="$WORKSPACE_ROOT/libs/$ANDROID_ABI"
INCLUDE_DIR="$WORKSPACE_ROOT/include"

echo "Opus Build Configuration:"
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
mkdir -p "$WORKSPACE_ROOT/build/opus-shared-$ANDROID_ABI"
mkdir -p "$WORKSPACE_ROOT/build/opus-static-$ANDROID_ABI"
mkdir -p "$SHARED_LIB_DIR"
mkdir -p "$STATIC_LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# ============================================================================
# SHARED LIBRARY BUILD
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Opus Shared Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/opus-shared-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DOPUS_BUILD_SHARED_LIBRARY=ON \
    -DOPUS_BUILD_PROGRAMS=OFF \
    -DOPUS_BUILD_TESTING=OFF \
    -DOPUS_INSTALL_DOCS=OFF \
    -DOPUS_DISABLE_FLOAT_API=OFF \
    -DOPUS_ENABLE_FIXED_POINT=OFF \
    "$WORKSPACE_ROOT/src/opus"

cmake --build . -j"$BUILD_JOBS"

# Install shared library
if [ -f "libopus.so" ]; then
    cp libopus.so "$SHARED_LIB_DIR/"
    echo "✓ Shared library: $SHARED_LIB_DIR/libopus.so ($(ls -lh libopus.so | awk '{print $5}'))"
else
    echo "✗ Shared library not found!"
    exit 1
fi

# ============================================================================
# STATIC LIBRARY BUILD
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Opus Static Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/opus-static-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DOPUS_BUILD_SHARED_LIBRARY=OFF \
    -DOPUS_BUILD_PROGRAMS=OFF \
    -DOPUS_BUILD_TESTING=OFF \
    -DOPUS_INSTALL_DOCS=OFF \
    -DOPUS_DISABLE_FLOAT_API=OFF \
    -DOPUS_ENABLE_FIXED_POINT=OFF \
    "$WORKSPACE_ROOT/src/opus"

cmake --build . -j"$BUILD_JOBS"

# Install static library
if [ -f "libopus.a" ]; then
    cp libopus.a "$STATIC_LIB_DIR/"
    echo "✓ Static library: $STATIC_LIB_DIR/libopus.a ($(ls -lh libopus.a | awk '{print $5}'))"
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
    
    if [ -d "$WORKSPACE_ROOT/src/opus/include" ]; then
        mkdir -p "$INCLUDE_DIR/opus"
        cp "$WORKSPACE_ROOT/src/opus/include/"*.h "$INCLUDE_DIR/opus/"
        echo "✓ Headers installed: $INCLUDE_DIR/opus/"
    else
        echo "✗ Header files not found!"
        exit 1
    fi
fi

echo ""
echo "✓ Opus build complete for ABI: $ANDROID_ABI"
