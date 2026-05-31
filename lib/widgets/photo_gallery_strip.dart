import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PhotoGalleryStrip extends StatelessWidget {
  const PhotoGalleryStrip({super.key, required this.images, this.onTapImage});

  final List<ui.Image> images;
  final ValueChanged<int>? onTapImage;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xCC000000)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 15, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '${images.length} ${images.length == 1 ? 'photo' : 'photos'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _Thumb(
                image: images[i],
                index: i,
                onTap: onTapImage == null ? null : () => onTapImage!(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.index, this.onTap});

  final ui.Image image;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tilt = (index.isEven ? 1.5 : -1.5) * math.pi / 180;
    return Transform.rotate(
      angle: tilt,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 70,
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F1),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox.expand(
              child: RawImage(image: image, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
