#!/bin/bash
#
# Build libsndfile for Android NDK
# Usage: ANDROID_ABI=arm64-v8a ./build-libsndfile.sh
# Dependencies: FLAC, Vorbis, OGG
# Output:
#   - Shared: jniLibs/<ABI>/libsndfile.so
#   - Static: libs/<ABI>/libsndfile.a
#   - Headers: include/sndfile.h

set -e

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NDK_ROOT="${NDK_ROOT:-/home/djshaji/Downloads/ndk-29/android-ndk-r29}"
export ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
export ANDROID_PLATFORM="${ANDROID_PLATFORM:-android-34}"
export BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

SHARED_LIB_DIR="$WORKSPACE_ROOT/jniLibs/$ANDROID_ABI"
STATIC_LIB_DIR="$WORKSPACE_ROOT/libs/$ANDROID_ABI"
INCLUDE_DIR="$WORKSPACE_ROOT/include"

echo "libsndfile Build Configuration:"
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

# Validate dependencies
if [ ! -f "$STATIC_LIB_DIR/libFLAC.a" ] || [ ! -f "$SHARED_LIB_DIR/libFLAC.so" ]; then
    echo "ERROR: FLAC libraries not found!"
    echo "       Please build FLAC first using: ./build-flac.sh"
    exit 1
fi

if [ ! -f "$STATIC_LIB_DIR/libvorbis.a" ] || [ ! -f "$SHARED_LIB_DIR/libvorbis.so" ]; then
    echo "ERROR: Vorbis libraries not found!"
    echo "       Please build Vorbis first using: ./build-vorbis.sh"
    exit 1
fi

if [ ! -f "$STATIC_LIB_DIR/libogg.a" ] || [ ! -f "$SHARED_LIB_DIR/libogg.so" ]; then
    echo "ERROR: OGG libraries not found!"
    echo "       Please build OGG first using: ./build-ogg.sh"
    exit 1
fi

# Validate headers
if [ ! -d "$INCLUDE_DIR/FLAC" ] || [ ! -d "$INCLUDE_DIR/vorbis" ] || [ ! -d "$INCLUDE_DIR/ogg" ]; then
    echo "ERROR: Required headers not found!"
    echo "       FLAC: $INCLUDE_DIR/FLAC"
    echo "       Vorbis: $INCLUDE_DIR/vorbis"
    echo "       OGG: $INCLUDE_DIR/ogg"
    exit 1
fi

# Create directories
mkdir -p "$WORKSPACE_ROOT/build/libsndfile-shared-$ANDROID_ABI"
mkdir -p "$WORKSPACE_ROOT/build/libsndfile-static-$ANDROID_ABI"
mkdir -p "$SHARED_LIB_DIR"
mkdir -p "$STATIC_LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# ============================================================================
# SHARED LIBRARY BUILD
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building libsndfile Shared Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/libsndfile-shared-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_PROGRAMS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DENABLES_CPACK=OFF \
    -DENABLE_EXTERNAL_LIBS=ON \
    -DENABLE_ALSA=OFF \
    -DENABLE_OSX=OFF \
    -DCMAKE_PREFIX_PATH="$INCLUDE_DIR" \
    -DFLAC_ROOT="$STATIC_LIB_DIR" \
    -DFLAC_INCLUDE_DIR="$INCLUDE_DIR/FLAC" \
    -DFLAC_LIBRARY="$SHARED_LIB_DIR/libFLAC.so" \
    -DVorbis_Vorbis_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_Enc_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_File_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_Vorbis_LIBRARY="$SHARED_LIB_DIR/libvorbis.so" \
    -DVorbis_Enc_LIBRARY="$SHARED_LIB_DIR/libvorbisenc.so" \
    -DVorbis_File_LIBRARY="$SHARED_LIB_DIR/libvorbisfile.so" \
    -DOgg_ROOT="$STATIC_LIB_DIR" \
    -DOgg_INCLUDE_DIR="$INCLUDE_DIR/ogg" \
    -DOgg_LIBRARY="$SHARED_LIB_DIR/libogg.so" \
    -DOPUS_INCLUDE_DIR="$INCLUDE_DIR/opus" \
    -DOPUS_LIBRARY="$SHARED_LIB_DIR/libopus.so" \
    "$WORKSPACE_ROOT/src/libsndfile"

cmake --build . -j"$BUILD_JOBS"

# Install shared library
if [ -f "libsndfile.so" ]; then
    cp libsndfile.so "$SHARED_LIB_DIR/"
    echo "✓ Shared library: $SHARED_LIB_DIR/libsndfile.so ($(ls -lh libsndfile.so | awk '{print $5}'))"
else
    echo "✗ Shared library not found!"
    exit 1
fi

# ============================================================================
# STATIC LIBRARY BUILD
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building libsndfile Static Library"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$WORKSPACE_ROOT/build/libsndfile-static-$ANDROID_ABI"

cmake \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_PROGRAMS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DENABLES_CPACK=OFF \
    -DENABLE_EXTERNAL_LIBS=ON \
    -DENABLE_ALSA=OFF \
    -DENABLE_OSX=OFF \
    -DCMAKE_PREFIX_PATH="$INCLUDE_DIR" \
    -DFLAC_ROOT="$STATIC_LIB_DIR" \
    -DFLAC_INCLUDE_DIR="$INCLUDE_DIR/FLAC" \
    -DFLAC_LIBRARY="$STATIC_LIB_DIR/libFLAC.a" \
    -DVorbis_Vorbis_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_Enc_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_File_INCLUDE_DIR="$INCLUDE_DIR" \
    -DVorbis_Vorbis_LIBRARY="$STATIC_LIB_DIR/libvorbis.a" \
    -DVorbis_Enc_LIBRARY="$STATIC_LIB_DIR/libvorbisenc.a" \
    -DVorbis_File_LIBRARY="$STATIC_LIB_DIR/libvorbisfile.a" \
    -DOgg_ROOT="$STATIC_LIB_DIR" \
    -DOgg_INCLUDE_DIR="$INCLUDE_DIR/ogg" \
    -DOgg_LIBRARY="$STATIC_LIB_DIR/libogg.a" \
    -DOPUS_INCLUDE_DIR="$INCLUDE_DIR/opus" \
    -DOPUS_LIBRARY="$STATIC_LIB_DIR/libopus.a" \
    "$WORKSPACE_ROOT/src/libsndfile"

cmake --build . -j"$BUILD_JOBS"

# Install static library
if [ -f "libsndfile.a" ]; then
    cp libsndfile.a "$STATIC_LIB_DIR/"
    echo "✓ Static library: $STATIC_LIB_DIR/libsndfile.a ($(ls -lh libsndfile.a | awk '{print $5}'))"
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
    
    if [ -f "$WORKSPACE_ROOT/src/libsndfile/include/sndfile.h" ]; then
        cp "$WORKSPACE_ROOT/src/libsndfile/include/sndfile.h" "$INCLUDE_DIR/"
        if [ -f "$WORKSPACE_ROOT/src/libsndfile/include/sndfile.h.in" ]; then
            cp "$WORKSPACE_ROOT/src/libsndfile/include/sndfile.h.in" "$INCLUDE_DIR/"
        fi
        echo "✓ Headers installed: $INCLUDE_DIR/sndfile.h"
    else
        echo "✗ Header files not found!"
        exit 1
    fi
fi

echo ""
echo "✓ libsndfile build complete for ABI: $ANDROID_ABI"
