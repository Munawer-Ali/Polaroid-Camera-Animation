import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/polaroid_palette.dart';

class PolaroidBodyPainter extends CustomPainter {
  const PolaroidBodyPainter({required this.isShutterPressed});

  final bool isShutterPressed;

  static const double _paddingX = 16;
  static const double _paddingTop = 16;
  static const double _paddingBottom = 32;

  static ({Offset center, double radius}) shutterHitArea(Size size) {
    final w = size.width - _paddingX * 2;
    final h = size.height - (_paddingTop + _paddingBottom);
    final trayH = h * 0.28;
    final lipH = h * 0.048;
    final ledgeH = h * 0.065;
    final topBodyH = h - trayH - ledgeH - lipH;
    final center = Offset(_paddingX + w * 0.20, _paddingTop + topBodyH * 0.68);
    return (center: center, radius: w * 0.065 * 1.35);
  }

  static Rect viewfinderRect(Size size) {
    final w = size.width - _paddingX * 2;
    final h = size.height - (_paddingTop + _paddingBottom);
    final trayH = h * 0.28;
    final lipH = h * 0.048;
    final ledgeH = h * 0.065;
    final topBodyH = h - trayH - ledgeH - lipH;
    return Rect.fromLTWH(
      _paddingX + w * 0.695,
      _paddingTop + topBodyH * 0.14,
      w * 0.215,
      w * 0.15,
    );
  }

  static Rect viewfinderInnerRect(Size size) => viewfinderRect(size).deflate(4);

