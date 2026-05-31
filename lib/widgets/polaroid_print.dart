import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PolaroidPrint extends StatefulWidget {
  const PolaroidPrint({
    super.key,
    required this.image,
    required this.offsetY,
    required this.rotationDegrees,
    required this.develop,
    required this.onTap,
    this.onDoubleTap,
    this.stow = 0,
  });

  final ui.Image? image;
  final double offsetY;
  final double rotationDegrees;

  final double develop;
  final VoidCallback onTap;

  final VoidCallback? onDoubleTap;

  final double stow;

  @override
  State<PolaroidPrint> createState() => _PolaroidPrintState();
}

class _PolaroidPrintState extends State<PolaroidPrint> {
  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = const [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.75;
        final height = width / 0.82;

        // stow: fly down into the tray while shrinking and fading
        final s = Curves.easeInCubic.transform(widget.stow.clamp(0.0, 1.0));
        final stowDy = s * (constraints.maxHeight - widget.offsetY);
        final scale = 1 - 0.82 * s;
        final opacity = (1 - Curves.easeIn.transform(s)).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, widget.offsetY + stowDy),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: Transform.rotate(
              angle: widget.rotationDegrees * math.pi / 180,
              child: Opacity(
                opacity: opacity,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: _buildPrint(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrint() {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onPanStart: (d) => setState(() => _currentLine = [d.localPosition]),
      onPanUpdate: (d) =>
          setState(() => _currentLine = [..._currentLine, d.localPosition]),
      onPanEnd: (_) => setState(() {
        if (_currentLine.isNotEmpty) {
          _lines.add(_currentLine);
          _currentLine = const [];
        }
      }),
      onPanCancel: () => setState(() => _currentLine = const []),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F0),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 12, top: 12, right: 12, bottom: 48),
              child: ClipRect(child: _buildDevelopingPhoto()),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _SharpiePainter(
                  completedLines: _lines,
                  currentLine: _currentLine,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopingPhoto() {
    final t = widget.develop.clamp(0.0, 1.0);

    Widget photo = Container(
      color: const Color(0xFF0E1512),
      child: widget.image == null
          ? null
          : RawImage(image: widget.image, fit: BoxFit.cover),
    );

    return SizedBox.expand(child: photo);
  }
}

List<double> _developColorMatrix(double t) {
  final s = 0.15 + 0.85 * t;
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final inv = 1 - s;
  final r = inv * lr, g = inv * lg, b = inv * lb;

  final c = 0.75 + 0.25 * t;
  final cb = 128 * (1 - c);

  final h = 1 - t;
  final biasR = 18.0 * h;
  final biasG = 42.0 * h;
  final biasB = 30.0 * h;

  return <double>[
    (r + s) * c, g * c, b * c, 0, biasR + cb,
    r * c, (g + s) * c, b * c, 0, biasG + cb,
    r * c, g * c, (b + s) * c, 0, biasB + cb,
    0, 0, 0, 1, 0,
  ];
}

class _SharpiePainter extends CustomPainter {
  _SharpiePainter({required this.completedLines, required this.currentLine});

  final List<List<Offset>> completedLines;
  final List<Offset> currentLine;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.0;
    final paint = Paint()
      ..color = const Color(0xFF18181A).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()..color = const Color(0xFF18181A).withOpacity(0.85);

    for (final line in completedLines) {
      _drawLine(canvas, line, paint, dotPaint, strokeWidth);
    }
    _drawLine(canvas, currentLine, paint, dotPaint, strokeWidth);
  }

  void _drawLine(Canvas canvas, List<Offset> line, Paint paint, Paint dotPaint,
      double strokeWidth) {
    if (line.length > 1) {
      final path = Path()..moveTo(line.first.dx, line.first.dy);
      for (var i = 1; i < line.length; i++) {
        path.lineTo(line[i].dx, line[i].dy);
      }
      canvas.drawPath(path, paint);
    } else if (line.length == 1) {
      canvas.drawCircle(line.first, strokeWidth / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SharpiePainter old) =>
      old.completedLines != completedLines || old.currentLine != currentLine;
}
