import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polaroid_camera/screens/polaroid_app_screen.dart';
import 'package:polaroid_camera/widgets/live_camera_preview.dart';
import 'package:polaroid_camera/widgets/photo_gallery_strip.dart';
import 'package:polaroid_camera/widgets/polaroid_print.dart';
import 'package:polaroid_camera/widgets/skeuomorphic_polaroid.dart';

void main() {
  testWidgets('app builds with the camera body and viewfinder',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PolaroidAppScreen()));
    await tester.pump();

    // Camera body and its viewfinder feed are on screen.
    expect(find.byType(SkeuomorphicPolaroid), findsOneWidget);
    expect(find.byType(LiveCameraPreview), findsOneWidget);

    // Nothing captured yet.
    expect(find.byType(PolaroidPrint), findsNothing);
  });

  testWidgets('gallery tray starts empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PolaroidAppScreen()));
    await tester.pump();

    expect(find.byType(PhotoGalleryStrip), findsOneWidget);
    // Empty tray renders nothing, so no "photo(s)" count label.
    expect(find.textContaining('photo'), findsNothing);
  });
}
