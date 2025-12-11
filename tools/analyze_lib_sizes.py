#!/usr/bin/env python3
"""
Analyze native library sizes for Android and iOS.

统计 Android/iOS 各架构原生库的压缩/解压后大小。

- Android APK: Uses ZIP deflate compression (APK is a ZIP file)
- iOS IPA/App Store: Uses LZMA for estimation (App Store uses similar compression)

Usage:
    python tools/analyze_lib_sizes.py
"""

import os
import zlib
import lzma
import zipfile
import io
from pathlib import Path
from typing import Dict, List, Tuple

# Project root
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent / "libvips_ffi"

# Paths
ANDROID_JNILIB = PROJECT_ROOT / "android" / "src" / "main" / "jniLibs"
IOS_XCFRAMEWORK = PROJECT_ROOT / "ios" / "Frameworks" / "libvips.xcframework"


def format_size(size_bytes: int) -> str:
    """Format bytes to human readable string."""
    if size_bytes >= 1024 * 1024 * 1024:
        return f"{size_bytes / (1024 * 1024 * 1024):.2f} GB"
    elif size_bytes >= 1024 * 1024:
        return f"{size_bytes / (1024 * 1024):.2f} MB"
    elif size_bytes >= 1024:
        return f"{size_bytes / 1024:.2f} KB"
    else:
        return f"{size_bytes} B"


def get_zip_compressed_size(file_path: Path) -> int:
    """
    Get ZIP deflate compressed size (used in APK).
    APK uses ZIP format with DEFLATE compression.
    """
    with open(file_path, 'rb') as f:
        data = f.read()
    
    # Create in-memory ZIP with DEFLATE compression (level 9)
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        zf.writestr('file', data)
    
    # Return compressed size (subtract ZIP overhead ~30 bytes for single file)
    return max(0, buffer.tell() - 30)


def get_lzma_compressed_size(file_path: Path) -> int:
    """
    Get LZMA compressed size (approximation for iOS App Store).
    App Store uses proprietary compression similar to LZMA/LZFSE.
    """
    with open(file_path, 'rb') as f:
        data = f.read()
    
    # Use LZMA with preset 9 (maximum compression)
    compressed = lzma.compress(data, preset=9)
    return len(compressed)


def get_dir_size_android(dir_path: Path, extensions: List[str] = None) -> Tuple[int, int]:
    """
    Get total size and ZIP compressed size for Android (APK).
    
    Returns:
        Tuple of (raw_size, apk_compressed_size)
    """
    raw_total = 0
    compressed_total = 0
    
    if not dir_path.exists():
        return 0, 0
    
    for file_path in dir_path.rglob('*'):
        if file_path.is_file():
            if extensions and file_path.suffix not in extensions:
                continue
            size = file_path.stat().st_size
            raw_total += size
            compressed_total += get_zip_compressed_size(file_path)
    
    return raw_total, compressed_total


def get_dir_size_ios(dir_path: Path, extensions: List[str] = None) -> Tuple[int, int]:
    """
    Get total size and LZMA compressed size for iOS (App Store).
    
    Returns:
        Tuple of (raw_size, appstore_compressed_size)
    """
    raw_total = 0
    compressed_total = 0
    
    if not dir_path.exists():
        return 0, 0
    
    for file_path in dir_path.rglob('*'):
        if file_path.is_file():
            if extensions and file_path.suffix not in extensions:
                continue
            size = file_path.stat().st_size
            raw_total += size
            compressed_total += get_lzma_compressed_size(file_path)
    
    return raw_total, compressed_total


def analyze_android() -> Dict[str, Tuple[int, int]]:
    """
    Analyze Android native libraries by architecture.
    Uses ZIP deflate compression (same as APK).
    """
    results = {}
    
    if not ANDROID_JNILIB.exists():
        print(f"Warning: Android jniLibs not found at {ANDROID_JNILIB}")
        return results
    
    for arch_dir in ANDROID_JNILIB.iterdir():
        if arch_dir.is_dir() and not arch_dir.name.startswith('.'):
            if arch_dir.name in ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86']:
                raw, compressed = get_dir_size_android(arch_dir, ['.so'])
                results[arch_dir.name] = (raw, compressed)
    
    return results