  static double filmSlotTopY(Size size) {
    final h = size.height - (_paddingTop + _paddingBottom);
    final trayH = h * 0.28;
    final lipH = h * 0.048;
    final ledgeH = h * 0.065;
    final topBodyH = h - trayH - ledgeH - lipH;
    final trayTopY = topBodyH + ledgeH + lipH;
    return _paddingTop + trayTopY + trayH * 0.62;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - _paddingX * 2;
    final h = size.height - (_paddingTop + _paddingBottom);

    final trayW = w;
    final topBodyBottomW = w * 0.94;
    final topBodyTopW = w * 0.88;
    final trayH = h * 0.28;
    final lipH = h * 0.048;
    final ledgeH = h * 0.065;
    final topBodyH = h - trayH - ledgeH - lipH;

    const trayLeft = 0.0;
    final trayRight = w;
    final topBodyBottomLeft = (w - topBodyBottomW) / 2;
    final topBodyBottomRight = topBodyBottomLeft + topBodyBottomW;
    final topBodyTopLeft = (w - topBodyTopW) / 2;
    final topBodyTopRight = topBodyTopLeft + topBodyTopW;

    const topY = 0.0;
    final ledgeTopY = topBodyH;
    final lipTopY = ledgeTopY + ledgeH;
    final trayTopY = lipTopY + lipH;
    final bottomY = h;

    const topRadius = 24.0;
    const seamRadius = 3.0;
    const bottomRadius = 24.0;

    final topBumpW = w * 0.48;
    const topBumpH = 14.0;
    final topBumpX = (w - topBumpW) / 2;
    final topBumpY = topY - topBumpH + 4;
    final topBumpPath = Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        topBumpX,
        topBumpY,
        topBumpX + topBumpW,
        topY + 10,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ));

    final topBodyPath = Path()
      ..moveTo(topBodyBottomLeft, ledgeTopY)
      ..lineTo(topBodyTopLeft, topY + topRadius)
      ..quadraticBezierTo(topBodyTopLeft, topY, topBodyTopLeft + topRadius, topY)
      ..lineTo(topBodyTopRight - topRadius, topY)
      ..quadraticBezierTo(
          topBodyTopRight, topY, topBodyTopRight, topY + topRadius)
      ..lineTo(topBodyBottomRight, ledgeTopY)
      ..close();

    const lipCornerRadius = 6.0;
    final slantRatio = (ledgeH - lipCornerRadius) / ledgeH;
    final leftSlantX =
        topBodyBottomLeft + (trayLeft - topBodyBottomLeft) * slantRatio;
    final rightSlantX =
        topBodyBottomRight + (trayRight - topBodyBottomRight) * slantRatio;
    final ledgeAndLipPath = Path()
      ..moveTo(topBodyBottomLeft, ledgeTopY)
      ..lineTo(topBodyBottomRight, ledgeTopY)
      ..lineTo(rightSlantX, lipTopY - lipCornerRadius)
      ..quadraticBezierTo(trayRight, lipTopY, trayRight, lipTopY + lipCornerRadius)
      ..lineTo(trayRight, trayTopY)
      ..lineTo(trayLeft, trayTopY)
      ..lineTo(trayLeft, lipTopY + lipCornerRadius)
      ..quadraticBezierTo(
          trayLeft, lipTopY, leftSlantX, lipTopY - lipCornerRadius)
      ..close();

    final trayPath = Path()
      ..moveTo(trayLeft + seamRadius, trayTopY)
      ..lineTo(trayRight - seamRadius, trayTopY)
      ..quadraticBezierTo(trayRight, trayTopY, trayRight, trayTopY + seamRadius)
      ..lineTo(trayRight, bottomY - bottomRadius)
      ..quadraticBezierTo(trayRight, bottomY, trayRight - bottomRadius, bottomY)
      ..lineTo(trayLeft + bottomRadius, bottomY)
      ..quadraticBezierTo(trayLeft, bottomY, trayLeft, bottomY - bottomRadius)
      ..lineTo(trayLeft, trayTopY + seamRadius)
      ..quadraticBezierTo(trayLeft, trayTopY, trayLeft + seamRadius, trayTopY)
      ..close();

    final silhouettePath = Path()
      ..addPath(topBumpPath, Offset.zero)
      ..addPath(topBodyPath, Offset.zero)
      ..addPath(ledgeAndLipPath, Offset.zero)
      ..addPath(trayPath, Offset.zero);

    final housingCenter = Offset(w / 2, topBodyH * 0.48);
    final housingSize = topBodyBottomW * 0.35;
    final stripeStartY = housingCenter.dy + housingSize * 0.35;
    final shutterCenter = Offset(w * 0.20, topBodyH * 0.68);
    final shutterRadius = w * 0.065;
    final flashCenter = Offset(w * 0.88, topBodyH * 0.65);
    final flashSize = w * 0.12;
    final dialCenter = Offset(w * 0.75, topBodyH * 0.65);
    final dialRadius = w * 0.05;
    final vfRect = Rect.fromLTWH(w * 0.695, topBodyH * 0.14, w * 0.215, w * 0.15);

    canvas.save();
    canvas.translate(_paddingX, _paddingTop);

    // body drop shadow first, then build up from the back
    canvas.save();
    canvas.translate(-8, 30);
    canvas.drawPath(silhouettePath, _blur(Colors.black.withOpacity(0.5), 35));
    canvas.restore();

    canvas.drawPath(
      topBumpPath,
      _fill(ui.Gradient.linear(
        Offset(0, topBumpY),
        const Offset(0, topY),
        const [Color(0xFF2E2E2E), Color(0xFF0A0A0A)],
      )),
    );
    canvas.drawPath(
      topBumpPath,
      _strokeShader(
        ui.Gradient.linear(
          Offset(topBumpX + topBumpW, topBumpY),
          Offset(topBumpX, topBumpY + topBumpH),
          [Colors.white.withOpacity(0.25), Colors.transparent],
        ),
        2,
      ),
    );

    canvas.drawRect(
      Rect.fromLTWH(trayLeft, trayTopY - seamRadius, trayW, seamRadius * 2),
      Paint()..color = const Color(0xFF111111),
    );

    canvas.drawPath(
      trayPath,
      _fill(ui.Gradient.linear(
        Offset(0, trayTopY),
        Offset(0, bottomY),
        const [PolaroidPalette.chassisLight, PolaroidPalette.chassisDark],
      )),
    );

    canvas.drawPath(
      ledgeAndLipPath,
      _fill(ui.Gradient.linear(
        Offset(0, ledgeTopY),
        Offset(0, lipTopY),
        const [Color(0xFFE0DDD0), PolaroidPalette.bodyCreamShadow],
      )),
    );

    canvas.save();
    canvas.clipPath(ledgeAndLipPath);
    canvas.drawRect(
      Rect.fromLTWH(0, lipTopY, w, trayTopY - lipTopY),
      _fill(ui.Gradient.linear(
        Offset(0, lipTopY),
        Offset(0, trayTopY),
        [Colors.white.withOpacity(0.8), PolaroidPalette.bodyCreamLip],
      )),
    );
    canvas.drawLine(
      Offset(0, lipTopY),
      Offset(w, lipTopY),
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..strokeWidth = 4,
    );
    canvas.restore();

    canvas.drawPath(
      topBodyPath,
      _fill(ui.Gradient.linear(
        const Offset(0, topY),
        Offset(0, ledgeTopY),
        const [Colors.white, PolaroidPalette.bodyCream],
      )),
    );

    canvas.drawLine(
      Offset(topBodyTopLeft, topY + topRadius),
      Offset(topBodyBottomLeft, ledgeTopY),
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(topBodyTopRight, topY + topRadius),
      Offset(topBodyBottomRight, ledgeTopY),
      Paint()
        ..color = Colors.black.withOpacity(0.05)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(topBodyBottomLeft, ledgeTopY),
      Offset(topBodyBottomRight, ledgeTopY),
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(trayLeft + seamRadius, trayTopY),
      Offset(trayRight - seamRadius, trayTopY),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(topBodyBottomLeft, ledgeTopY),
      Offset(leftSlantX, lipTopY - lipCornerRadius),
      _strokeShader(
        ui.Gradient.linear(
          Offset(topBodyBottomLeft, ledgeTopY),
          Offset(leftSlantX, lipTopY - lipCornerRadius),
          [Colors.white.withOpacity(0.6), Colors.transparent],
        ),
        4,
      ),
    );
    canvas.drawLine(
      Offset(topBodyBottomRight, ledgeTopY),
      Offset(rightSlantX, lipTopY - lipCornerRadius),
      _strokeShader(
        ui.Gradient.linear(
          Offset(topBodyBottomRight, ledgeTopY),
          Offset(rightSlantX, lipTopY - lipCornerRadius),
          [Colors.white.withOpacity(0.6), Colors.transparent],
        ),
        4,
      ),
    );

    _drawPerspectiveStripe(
        canvas, w, topBodyBottomW, stripeStartY, ledgeTopY, lipTopY, trayTopY);
    _drawLensAssembly(canvas, housingCenter, housingSize);
    _drawBranding(canvas, w, topY, topBodyH);
    _drawFlash(canvas, flashCenter, flashSize);
    _drawShutterButton(canvas, shutterCenter, shutterRadius, isShutterPressed);
    _drawExposureDial(canvas, dialCenter, dialRadius);
    _drawViewfinderBezel(canvas, vfRect);
    _drawBottomTrayDetails(canvas, trayLeft, trayTopY, trayW, trayH);

    canvas.restore();
  }

  @override
  bool shouldRepaint(PolaroidBodyPainter old) =>
      old.isShutterPressed != isShutterPressed;
}

