# Native Library Sizes

This document shows the native library sizes for Android and iOS platforms.

## Android Native Library Sizes

APK uses ZIP deflate compression.

| Architecture | Install Size | Download Size (APK) | Ratio |
|--------------|--------------|---------------------|-------|
| arm64-v8a | 7.51 MB | 3.20 MB | 42.6% |
| armeabi-v7a | 6.07 MB | 2.82 MB | 46.5% |
| x86_64 | 8.06 MB | 3.37 MB | 41.9% |
| **Total** | **21.64 MB** | **9.39 MB** | **43.4%** |

> **Note:** Android App Bundle (AAB) delivers only the architecture needed by the device.
> Most devices use arm64-v8a (~3.20 MB download).

## iOS Native Library Sizes

App Store uses LZMA-like compression (estimated).

| Architecture | Install Size | Download Size (IPA) | Ratio |
|--------------|--------------|---------------------|-------|
| arm64 | 26.59 MB | 7.48 MB | 28.1% |
| arm64 simulator | 27.36 MB | 7.54 MB | 27.6% |
| **Total** | **53.96 MB** | **15.03 MB** | **27.8%** |

> **Note:** App Store uses App Thinning, so users download only arm64 (~7.5 MB).
> Simulator slice is not included in App Store builds.
>
> **Important:** iOS App Store's cellular download limit (200MB) uses **Install Size**, not download size.
> The arm64 install size is ~26.59 MB, which counts toward this limit.

## Impact on Your App

### Download Size Impact

This is the additional size users need to download when installing your app:

| Platform | Additional Download |
|----------|---------------------|
| Android (arm64-v8a) | +3.20 MB |
| iOS (arm64) | +7.48 MB |

### Install Size Impact

This is the additional storage space required on the user's device:

| Platform | Additional Storage |
|----------|---------------------|
| Android (arm64-v8a) | +7.51 MB |
| iOS (arm64) | +26.59 MB |

### Practical Considerations

1. **App Size Increase**: Adding libvips will increase your app's download size by ~3-7 MB and install size by ~7-27 MB depending on platform.

2. **User Perception**: Users may notice the larger app size in app stores. Consider whether the image processing capabilities justify this increase for your use case.

3. **Storage-Constrained Devices**: On devices with limited storage (e.g., 16GB/32GB phones), the additional ~7-27 MB install size may matter to some users.

4. **Download Time**: On slow networks (e.g., 3G), the additional 3-7 MB download may add noticeable wait time.

5. **Alternative**: If you only need basic image operations (resize, crop), consider using platform-native APIs or lighter libraries. libvips is best suited for apps that need advanced/high-performance image processing.