def analyze_ios() -> Dict[str, Tuple[int, int]]:
    """
    Analyze iOS frameworks by architecture.
    Uses LZMA compression (approximation for App Store).
    """
    results = {}
    
    if not IOS_XCFRAMEWORK.exists():
        print(f"Warning: iOS xcframework not found at {IOS_XCFRAMEWORK}")
        return results
    
    for arch_dir in IOS_XCFRAMEWORK.iterdir():
        if arch_dir.is_dir() and arch_dir.name.startswith('ios-'):
            raw, compressed = get_dir_size_ios(arch_dir, ['.a', '.dylib', ''])
            # Also count framework binaries (no extension)
            for framework_dir in arch_dir.glob('*.framework'):
                binary = framework_dir / framework_dir.stem
                if binary.exists():
                    size = binary.stat().st_size
                    raw += size
                    compressed += get_lzma_compressed_size(binary)
            results[arch_dir.name] = (raw, compressed)
    
    return results


def print_table(title: str, data: Dict[str, Tuple[int, int]], compress_label: str = "Compressed"):
    """Print a formatted table."""
    if not data:
        print(f"\n{title}: No data found")
        return
    
    print(f"\n{'=' * 75}")
    print(f" {title}")
    print(f"{'=' * 75}")
    print(f"{'Architecture':<25} {'Raw (Install)':>18} {compress_label:>18} {'Ratio':>10}")
    print(f"{'-' * 75}")
    
    total_raw = 0
    total_compressed = 0
    
    for arch, (raw, compressed) in sorted(data.items()):
        ratio = (compressed / raw * 100) if raw > 0 else 0
        print(f"{arch:<25} {format_size(raw):>18} {format_size(compressed):>18} {ratio:>9.1f}%")
        total_raw += raw
        total_compressed += compressed
    
    print(f"{'-' * 75}")
    total_ratio = (total_compressed / total_raw * 100) if total_raw > 0 else 0
    print(f"{'TOTAL':<25} {format_size(total_raw):>18} {format_size(total_compressed):>18} {total_ratio:>9.1f}%")


def generate_markdown_files(android_data: Dict, ios_data: Dict):
    """Generate markdown files in docs directory."""
    docs_dir = SCRIPT_DIR.parent / "docs"
    docs_dir.mkdir(exist_ok=True)
    
    # English version
    en_content = generate_markdown_content(android_data, ios_data, lang='en')
    en_file = docs_dir / "NATIVE_LIBRARY_SIZES.md"
    en_file.write_text(en_content, encoding='utf-8')
    print(f"\nGenerated: {en_file}")
    
    # Chinese version
    cn_content = generate_markdown_content(android_data, ios_data, lang='cn')
    cn_file = docs_dir / "NATIVE_LIBRARY_SIZES_CN.md"
    cn_file.write_text(cn_content, encoding='utf-8')
    print(f"Generated: {cn_file}")