double _blurSigma(double radius) => radius * 0.57735 + 0.5;

Paint _blur(Color color, double blurRadius) => Paint()
  ..color = color
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, _blurSigma(blurRadius));

Paint _fill(ui.Shader shader) => Paint()..shader = shader;

Paint _strokeShader(ui.Shader shader, double width) => Paint()
  ..shader = shader
  ..style = PaintingStyle.stroke
  ..strokeWidth = width;

void _drawPerspectiveStripe(
  Canvas canvas,
  double w,
  double topBodyW,
  double startY,
  double ledgeTopY,
  double lipTopY,
  double trayTopY,
) {
  final colors = PolaroidPalette.rainbowColors;
  final topStripeW = topBodyW * 0.075;
  final bottomStripeW = topStripeW * 1.4;
  final topX = (w - topStripeW) / 2;
  final bottomX = (w - bottomStripeW) / 2;
  final topSegmentW = topStripeW / colors.length;
  final bottomSegmentW = bottomStripeW / colors.length;
  final controlPointOffset = (lipTopY - ledgeTopY) * 0.4;

  for (var index = 0; index < colors.length; index++) {
    final color = colors[index];
    final segTopX = topX + index * topSegmentW;
    final segBottomX = bottomX + index * bottomSegmentW;
    final paint = Paint()..color = color;

    canvas.drawRect(
      Rect.fromLTWH(segTopX, startY, topSegmentW, ledgeTopY - startY),
      paint,
    );

    final flarePath = Path()
      ..moveTo(segTopX, ledgeTopY)
      ..lineTo(segTopX + topSegmentW, ledgeTopY)
      ..cubicTo(
        segTopX + topSegmentW,
        ledgeTopY + controlPointOffset,
        segBottomX + bottomSegmentW,
        lipTopY - controlPointOffset,
        segBottomX + bottomSegmentW,
        lipTopY,
      )
      ..lineTo(segBottomX, lipTopY)
      ..cubicTo(
        segBottomX,
        lipTopY - controlPointOffset,
        segTopX,
        ledgeTopY + controlPointOffset,
        segTopX,
        ledgeTopY,
      )
      ..close();
    canvas.drawPath(flarePath, paint);

    canvas.drawRect(
      Rect.fromLTWH(segBottomX, lipTopY, bottomSegmentW, trayTopY - lipTopY),
      paint,
    );
  }

  final slantedShadowPath = Path()
    ..moveTo(topX, ledgeTopY)
    ..lineTo(topX + topStripeW, ledgeTopY)
    ..cubicTo(
      topX + topStripeW,
      ledgeTopY + controlPointOffset,
      bottomX + bottomStripeW,
      lipTopY - controlPointOffset,
      bottomX + bottomStripeW,
      lipTopY,
    )
    ..lineTo(bottomX, lipTopY)
    ..cubicTo(
      bottomX,
      lipTopY - controlPointOffset,
      topX,
      ledgeTopY + controlPointOffset,
      topX,
      ledgeTopY,
    )
    ..close();
  canvas.drawPath(
    slantedShadowPath,
    _fill(ui.Gradient.linear(
      Offset(0, ledgeTopY),
      Offset(0, lipTopY),
      [Colors.black.withOpacity(0), Colors.black.withOpacity(0.35)],
    )),
  );

  canvas.drawRect(
    Rect.fromLTWH(bottomX, lipTopY, bottomStripeW, trayTopY - lipTopY),
    _fill(ui.Gradient.linear(
      Offset(0, lipTopY),
      Offset(0, trayTopY),
      [Colors.white.withOpacity(0.4), Colors.transparent],
    )),
  );
}

