# Flutter Vips Benchmark Report

**Iterations:** 5
**Date:** 2025-12-09T11:32:42.605240

## Results

| Operation | Sync (ms) | Compute (ms) | Winner | Lead |
|-----------|-----------|--------------|--------|------|
| Resize (0.5x) | 427.2 | 434.4 | Sync | +1.7% |
| Thumbnail (200px) | 24.6 | 25.8 | Sync | +4.7% |
| Rotate (90°) | 1093.2 | 1167.8 | Sync | +6.4% |
| Flip Horizontal | 1295.4 | 1223.6 | Compute | +5.5% |
| Gaussian Blur (σ=3) | 1183.8 | 1243.4 | Sync | +4.8% |
| Sharpen | 1470.4 | 1556.4 | Sync | +5.5% |
| Invert | 1303.0 | 1403.8 | Sync | +7.2% |
| Brightness (+20%) | 1267.8 | 1019.2 | Compute | +19.6% |
| Contrast (+30%) | 1538.4 | 1338.8 | Compute | +13.0% |
| Auto Rotate | 1489.6 | 1308.8 | Compute | +12.1% |

## Summary

- **Sync wins:** 6
- **Compute wins:** 4
- **Total Sync time:** 11093.4ms
- **Total Compute time:** 10722.0ms

## Notes

- **Sync**: Runs on main thread, faster but blocks UI
- **Compute**: Uses Flutter `compute()`, runs in isolate, keeps UI responsive
