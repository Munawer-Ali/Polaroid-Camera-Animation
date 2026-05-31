import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/polaroid_app_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  runApp(const PolaroidApp());
}

class PolaroidApp extends StatelessWidget {
  const PolaroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Polaroid Camera',
      debugShowCheckedModeBanner: false,
      home: PolaroidAppScreen(),
    );
  }
}
