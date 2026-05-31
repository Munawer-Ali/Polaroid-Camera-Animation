import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polaroid_camera/painters/polaroid_body_painter.dart';

void main() {
  const size = Size(400, 480);
  final bounds = Offset.zero & size;

  test('shutter hit area sits inside the body with a positive radius', () {
    final area = PolaroidBodyPainter.shutterHitArea(size);
    expect(area.radius, greaterThan(0));
    expect(bounds.contains(area.center), isTrue);
  });

  test('viewfinder rect is within the widget bounds', () {
    final vf = PolaroidBodyPainter.viewfinderRect(size);
    expect(vf.left, greaterThanOrEqualTo(0));
    expect(vf.top, greaterThanOrEqualTo(0));
    expect(vf.right, lessThanOrEqualTo(size.width));
    expect(vf.bottom, lessThanOrEqualTo(size.height));
  });

  test('viewfinder inner rect is the outer rect deflated by 4', () {
    final outer = PolaroidBodyPainter.viewfinderRect(size);
    final inner = PolaroidBodyPainter.viewfinderInnerRect(size);
    expect(inner, outer.deflate(4));
  });

  test('film slot Y is below the top and above the bottom', () {
    final y = PolaroidBodyPainter.filmSlotTopY(size);
    expect(y, greaterThan(0));
    expect(y, lessThan(size.height));
  });

  test('geometry scales with size', () {
    final small = PolaroidBodyPainter.shutterHitArea(const Size(200, 240));
    final large = PolaroidBodyPainter.shutterHitArea(const Size(800, 960));
    expect(large.radius, greaterThan(small.radius));
  });
}
