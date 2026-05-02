// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

import 'package:mirk_poc_debug/infrastructure/mirk/animation_helpers.dart';
import 'package:test/test.dart';

void main() {
  test('triangleWave returns min, max, then min over one period', () {
    expect(triangleWave(tSec: 0.0, period: 10.0, minV: 2.0, maxV: 6.0), equals(2.0));
    expect(triangleWave(tSec: 2.5, period: 10.0, minV: 2.0, maxV: 6.0), equals(4.0));
    expect(triangleWave(tSec: 5.0, period: 10.0, minV: 2.0, maxV: 6.0), equals(6.0));
    expect(triangleWave(tSec: 10.0, period: 10.0, minV: 2.0, maxV: 6.0), equals(2.0));
  });

  test('triangleWave wraps times after the period', () {
    expect(triangleWave(tSec: 12.5, period: 10.0, minV: 2.0, maxV: 6.0), equals(4.0));
  });

  test('triangleWave returns min for non-positive periods', () {
    expect(triangleWave(tSec: 5.0, period: 0.0, minV: 2.0, maxV: 6.0), equals(2.0));
    expect(triangleWave(tSec: 5.0, period: -1.0, minV: 2.0, maxV: 6.0), equals(2.0));
  });
}
