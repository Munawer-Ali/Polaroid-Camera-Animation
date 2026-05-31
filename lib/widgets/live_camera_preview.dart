import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LiveCameraPreview extends StatelessWidget {
  const LiveCameraPreview({
    super.key,
    required this.controller,
    this.placeholder,
  });

  final CameraController? controller;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null || !c.value.isInitialized) {
      return placeholder ??
          const ColoredBox(
            color: Color(0xFF222222),
            child: Center(
              child:
                  Text('Camera Preview', style: TextStyle(color: Colors.grey)),
            ),
          );
    }

    final preview = c.value.previewSize ?? const Size(1, 1);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: preview.height,
          height: preview.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }
}
