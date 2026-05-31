import 'package:flutter/material.dart';

class PolaroidPalette {
  PolaroidPalette._();

  static const appBackground = Color(0xFF6B705C);
  static const bodyCream = Color(0xFFEBE9DE);
  static const bodyCreamShadow = Color(0xFFBCBAAB);
  static const bodyCreamLip = Color(0xFFE5E3D5);
  static const chassisLight = Color(0xFF2E2E2E);
  static const chassisDark = Color(0xFF141414);
  static const panelRecess = Color(0xFF1F1F1F);
  static const textColor = Color(0xFFAFAFAF);
  static const stickerBeige = Color(0xFFEBE6C8);
  static const shutterRed = Color(0xFFDF1A00);
  static const shutterRedHighlight = Color(0xFFFF4D33);

  static const rainbowColors = <Color>[
    Color(0xFFB30033),
    Color(0xFFE65C00),
    Color(0xFFFFC000),
    Color(0xFF00A633),
    Color(0xFF0073B3),
  ];
}

enum PhotoState { idle, capturing, ejecting, developing, done }