void _drawLensAssembly(Canvas canvas, Offset center, double size) {
  final cornerR = size * 0.15;
  final topLeft = Offset(center.dx - size / 2, center.dy - size / 2);
  final topRight = Offset(center.dx + size / 2, center.dy - size / 2);
  final bottomLeft = Offset(center.dx - size / 2, center.dy + size / 2);

  canvas.drawRRect(
    RRect.fromLTRBR(
      topLeft.dx - 6,
      topLeft.dy + 16,
      topLeft.dx + size - 6,
      topLeft.dy + size + 16,
      Radius.circular(cornerR),
    ),
    _blur(Colors.black.withOpacity(0.4), 25),
  );

  final rimSize = size + 8;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - rimSize / 2, center.dy - rimSize / 2, rimSize,
          rimSize),
      Radius.circular(rimSize * 0.15),
    ),
    Paint()..color = PolaroidPalette.bodyCream,
  );

  final innerRimSize = size + 2;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - innerRimSize / 2, center.dy - innerRimSize / 2,
          innerRimSize, innerRimSize),
      Radius.circular(innerRimSize * 0.15),
    ),
    Paint()..color = const Color(0xFFC7C5B5),
  );

  final bodyRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size, size);
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerR)),
    _fill(ui.Gradient.linear(
      topRight,
      bottomLeft,
      const [Color(0xFF2B2B2B), Color(0xFF030303)],
    )),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerR)),
    _strokeShader(
      ui.Gradient.linear(
        topRight,
        center,
        [Colors.white.withOpacity(0.15), Colors.transparent],
      ),
      2,
    ),
  );

  const numRibs = 35;
  final funnelOuterSize = size * 0.85;
  final innerHoleSize = size * 0.48;
  final ribStep = (funnelOuterSize - innerHoleSize) / 2 / numRibs;
  final funnelTopLeft =
      Offset(center.dx - funnelOuterSize / 2, center.dy - funnelOuterSize / 2);

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
          funnelTopLeft.dx, funnelTopLeft.dy, funnelOuterSize, funnelOuterSize),
      Radius.circular(cornerR * 0.85),
    ),
    _strokeShader(
      ui.Gradient.linear(
          topRight, bottomLeft, const [Colors.black, Color(0xFF2A2A2A)]),
      3,
    ),
  );

  for (var i = 0; i <= numRibs; i++) {
    final currentSize = funnelOuterSize - i * ribStep * 2;
    final currentCorner =
        cornerR * 0.85 - i * (cornerR * 0.4 / numRibs);
    final currentTopLeft =
        Offset(center.dx - currentSize / 2, center.dy - currentSize / 2);
    final currentTopRight =
        Offset(center.dx + currentSize / 2, center.dy - currentSize / 2);
    final currentBottomLeft =
        Offset(center.dx - currentSize / 2, center.dy + currentSize / 2);
    final ribRect =
        Rect.fromLTWH(currentTopLeft.dx, currentTopLeft.dy, currentSize, currentSize);

    canvas.drawRRect(
      RRect.fromRectAndRadius(ribRect, Radius.circular(currentCorner)),
      Paint()
        ..color = const Color(0xFF080808)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ribRect, Radius.circular(currentCorner)),
      _strokeShader(
        ui.Gradient.linear(
          currentTopRight,
          currentBottomLeft,
          [Colors.white.withOpacity(0.12), Colors.transparent, Colors.transparent],
          const [0.0, 0.5, 1.0],
        ),
        1,
      ),
    );
  }

  final craterTopLeft =
      Offset(center.dx - innerHoleSize / 2, center.dy - innerHoleSize / 2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
          craterTopLeft.dx, craterTopLeft.dy, innerHoleSize, innerHoleSize),
      const Radius.circular(14),
    ),
    _fill(ui.Gradient.linear(
      Offset(center.dx + innerHoleSize / 2, center.dy - innerHoleSize / 2),
      Offset(center.dx - innerHoleSize / 2, center.dy + innerHoleSize / 2),
      const [Color(0xFF000000), Color(0xFF252525)],
    )),
  );

  final glassSize = innerHoleSize * 0.85;
  final glassTopLeft =
      Offset(center.dx - glassSize / 2, center.dy - glassSize / 2);
  final glassRect =
      Rect.fromLTWH(glassTopLeft.dx, glassTopLeft.dy, glassSize, glassSize);
  final glassPath = Path()
    ..addRRect(RRect.fromRectAndRadius(glassRect, Radius.circular(glassSize * 0.1)));

  canvas.drawPath(
    glassPath,
    _fill(ui.Gradient.radial(
      center,
      glassSize * 0.8,
      const [Color(0xFF13181A), Color(0xFF010202)],
    )),
  );

  final specular = _blur(Colors.white.withOpacity(0.85), 1);

  canvas.save();
  canvas.clipPath(glassPath);

  _withRotation(canvas, -30, center, () {
    canvas.drawOval(
      Rect.fromLTWH(center.dx - glassSize, center.dy - glassSize * 0.6,
          glassSize * 2, glassSize * 0.8),
      _fill(ui.Gradient.linear(
        Offset(center.dx - glassSize, center.dy - glassSize * 0.6),
        Offset(center.dx - glassSize, center.dy - glassSize * 0.6 + glassSize * 0.8),
        [Colors.white.withOpacity(0.08), Colors.transparent],
      )),
    );
  });

  _withRotation(canvas, -35, center, () {
    final mainRect = Rect.fromLTRB(
      center.dx - glassSize * 0.15,
      center.dy - glassSize * 0.28,
      center.dx + glassSize * 0.15,
      center.dy - glassSize * 0.12,
    );
    final mainCutout = Rect.fromLTRB(
      center.dx - glassSize * 0.12,
      center.dy - glassSize * 0.24,
      center.dx + glassSize * 0.18,
      center.dy - glassSize * 0.08,
    );
    final mainPath = Path()
      ..addRRect(RRect.fromRectAndRadius(mainRect, Radius.circular(glassSize * 0.1)));
    final mainSubPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(mainCutout, Radius.circular(glassSize * 0.1)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, mainPath, mainSubPath),
      specular,
    );

    final dotRect = Rect.fromLTRB(
      center.dx + glassSize * 0.18,
      center.dy - glassSize * 0.15,
      center.dx + glassSize * 0.28,
      center.dy - glassSize * 0.08,
    );
    final dotCutout = Rect.fromLTRB(
      center.dx + glassSize * 0.21,
      center.dy - glassSize * 0.12,
      center.dx + glassSize * 0.31,
      center.dy - glassSize * 0.05,
    );
    final dotPath = Path()
      ..addRRect(RRect.fromRectAndRadius(dotRect, Radius.circular(glassSize * 0.05)));
    final dotSubPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(dotCutout, Radius.circular(glassSize * 0.05)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, dotPath, dotSubPath),
      specular,
    );
  });

  canvas.restore();
}

