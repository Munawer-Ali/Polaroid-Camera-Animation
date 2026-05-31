import 'dart:ui' as ui;

import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  bool _isFront = false;

  bool get isInitialized => controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _isFront = front.lensDirection == CameraLensDirection.front;

      final c = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      controller = c;
    } catch (_) {
      controller = null;
    }
  }

  Future<ui.Image?> capture() async {
    final c = controller;
    if (c == null || !c.value.isInitialized) return null;
    c.setFlashMode(FlashMode.off);
    final file = await c.takePicture();
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // selfies come out reversed, flip them back
    if (!_isFront) return image;
    return _mirrorHorizontally(image);
  }

  Future<ui.Image> _mirrorHorizontally(ui.Image src) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.translate(src.width.toDouble(), 0);
    canvas.scale(-1, 1);
    canvas.drawImage(src, ui.Offset.zero, ui.Paint());
    final picture = recorder.endRecording();
    final mirrored = await picture.toImage(src.width, src.height);
    src.dispose();
    return mirrored;
  }

  void dispose() {
    controller?.dispose();
    controller = null;
  }
}
