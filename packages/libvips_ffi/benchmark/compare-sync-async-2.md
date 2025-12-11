# Flutter Vips Benchmark Report

**Iterations:** 5
**Date:** 2025-12-09T13:10:22.196246

## Results

| Operation | Sync (ms) | Compute (ms) | Winner | Lead |
|-----------|-----------|--------------|--------|------|
| Resize (0.5x) | 320.2 | 361.8 | Sync | +11.5% |
| Thumbnail (200px) | 19.0 | 22.6 | Sync | +15.9% |
| Rotate (90°) | 991.0 | 1021.6 | Sync | +3.0% |
| Flip Horizontal | 985.8 | 995.2 | Sync | +0.9% |
| Gaussian Blur (σ=3) | 938.2 | 974.4 | Sync | +3.7% |
| Sharpen | 1123.4 | 1205.2 | Sync | +6.8% |
| Invert | 997.6 | 996.6 | Compute | +0.1% |
| Brightness (+20%) | 979.8 | 989.6 | Sync | +1.0% |
| Contrast (+30%) | 976.0 | 994.2 | Sync | +1.8% |
| Auto Rotate | 985.8 | 999.4 | Sync | +1.4% |

## Summary

- **Sync wins:** 9
- **Compute wins:** 1
- **Total Sync time:** 8316.8ms
- **Total Compute time:** 8560.6ms

## Notes

- **Sync**: Runs on main thread, faster but blocks UI
- **Compute**: Uses Flutter `compute()`, runs in isolate, keeps UI responsive
