# opiqo-extras

Audio codec libraries built for Android NDK r29 (SDK 34) supporting multiple architectures.

## Overview

This project provides pre-built audio codec libraries for Android development, compiled for 4 ABIs with both shared and static linking support.

## Build Status

✅ **7 of 8 libraries successfully built**

| Library | Status | Version | Purpose |
|---------|--------|---------|---------|
| **LAME** | ✅ Complete | 3.100 | MP3 encoder |
| **FLAC** | ✅ Complete | 1.4.3 | Lossless audio codec |
| **OGG** | ✅ Complete | 1.3.6 | Audio container format |
| **Vorbis** | ✅ Complete | 1.3.7 | Ogg Vorbis audio codec |
| **Opus** | ✅ Complete | 1.6 | Modern audio codec |
| **FFTW3** | ✅ Complete | 3.3.10 | Fast Fourier Transform library |
| **libsndfile** | ✅ Complete | 1.2.2 | Audio file I/O library |
| **mpg123** | ❌ Blocked | 1.32.10 | MPEG audio decoder (POSIX compat issue) |

## Supported Architectures

- **arm64-v8a** (64-bit ARM)
- **armeabi-v7a** (32-bit ARM)
- **x86_64** (64-bit Intel)
- **x86** (32-bit Intel)

## Build Outputs

### Shared Libraries (`.so`)
Located in `jniLibs/{ABI}/`

```
jniLibs/
├── arm64-v8a/
│   ├── libFLAC.so (1.2M)
│   ├── libmp3lame.so (1023K)
│   ├── libogg.so (84K)
│   ├── libopus.so (1.9M)
│   ├── libfftw3.so (7.9M)
│   ├── libsndfile.so (varies)
│   └── libvorbis.so (608K)
├── armeabi-v7a/
│   └── [same libraries, smaller sizes]
├── x86_64/
│   └── [same libraries]
└── x86/
	└── [same libraries]
```

### Static Libraries (`.a`)
Located in `libs/{ABI}/`

```
libs/
├── arm64-v8a/
│   ├── libFLAC.a (2.0M)
│   ├── libmp3lame.a (1.8M)
│   ├── libogg.a (126K)
│   ├── libopus.a (3.5M)
│   ├── libfftw3.a (19M)
│   ├── libsndfile.a (varies)
│   └── libvorbis.a (1020K)
└── [other ABIs...]
```

### Headers
Located in `include/`

```
include/
├── FLAC/
├── ogg/
├── opus/
├── vorbis/
├── fftw3.h
├── lame.h
└── sndfile.h
```

## Quick Start

### Building All Libraries

```bash
# Build all libraries for all ABIs
./build-lame-all-abis.sh
./build-ogg-all-abis.sh
./build-flac-all-abis.sh
./build-vorbis-all-abis.sh
./build-opus-all-abis.sh
./build-fftw-all-abis.sh
./build-libsndfile-all-abis.sh
```

### Building Single ABI

```bash
# Build for specific architecture
ANDROID_ABI=arm64-v8a ./build-lame.sh
ANDROID_ABI=x86_64 ./build-flac.sh
```

## Build Scripts

Each library has two build scripts:

- `build-{library}.sh` - Builds for a single ABI (set via `ANDROID_ABI` env var)
- `build-{library}-all-abis.sh` - Builds for all 4 ABIs automatically

## Requirements

- **Android NDK r29** (default path: `/home/djshaji/Downloads/ndk-29/android-ndk-r29`)
- **CMake 3.16+**
- **Build tools**: gcc/clang, make, autotools

## Library Dependencies

```
OGG (no dependencies)
 ├── FLAC (optional OGG dependency, built standalone)
 ├── Vorbis (requires OGG)
 └── libsndfile (requires FLAC, Vorbis, OGG, Opus)

LAME (standalone)
Opus (standalone)
FFTW3 (standalone)
mpg123 (standalone, not built)
```

## Usage in Android Projects

### Using Shared Libraries

1. Copy libraries from `jniLibs/{ABI}/` to your Android project's `src/main/jniLibs/{ABI}/`
2. Copy headers from `include/` to your native code directory
3. Link in your CMakeLists.txt:

```cmake
find_library(lame-lib mp3lame)
target_link_libraries(your-native-lib ${lame-lib})
```

### Using Static Libraries

```cmake
add_library(mp3lame STATIC IMPORTED)
set_target_properties(mp3lame PROPERTIES
	IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libmp3lame.a)
target_link_libraries(your-native-lib mp3lame)
```

