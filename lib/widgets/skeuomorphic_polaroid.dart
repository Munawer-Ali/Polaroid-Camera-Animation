import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../painters/polaroid_body_painter.dart';
import 'live_camera_preview.dart';

class SkeuomorphicPolaroid extends StatefulWidget {
  const SkeuomorphicPolaroid({
    super.key,
    required this.onShutterClick,
    this.controller,
  });

  final VoidCallback onShutterClick;

  final CameraController? controller;

  @override
  State<SkeuomorphicPolaroid> createState() => _SkeuomorphicPolaroidState();
}

class _SkeuomorphicPolaroidState extends State<SkeuomorphicPolaroid> {
  bool _pressed = false;
  bool _armed = false;

  bool _hitsShutter(Offset localPosition, Size size) {
    final area = PolaroidBodyPainter.shutterHitArea(size);
    return (localPosition - area.center).distance <= area.radius;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final vf = PolaroidBodyPainter.viewfinderInnerRect(size);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (_hitsShutter(details.localPosition, size)) {
              _armed = true;
              setState(() => _pressed = true);
            }
          },
          onTapUp: (_) {
            if (_armed) {
              _armed = false;
              setState(() => _pressed = false);
              widget.onShutterClick();
            }
          },
          onTapCancel: () {
            if (_armed) {
              _armed = false;
              setState(() => _pressed = false);
            }
          },
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: PolaroidBodyPainter(isShutterPressed: _pressed),
              ),
              Positioned.fromRect(
                rect: vf,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LiveCameraPreview(
                        controller: widget.controller,
                        placeholder: const ColoredBox(color: Color(0xFF0A0A0A)),
                      ),
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                              stops: [0.0, 0.45],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            ],
          ),
        );
      },
    );
  }
}