void _drawViewfinderBezel(Canvas canvas, Rect r) {
  final outer = r.inflate(3);

  canvas.drawRRect(
    RRect.fromRectAndRadius(outer.shift(const Offset(-2, 5)), const Radius.circular(9)),
    _blur(Colors.black.withOpacity(0.35), 10),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(outer.inflate(3), const Radius.circular(11)),
    Paint()..color = PolaroidPalette.bodyCreamShadow,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(outer, const Radius.circular(9)),
    _fill(ui.Gradient.linear(
      outer.topRight,
      outer.bottomLeft,
      const [Color(0xFF3A3A3A), Color(0xFF101010)],
    )),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(r, const Radius.circular(6)),
    Paint()..color = const Color(0xFF050505),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(outer, const Radius.circular(9)),
    _strokeShader(
      ui.Gradient.linear(
        outer.topRight,
        outer.center,
        [Colors.white.withOpacity(0.25), Colors.transparent],
      ),
      1.5,
    ),
  );
}

void _drawFlash(Canvas canvas, Offset center, double size) {
  final cornerR = size * 0.18;
  final topLeft = Offset(center.dx - size / 2, center.dy - size / 2);
  final topRight = Offset(center.dx + size / 2, center.dy - size / 2);
  final bottomLeft = Offset(center.dx - size / 2, center.dy + size / 2);

  canvas.drawRRect(
    RRect.fromLTRBR(
      topLeft.dx - 4,
      topLeft.dy + 10,
      topLeft.dx + size - 4,
      topLeft.dy + size + 10,
      Radius.circular(cornerR),
    ),
    _blur(Colors.black.withOpacity(0.4), 15),
  );

  final bodyRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size, size);
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerR)),
    _fill(ui.Gradient.linear(
        topRight, bottomLeft, const [Color(0xFF383838), Color(0xFF121212)])),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerR)),
    _strokeShader(
      ui.Gradient.linear(
          topRight, center, [Colors.white.withOpacity(0.2), Colors.transparent]),
      1.5,
    ),
  );

  final innerSize = size * 0.65;
  final innerTopLeft =
      Offset(center.dx - innerSize / 2, center.dy - innerSize / 2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(innerTopLeft.dx, innerTopLeft.dy, innerSize, innerSize),
      Radius.circular(innerSize * 0.15),
    ),
    _fill(ui.Gradient.linear(
      Offset(center.dx + innerSize / 2, center.dy - innerSize / 2),
      Offset(center.dx - innerSize / 2, center.dy + innerSize / 2),
      const [Color(0xFF030303), Color(0xFF222222)],
    )),
  );

  final glassSize = innerSize * 0.90;
  final glassTopLeft =
      Offset(center.dx - glassSize / 2, center.dy - glassSize / 2);
  final glassRect =
      Rect.fromLTWH(glassTopLeft.dx, glassTopLeft.dy, glassSize, glassSize);
  final glassPath = Path()
    ..addRRect(RRect.fromRectAndRadius(glassRect, Radius.circular(glassSize * 0.1)));

  canvas.drawPath(
    glassPath,
    _fill(ui.Gradient.radial(
        center, glassSize * 0.8, const [Color(0xFF151515), Color(0xFF000000)])),
  );

  canvas.save();
  canvas.clipPath(glassPath);

  final bulbW = glassSize * 0.45;
  final bulbH = glassSize * 0.35;
  final bulbTopLeft = Offset(center.dx - bulbW / 2, center.dy - bulbH / 2);
  final bulbRect = Rect.fromLTWH(bulbTopLeft.dx, bulbTopLeft.dy, bulbW, bulbH);
  canvas.drawRRect(
    RRect.fromRectAndRadius(bulbRect, Radius.circular(bulbW * 0.2)),
    Paint()..color = const Color(0xFFE5E5E5),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bulbRect, Radius.circular(bulbW * 0.2)),
    _fill(ui.Gradient.linear(
      bulbTopLeft,
      Offset(bulbTopLeft.dx, bulbTopLeft.dy + bulbH),
      [Colors.black.withOpacity(0.4), Colors.transparent],
    )),
  );

  final reflectionPath = Path()
    ..moveTo(glassTopLeft.dx, glassTopLeft.dy)
    ..lineTo(glassTopLeft.dx + glassSize, glassTopLeft.dy)
    ..lineTo(glassTopLeft.dx + glassSize, glassTopLeft.dy + glassSize * 0.5)
    ..quadraticBezierTo(
      center.dx,
      center.dy - glassSize * 0.1,
      glassTopLeft.dx,
      glassTopLeft.dy + glassSize * 0.6,
    )
    ..close();
  canvas.drawPath(
    reflectionPath,
    _fill(ui.Gradient.linear(
      Offset(center.dx + glassSize / 2, center.dy - glassSize / 2),
      Offset(center.dx - glassSize / 2, center.dy + glassSize / 2),
      [Colors.white.withOpacity(0.35), Colors.white.withOpacity(0.05)],
    )),
  );

  canvas.restore();
}

