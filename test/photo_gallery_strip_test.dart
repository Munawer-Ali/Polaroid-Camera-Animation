import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polaroid_camera/widgets/photo_gallery_strip.dart';

Future<ui.Image> _makeImage(WidgetTester tester) async {
  late ui.Image image;
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 8, 8),
      Paint()..color = const Color(0xFF2196F3),
    );
    image = await recorder.endRecording().toImage(8, 8);
  });
  return image;
}

void main() {
  testWidgets('empty gallery renders nothing visible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PhotoGalleryStrip(images: []))),
    );

    expect(find.byType(RawImage), findsNothing);
    expect(find.textContaining('photo'), findsNothing);
  });

  testWidgets('populated gallery shows a count and a thumbnail',
      (tester) async {
    final image = await _makeImage(tester);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PhotoGalleryStrip(images: [image]))),
    );

    expect(find.text('1 photo'), findsOneWidget);
    expect(find.byType(RawImage), findsOneWidget);
  });

  testWidgets('count label pluralises', (tester) async {
    final a = await _makeImage(tester);
    final b = await _makeImage(tester);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PhotoGalleryStrip(images: [a, b]))),
    );

    expect(find.text('2 photos'), findsOneWidget);
  });
}