## Build Configuration

Default settings:
- **NDK**: `/home/djshaji/Downloads/ndk-29/android-ndk-r29`
- **API Level**: android-34
- **Build Type**: Release
- **Optimization**: Enabled with NEON/SIMD support where available

Override via environment variables:
```bash
export NDK_ROOT=/path/to/ndk
export ANDROID_PLATFORM=android-29
export BUILD_JOBS=8
```

## Library Details

### LAME (libmp3lame)
- MP3 encoding at various bitrates
- VBR/CBR support
- ID3 tag support
- **Size**: ~1MB (shared), ~1.8MB (static) for arm64

### FLAC (libFLAC)
- Lossless compression
- Streaming support
- Metadata preservation
- **Size**: ~1.2MB (shared), ~2MB (static) for arm64

### OGG (libogg)
- Container format for Vorbis/Opus
- Low overhead
- **Size**: ~84KB (shared), ~126KB (static) for arm64

### Vorbis (libvorbis)
- Ogg Vorbis encoding/decoding
- Better quality than MP3 at same bitrate
- Includes: libvorbis, libvorbisenc, libvorbisfile
- **Size**: ~608KB (shared), ~1MB (static) for arm64

### Opus (libopus)
- Low latency codec
- Wide bitrate range (6-510 kbps)
- Excellent quality
- **Size**: ~1.9MB (shared), ~3.5MB (static) for arm64

### FFTW3 (libfftw3)
- Fast Fourier Transform for 1D/2D/3D data
- Real and complex transforms
- Highly optimized generated codelets
- **Size**: ~7.9MB (shared), ~19MB (static) for arm64

### libsndfile
- Reads/writes many audio formats (WAV, AIFF, AU, etc.)
- Integrates FLAC, Vorbis, Opus codecs
- Format detection
- **Size**: Varies by ABI

## Known Issues

### mpg123 Build Failure
- **Status**: Blocked
- **Issue**: POSIX directory interface (dirent.h) not fully compatible with Android NDK
- **File**: `src/mpg123/src/compat.c`
- **Workaround**: Can be built without compat layer but loses some functionality
- **Impact**: MP3 decoding not available (use libsndfile or implement native MediaCodec wrapper)

## Build Environment

Built on:
- **OS**: Linux (Fedora/RHEL-based)
- **Date**: February 2026
- **NDK**: r29 (Clang 21.0.0)
- **CMake**: 3.16+

## License

Each library retains its original license:
- **LAME**: LGPL
- **FLAC**: BSD-like (Xiph.org)
- **OGG**: BSD-like (Xiph.org)
- **Vorbis**: BSD-like (Xiph.org)
- **Opus**: BSD
- **FFTW3**: GPL v2+
- **libsndfile**: LGPL v2.1+

See individual source directories for full license texts.

## Contributing

To add new audio codecs or fix build issues:

1. Add source code to `src/{library}/`
2. Create build script following the pattern of existing scripts
3. Test for all 4 ABIs
4. Update this README

## Directory Structure

```
opiqo-extra/
├── src/               # Source code for each library
│   ├── lame/
│   ├── flac/
│   ├── ogg/
│   ├── vorbis/
│   ├── opus/
│   ├── fftw-3.3.10/
│   ├── libsndfile/
│   └── mpg123/
├── build/             # Build artifacts (gitignored)
├── jniLibs/           # Shared libraries (.so)
│   ├── arm64-v8a/
│   ├── armeabi-v7a/
│   ├── x86_64/
│   └── x86/
├── libs/              # Static libraries (.a)
│   └── [same ABIs]
├── include/           # Public headers
├── build-*.sh         # Build scripts
└── README.md          # This file
```

## Troubleshooting

### "NDK not found"
Set the NDK path: `export NDK_ROOT=/path/to/ndk`

### "Library not found" during linking
Ensure you've copied the correct ABI to your project's jniLibs folder

### Build hangs
Reduce parallel jobs: `export BUILD_JOBS=2`

### Missing symbols
Check that you're linking all dependencies (e.g., libsndfile needs FLAC, Vorbis, OGG)

## Support

For issues specific to:
- **Build process**: Check build logs in `build/{library}-{shared|static}-{ABI}/`
- **Library usage**: Consult official documentation of each library
- **Android integration**: See Android NDK documentation

## Acknowledgments

Thanks to the maintainers of:
- LAME Project
- Xiph.Org Foundation (FLAC, OGG, Vorbis)
- Opus Codec
- FFTW Team
- libsndfile
- mpg123 Project