void _drawShutterButton(
    Canvas canvas, Offset center, double radius, bool isPressed) {
  final outerCollarRadius = radius * 1.35;

  canvas.drawOval(
    Rect.fromLTRB(
      center.dx - outerCollarRadius - 4,
      center.dy - outerCollarRadius + 8,
      center.dx + outerCollarRadius - 4,
      center.dy + outerCollarRadius + 8,
    ),
    _blur(Colors.black.withOpacity(0.3), 12),
  );

  canvas.drawCircle(
    center,
    outerCollarRadius,
    _fill(ui.Gradient.linear(
      Offset(center.dx - outerCollarRadius, center.dy - outerCollarRadius),
      Offset(center.dx + outerCollarRadius, center.dy + outerCollarRadius),
      const [Color(0xFFE2DFCD), Color(0xFFA5A394)],
    )),
  );

  final pressOffset = isPressed ? const Offset(-1, 3) : Offset.zero;
  final buttonCenter = center + pressOffset;

  canvas.drawCircle(
    Offset(center.dx, center.dy + 4),
    radius * 1.05,
    Paint()..color = Colors.black.withOpacity(0.4),
  );

  canvas.drawCircle(
    buttonCenter,
    radius,
    _fill(ui.Gradient.radial(
      buttonCenter,
      radius * 1.5,
      const [PolaroidPalette.shutterRedHighlight, PolaroidPalette.shutterRed],
    )),
  );
  canvas.drawCircle(
    buttonCenter,
    radius,
    _fill(ui.Gradient.linear(
      Offset(buttonCenter.dx - radius, buttonCenter.dy - radius),
      buttonCenter,
      [Colors.transparent, Colors.black.withOpacity(0.25)],
    )),
  );
  canvas.drawCircle(
    buttonCenter,
    radius,
    _fill(ui.Gradient.sweep(
      buttonCenter,
      [
        Colors.black.withOpacity(0.1),
        Colors.white.withOpacity(0.1),
        Colors.black.withOpacity(0.1),
        Colors.white.withOpacity(0.1),
        Colors.black.withOpacity(0.1),
        Colors.white.withOpacity(0.1),
        Colors.black.withOpacity(0.1),
      ],
      const [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 1.0],
    )),
  );
  canvas.drawCircle(
    buttonCenter,
    radius * 0.98,
    Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );

  _withRotation(canvas, -35, buttonCenter, () {
    canvas.drawOval(
      Rect.fromLTRB(
        buttonCenter.dx - radius * 0.2,
        buttonCenter.dy - radius * 0.7,
        buttonCenter.dx + radius * 0.4,
        buttonCenter.dy - radius * 0.4,
      ),
      _blur(Colors.white.withOpacity(isPressed ? 0.4 : 0.75), 3),
    );
  });
}