def generate_markdown_content(android_data: Dict, ios_data: Dict, lang: str = 'en') -> str:
    """Generate markdown content for the given language."""
    lines = []
    
    if lang == 'en':
        lines.append("# Native Library Sizes")
        lines.append("")
        lines.append("This document shows the native library sizes for Android and iOS platforms.")
        lines.append("")
        lines.append("## Android Native Library Sizes")
        lines.append("")
        lines.append("APK uses ZIP deflate compression.")
        lines.append("")
        lines.append("| Architecture | Install Size | Download Size (APK) | Ratio |")
        lines.append("|--------------|--------------|---------------------|-------|")
    else:
        lines.append("# 原生库大小")
        lines.append("")
        lines.append("本文档展示 Android 和 iOS 平台的原生库大小。")
        lines.append("")
        lines.append("## Android 原生库大小")
        lines.append("")
        lines.append("APK 使用 ZIP deflate 压缩。")
        lines.append("")
        lines.append("| 架构 | 安装大小 | 下载大小 (APK) | 压缩率 |")
        lines.append("|------|----------|----------------|--------|")
    
    total_raw = 0
    total_compressed = 0
    for arch, (raw, compressed) in sorted(android_data.items()):
        ratio = (compressed / raw * 100) if raw > 0 else 0
        lines.append(f"| {arch} | {format_size(raw)} | {format_size(compressed)} | {ratio:.1f}% |")
        total_raw += raw
        total_compressed += compressed
    
    if total_raw > 0:
        total_ratio = (total_compressed / total_raw * 100)
        if lang == 'en':
            lines.append(f"| **Total** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
        else:
            lines.append(f"| **总计** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
    
    lines.append("")
    if lang == 'en':
        lines.append("> **Note:** Android App Bundle (AAB) delivers only the architecture needed by the device.")
        lines.append("> Most devices use arm64-v8a (~3.20 MB download).")
    else:
        lines.append("> **注意：** Android App Bundle (AAB) 只分发设备需要的架构。")
        lines.append("> 大多数设备使用 arm64-v8a（下载约 3.20 MB）。")
    
    lines.append("")
    if lang == 'en':
        lines.append("## iOS Native Library Sizes")
        lines.append("")
        lines.append("App Store uses LZMA-like compression (estimated).")
        lines.append("")
        lines.append("| Architecture | Install Size | Download Size (IPA) | Ratio |")
        lines.append("|--------------|--------------|---------------------|-------|")
    else:
        lines.append("## iOS 原生库大小")
        lines.append("")
        lines.append("App Store 使用类似 LZMA 的压缩（估算值）。")
        lines.append("")
        lines.append("| 架构 | 安装大小 | 下载大小 (IPA) | 压缩率 |")
        lines.append("|------|----------|----------------|--------|")
    
    total_raw = 0
    total_compressed = 0
    for arch, (raw, compressed) in sorted(ios_data.items()):
        ratio = (compressed / raw * 100) if raw > 0 else 0
        arch_display = arch.replace('ios-', '').replace('-', ' ')
        lines.append(f"| {arch_display} | {format_size(raw)} | {format_size(compressed)} | {ratio:.1f}% |")
        total_raw += raw
        total_compressed += compressed
    
    if total_raw > 0:
        total_ratio = (total_compressed / total_raw * 100)
        if lang == 'en':
            lines.append(f"| **Total** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
        else:
            lines.append(f"| **总计** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
    
    lines.append("")
    if lang == 'en':
        lines.append("> **Note:** App Store uses App Thinning, so users download only arm64 (~7.5 MB).")
        lines.append("> Simulator slice is not included in App Store builds.")
        lines.append(">")
        lines.append("> **Important:** iOS App Store's cellular download limit (200MB) uses **Install Size**, not download size.")
        lines.append("> The arm64 install size is ~26.59 MB, which counts toward this limit.")
    else:
        lines.append("> **注意：** App Store 使用 App Thinning，用户只下载 arm64（约 7.5 MB）。")
        lines.append("> 模拟器切片不包含在 App Store 构建中。")
        lines.append(">")
        lines.append("> **重要：** iOS App Store 的蜂窝网络下载限制（200MB）使用的是**安装大小**，而非下载大小。")
        lines.append("> arm64 安装大小约 26.59 MB，会计入此限制。")
    
    # Get arm64 sizes
    android_arm64_raw = android_data.get('arm64-v8a', (0, 0))[0]
    android_arm64_compressed = android_data.get('arm64-v8a', (0, 0))[1]
    ios_arm64_raw = ios_data.get('ios-arm64', (0, 0))[0]
    ios_arm64_compressed = ios_data.get('ios-arm64', (0, 0))[1]
    
    lines.append("")
    if lang == 'en':
        lines.append("## Impact on Your App")
        lines.append("")
        lines.append("### Download Size Impact")
        lines.append("")
        lines.append("This is the additional size users need to download when installing your app:")
        lines.append("")
        lines.append("| Platform | Additional Download |")
        lines.append("|----------|---------------------|")
        lines.append(f"| Android (arm64-v8a) | +{format_size(android_arm64_compressed)} |")
        lines.append(f"| iOS (arm64) | +{format_size(ios_arm64_compressed)} |")
        lines.append("")
        lines.append("### Install Size Impact")
        lines.append("")
        lines.append("This is the additional storage space required on the user's device:")
        lines.append("")
        lines.append("| Platform | Additional Storage |")
        lines.append("|----------|---------------------|")
        lines.append(f"| Android (arm64-v8a) | +{format_size(android_arm64_raw)} |")
        lines.append(f"| iOS (arm64) | +{format_size(ios_arm64_raw)} |")
        lines.append("")
        lines.append("### Practical Considerations")
        lines.append("")
        lines.append("1. **App Size Increase**: Adding libvips will increase your app's download size by ~3-7 MB and install size by ~7-27 MB depending on platform.")
        lines.append("")
        lines.append("2. **User Perception**: Users may notice the larger app size in app stores. Consider whether the image processing capabilities justify this increase for your use case.")
        lines.append("")
        lines.append("3. **Storage-Constrained Devices**: On devices with limited storage (e.g., 16GB/32GB phones), the additional ~7-27 MB install size may matter to some users.")
        lines.append("")
        lines.append("4. **Download Time**: On slow networks (e.g., 3G), the additional 3-7 MB download may add noticeable wait time.")
        lines.append("")
        lines.append("5. **Alternative**: If you only need basic image operations (resize, crop), consider using platform-native APIs or lighter libraries. libvips is best suited for apps that need advanced/high-performance image processing.")
        lines.append("")
    else:
        lines.append("## 对应用的实际影响")
        lines.append("")
        lines.append("### 下载大小影响")
        lines.append("")
        lines.append("用户安装应用时需要额外下载的大小：")
        lines.append("")
        lines.append("| 平台 | 额外下载量 |")
        lines.append("|------|------------|")
        lines.append(f"| Android (arm64-v8a) | +{format_size(android_arm64_compressed)} |")
        lines.append(f"| iOS (arm64) | +{format_size(ios_arm64_compressed)} |")
        lines.append("")
        lines.append("### 安装大小影响")
        lines.append("")
        lines.append("用户设备上需要额外占用的存储空间：")
        lines.append("")
        lines.append("| 平台 | 额外存储空间 |")
        lines.append("|------|--------------|")
        lines.append(f"| Android (arm64-v8a) | +{format_size(android_arm64_raw)} |")
        lines.append(f"| iOS (arm64) | +{format_size(ios_arm64_raw)} |")
        lines.append("")
        lines.append("### 实际考量")
        lines.append("")
        lines.append("1. **应用体积增加**：集成 libvips 会使应用下载大小增加约 3-7 MB，安装大小增加约 7-27 MB（取决于平台）。")
        lines.append("")
        lines.append("2. **用户感知**：用户会在应用商店看到更大的应用体积。请评估图像处理能力是否值得这个体积增加。")
        lines.append("")
        lines.append("3. **存储受限设备**：在存储空间有限的设备上（如 16GB/32GB 手机），额外的 7-27 MB 安装空间可能对部分用户有影响。")
        lines.append("")
        lines.append("4. **下载时间**：在慢速网络（如 3G）下，额外的 3-7 MB 下载可能会增加明显的等待时间。")
        lines.append("")
        lines.append("5. **替代方案**：如果只需要基础图像操作（缩放、裁剪），可考虑使用平台原生 API 或更轻量的库。libvips 最适合需要高级/高性能图像处理的应用。")
        lines.append("")
    
    return '\n'.join(lines)


def print_markdown_table(android_data: Dict, ios_data: Dict):
    """Print markdown formatted tables for README."""
    print("\n\n## Markdown Format (for README)\n")
    
    print("### Android Native Library Sizes")
    print()
    print("APK uses ZIP deflate compression.")
    print()
    print("| Architecture | Install Size | Download Size (APK) | Ratio |")
    print("|--------------|--------------|---------------------|-------|")
    
    total_raw = 0
    total_compressed = 0
    for arch, (raw, compressed) in sorted(android_data.items()):
        ratio = (compressed / raw * 100) if raw > 0 else 0
        print(f"| {arch} | {format_size(raw)} | {format_size(compressed)} | {ratio:.1f}% |")
        total_raw += raw
        total_compressed += compressed
    
    if total_raw > 0:
        total_ratio = (total_compressed / total_raw * 100)
        print(f"| **Total** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
    
    print()
    print("> Note: Android App Bundle (AAB) delivers only the architecture needed by the device.")
    print("> Most devices use arm64-v8a (~3.20 MB download).")
    
    print("\n### iOS Native Library Sizes")
    print()
    print("App Store uses LZMA-like compression (estimated).")
    print()
    print("| Architecture | Install Size | Download Size (IPA) | Ratio |")
    print("|--------------|--------------|---------------------|-------|")
    
    total_raw = 0
    total_compressed = 0
    for arch, (raw, compressed) in sorted(ios_data.items()):
        ratio = (compressed / raw * 100) if raw > 0 else 0
        arch_display = arch.replace('ios-', '').replace('-', ' ')
        print(f"| {arch_display} | {format_size(raw)} | {format_size(compressed)} | {ratio:.1f}% |")
        total_raw += raw
        total_compressed += compressed
    
    if total_raw > 0:
        total_ratio = (total_compressed / total_raw * 100)
        print(f"| **Total** | **{format_size(total_raw)}** | **{format_size(total_compressed)}** | **{total_ratio:.1f}%** |")
    
    print()
    print("> Note: App Store uses App Thinning, so users download only arm64 (~10 MB).")
    print("> Simulator slice is not included in App Store builds.")


def main():
    print("=" * 70)
    print(" libvips_ffi Native Library Size Analysis")
    print(" 原生库大小分析")
    print("=" * 70)
    
    print("\nAnalyzing Android libraries...")
    android_data = analyze_android()
    
    print("Analyzing iOS libraries...")
    ios_data = analyze_ios()
    
    # Print console tables
    print_table("Android Native Libraries (.so) - ZIP Deflate", android_data, "Download (APK)")
    print_table("iOS Native Libraries (xcframework) - LZMA", ios_data, "Download (IPA)")
    
    # Print combined summary
    print(f"\n{'=' * 70}")
    print(" Summary / 总结")
    print(f"{'=' * 70}")
    
    android_total = sum(raw for raw, _ in android_data.values())
    android_compressed = sum(compressed for _, compressed in android_data.values())
    ios_total = sum(raw for raw, _ in ios_data.values())
    ios_compressed = sum(compressed for _, compressed in ios_data.values())
    
    print(f"\nAndroid (all architectures):")
    print(f"  Raw:        {format_size(android_total)}")
    print(f"  Compressed: {format_size(android_compressed)}")
    
    print(f"\niOS (all architectures):")
    print(f"  Raw:        {format_size(ios_total)}")
    print(f"  Compressed: {format_size(ios_compressed)}")
    
    print(f"\nTotal (Android + iOS):")
    print(f"  Raw:        {format_size(android_total + ios_total)}")
    print(f"  Compressed: {format_size(android_compressed + ios_compressed)}")
    
    # Generate markdown files
    generate_markdown_files(android_data, ios_data)
    
    # Print markdown tables to console
    print_markdown_table(android_data, ios_data)


if __name__ == "__main__":
    main()
