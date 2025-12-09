#!/bin/bash

# Check the size of files that would be published to pub.dev
# pub.dev has a 100MB limit for package archives

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PACKAGE_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         Flutter Vips Package Size Analysis                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Package directory: $PACKAGE_DIR"
echo ""

# Check if .pubignore exists
if [ -f ".pubignore" ]; then
    echo "📄 .pubignore found:"
    echo "---"
    cat .pubignore
    echo "---"
    echo ""
fi

echo "┌──────────────────────────────────────────────────────────────┐"
echo "│ Dart Files in lib/                                           │"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""

# List all dart files with sizes
find lib -name "*.dart" -type f -exec ls -la {} + 2>/dev/null | \
    awk '{printf "  %8.2f KB  %s\n", $5/1024, $9}' | sort -rn

echo ""
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│ Size Breakdown                                               │"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""

# Calculate sizes
bindings_size=$(wc -c < lib/src/bindings/vips_bindings_generated.dart 2>/dev/null || echo 0)
bindings_kb=$(echo "scale=2; $bindings_size / 1024" | bc)

other_dart_size=$(find lib -name "*.dart" -type f ! -name "vips_bindings_generated.dart" -exec cat {} + 2>/dev/null | wc -c)
other_dart_kb=$(echo "scale=2; $other_dart_size / 1024" | bc)

echo "  Generated bindings:  ${bindings_kb} KB"
echo "  Other Dart files:    ${other_dart_kb} KB"

# Other files
other_files=("pubspec.yaml" "README.md" "CHANGELOG.md" "LICENSE" "analysis_options.yaml")
other_size=0
echo ""
echo "  Other package files:"
for file in "${other_files[@]}"; do
    if [ -f "$file" ]; then
        file_size=$(wc -c < "$file")
        other_size=$((other_size + file_size))
        file_kb=$(echo "scale=2; $file_size / 1024" | bc)
        echo "    $file: ${file_kb} KB"
    fi
done

total_bytes=$((bindings_size + other_dart_size + other_size))
total_kb=$(echo "scale=2; $total_bytes / 1024" | bc)
total_mb=$(echo "scale=2; $total_bytes / 1024 / 1024" | bc)

echo ""
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│ Summary                                                      │"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""
echo "  📦 Estimated uncompressed size: ${total_kb} KB (${total_mb} MB)"
echo "  📊 pub.dev limit: 100 MB"
echo ""

if (( $(echo "$total_mb > 100" | bc -l) )); then
    echo "  ⚠️  WARNING: Package may exceed pub.dev size limit!"
elif (( $(echo "$total_mb > 10" | bc -l) )); then
    echo "  ⚡ Package is large but within limits"
else
    echo "  ✅ Package size is well within pub.dev limits"
fi

echo ""
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│ Dry Run Publish Check                                        │"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""
dart pub publish --dry-run 2>&1 | head -30 || true