void _drawExposureDial(Canvas canvas, Offset center, double radius) {
  canvas.drawOval(
    Rect.fromLTRB(
      center.dx - radius - 4,
      center.dy - radius + 8,
      center.dx + radius - 4,
      center.dy + radius + 8,
    ),
    _blur(Colors.black.withOpacity(0.4), 10),
  );

  canvas.drawCircle(
    center,
    radius,
    _fill(ui.Gradient.linear(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx - radius, center.dy + radius),
      const [Color(0xFF383838), Color(0xFF0A0A0A)],
    )),
  );
  canvas.drawCircle(
      center, radius * 0.88, Paint()..color = const Color(0xFF050505));

  final topRadius = radius * 0.82;
  canvas.drawCircle(
    center,
    topRadius,
    _fill(ui.Gradient.linear(
      Offset(center.dx + topRadius, center.dy - topRadius),
      Offset(center.dx - topRadius, center.dy + topRadius),
      const [Color(0xFF1E1E1E), Color(0xFF111111)],
    )),
  );

  _withRotation(canvas, 45, center, () {
    canvas.drawOval(
      Rect.fromLTRB(
        center.dx - topRadius * 0.6,
        center.dy - topRadius * 0.8,
        center.dx + topRadius * 0.6,
        center.dy - topRadius * 0.2,
      ),
      _blur(Colors.white.withOpacity(0.15), 4),
    );
  });
}

