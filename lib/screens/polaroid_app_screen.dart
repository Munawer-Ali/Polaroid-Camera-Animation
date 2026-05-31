import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../painters/polaroid_body_painter.dart';
import '../services/camera_service.dart';
import '../theme/polaroid_palette.dart';
import '../widgets/photo_gallery_strip.dart';
import '../widgets/polaroid_print.dart';
import '../widgets/skeuomorphic_polaroid.dart';

const _linearOutSlowIn = Cubic(0.0, 0.0, 0.2, 1.0);

class PolaroidAppScreen extends StatefulWidget {
  const PolaroidAppScreen({super.key});

  @override
  State<PolaroidAppScreen> createState() => _PolaroidAppScreenState();
}

class _PolaroidAppScreenState extends State<PolaroidAppScreen>
    with TickerProviderStateMixin {
  final CameraService _camera = CameraService();
  final math.Random _random = math.Random();

  PhotoState _state = PhotoState.idle;
  ui.Image? _capturedImage;

  final List<ui.Image> _gallery = [];

  late final AnimationController _flash;
  late final AnimationController _ejectY;
  late final AnimationController _rotation;
  late final AnimationController _develop;
  late final AnimationController _stow;

  bool get _showPrint =>
      _state != PhotoState.idle && _state != PhotoState.capturing;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController.unbounded(vsync: this);
    _ejectY = AnimationController.unbounded(vsync: this, value: -800);
    _rotation = AnimationController.unbounded(vsync: this);
    _develop = AnimationController.unbounded(vsync: this);
    _stow = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    _camera.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _flash.dispose();
    _ejectY.dispose();
    _rotation.dispose();
    _develop.dispose();
    _stow.dispose();
    _camera.dispose();
    final disposed = <ui.Image>{};
    for (final img in _gallery) {
      if (disposed.add(img)) img.dispose();
    }
    final cap = _capturedImage;
    if (cap != null && disposed.add(cap)) cap.dispose();
    super.dispose();
  }

  Future<void> _onShutter() async {
    if (_state != PhotoState.idle && _state != PhotoState.done) return;

    if (_state == PhotoState.done) {
      _ejectY.animateTo(2500,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn);
    }

    setState(() => _state = PhotoState.capturing);

    // quick flash burst then decay
    _flash.value = 0;
    _flash
        .animateTo(1,
            duration: const Duration(milliseconds: 40),
            curve: Curves.easeOutQuad)
        .then((_) {
      if (mounted) {
        _flash.animateTo(0,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutExpo);
      }
    });

    ui.Image? image;
    try {
      image = await _camera.capture();
    } catch (_) {
      image = null;
    }
    if (!mounted) return;
    if (image == null) {
      setState(() => _state = PhotoState.idle);
      return;
    }

    _develop.value = 0;
    setState(() {
      _capturedImage = image;
      _state = PhotoState.ejecting;
    });
    await _ejectAndDevelop();
  }

  Future<void> _ejectAndDevelop() async {
    _ejectY.value = -800;
    _develop.value = 0;

    final tilt = (_random.nextInt(7) - 3).toDouble();
    _rotation.animateTo(tilt, duration: const Duration(milliseconds: 1200));

    await _ejectY.animateTo(40,
        duration: const Duration(milliseconds: 1200), curve: _linearOutSlowIn);
    if (!mounted) return;
    setState(() => _state = PhotoState.developing);

     _develop.animateTo(1,
        duration: const Duration(milliseconds: 4200),
        curve: Curves.easeInOutCubic);
    if (!mounted) return;
    setState(() => _state = PhotoState.done);
  }

  void _dismissPrint() {
    if (_state != PhotoState.done && _state != PhotoState.developing) return;
    setState(() => _state = PhotoState.idle);
    _ejectY.animateTo(2500,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  Future<void> _stowToGallery() async {
    if (_state != PhotoState.done) return;
    final img = _capturedImage;
    if (img == null) return;

    // drop the print down into the tray, then add it to the gallery
    setState(() => _gallery.insert(0, img));
    await _stow.forward(from: 0);
    if (!mounted) return;
    setState(() => _state = PhotoState.idle);
    _stow.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PolaroidPalette.appBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screen = constraints.biggest;

          // camera body on top, preview fills the rest
          final topAreaH = screen.height * 13 / 23;

          const padL = 4.0, padR = 4.0, padT = 16.0, padB = 8.0;
          final innerW = screen.width - padL - padR;
          final innerH = topAreaH - padT - padB;
          double boxW, boxH;
          if (innerW / 1.15 <= innerH) {
            boxW = innerW;
            boxH = innerW / 1.15;
          } else {
            boxH = innerH;
            boxW = innerH * 1.15;
          }
          final boxTop = (padT + (innerH - boxH) / 2) + 5;
          final slotY =
              boxTop + PolaroidBodyPainter.filmSlotTopY(Size(boxW, boxH));

          return Stack(
            children: [

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topAreaH,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: padT, left: padL, right: padR, bottom: padB),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: SkeuomorphicPolaroid(
                        onShutterClick: _onShutter,
                        controller: _camera.controller,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PhotoGalleryStrip(images: _gallery),
              ),

              if (_showPrint)
                Positioned(
                  top: slotY,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_ejectY, _develop, _stow]),
                        builder: (context, _) {
                          return PolaroidPrint(
                            image: _capturedImage,
                            offsetY: _ejectY.value,
                            rotationDegrees: 0.0,
                            develop: _develop.value,
                            stow: _stow.value,
                            onTap: _stowToGallery,
                            onDoubleTap: _stowToGallery,
                          );
                        },
                      ),
                    ),
                  ),
                ),

              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _flash,
                    builder: (context, _) => Opacity(
                      opacity: _flash.value.clamp(0.0, 1.0),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.0,
                            colors: [Colors.white, Color(0xFFEAF0FF)],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
