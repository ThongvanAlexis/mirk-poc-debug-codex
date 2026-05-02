// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

/// Computes a triangle wave between [minV] and [maxV] over [period] seconds.
double triangleWave({required double tSec, required double period, required double minV, required double maxV}) {
  if (period <= 0.0) return minV;
  final phase = (tSec % period) / period;
  final folded = phase < 0.5 ? phase * 2.0 : (1.0 - phase) * 2.0;
  return minV + folded * (maxV - minV);
}