void _drawBranding(
    Canvas canvas, double w, double topY, double topBodyH) {
  final stickerWidth = w * 0.18;
  final stickerHeight = stickerWidth * 0.85;
  final stickerX = w * 0.11;
  final stickerY = topY + topBodyH * 0.10;

  canvas.drawRRect(
    RRect.fromLTRBR(
      stickerX - 2,
      stickerY + 6,
      stickerX + stickerWidth - 2,
      stickerY + stickerHeight + 6,
      const Radius.circular(6),
    ),
    _blur(Colors.black.withOpacity(0.2), 8),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stickerX, stickerY, stickerWidth, stickerHeight),
      const Radius.circular(6),
    ),
    Paint()..color = PolaroidPalette.stickerBeige,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stickerX + 1, stickerY + 1, stickerWidth - 2, stickerHeight - 2),
      const Radius.circular(5),
    ),
    Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );

  const numLines = 14;
  final lineSpacing = stickerHeight / (numLines + 1);
  for (var i = 1; i <= numLines; i++) {
    final lineY = stickerY + i * lineSpacing;
    canvas.drawLine(
      Offset(stickerX + 4, lineY),
      Offset(stickerX + stickerWidth - 4, lineY),
      Paint()
        ..color = const Color(0xFFD4D0B3)
        ..strokeWidth = 1.5,
    );
  }

  final leftPadding = stickerWidth * 0.12;
  _drawText(
    canvas,
    'Supercolor',
    Offset(stickerX + leftPadding, stickerY + stickerHeight * 0.15),
    const TextStyle(
      color: Color(0xFFD11A00),
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
  );
  _drawText(
    canvas,
    '1000',
    Offset(stickerX + leftPadding, stickerY + stickerHeight * 0.38),
    TextStyle(
      color: const Color(0xFF151515),
      fontSize: 21,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(-2, 3),
          blurRadius: 4,
        ),
      ],
    ),
  );
}

void _drawBottomTrayDetails(
  Canvas canvas,
  double startX,
  double startY,
  double trayW,
  double trayH,
) {
  final panelWidth = trayW * 0.90;
  final panelHeight = trayH * 0.35;
  final panelX = startX + (trayW - panelWidth) / 2;
  final panelY = startY + trayH * 0.12;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(panelX - 2, panelY - 2, panelWidth + 4, panelHeight + 4),
      const Radius.circular(6),
    ),
    Paint()..color = const Color(0xFF050505),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(panelX, panelY, panelWidth, panelHeight),
      const Radius.circular(6),
    ),
    Paint()..color = PolaroidPalette.panelRecess,
  );

  const numRibs = 6;
  final ribSpacing = panelHeight / (numRibs + 1);
  for (var i = 1; i <= numRibs; i++) {
    final yPos = panelY + i * ribSpacing;
    canvas.drawLine(
      Offset(panelX + 8, yPos),
      Offset(panelX + panelWidth - 8, yPos),
      Paint()
        ..color = const Color(0xFF0F0F0F)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(panelX + 8, yPos + 2),
      Offset(panelX + panelWidth - 8, yPos + 2),
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..strokeWidth = 2,
    );
  }

  _drawText(
    canvas,
    'POLAROID LAND CAMERA',
    Offset(panelX + trayW * 0.04, panelY + panelHeight * 0.25),
    const TextStyle(
      color: PolaroidPalette.textColor,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
    ),
  );

  final slotWidth = trayW * 0.86;
  final slotHeight = trayH * 0.26;
  final slotX = startX + (trayW - slotWidth) / 2;
  final slotY = startY + trayH * 0.62;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(slotX - 4, slotY - 4, slotWidth + 8, slotHeight + 8),
      const Radius.circular(6),
    ),
    Paint()..color = const Color(0xFF1E1E1E),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(slotX, slotY, slotWidth, slotHeight),
      const Radius.circular(4),
    ),
    Paint()..color = const Color(0xFF050505),
  );

  final lipHeight = slotHeight * 0.5;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(slotX + 4, slotY + 2, slotWidth - 8, lipHeight),
      const Radius.circular(3),
    ),
    _fill(ui.Gradient.linear(
      Offset(0, slotY + 2),
      Offset(0, slotY + lipHeight),
      const [
        Color(0xFF0F0F0F),
        Color(0xFF6A6A6A),
        Color(0xFF222222),
        Color(0xFF050505),
      ],
      const [0.0, 0.4, 0.6, 1.0],
    )),
  );
}

void _withRotation(Canvas canvas, double degrees, Offset pivot, VoidCallback body) {
  canvas.save();
  canvas.translate(pivot.dx, pivot.dy);
  canvas.rotate(degrees * math.pi / 180);
  canvas.translate(-pivot.dx, -pivot.dy);
  body();
  canvas.restore();
}

void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, offset);
}
