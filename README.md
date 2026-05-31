# polaroid_camera

A skeuomorphic Polaroid OneStep camera built in Flutter. The entire camera body
is hand-painted on a `Canvas`, a live front-camera feed shows inside the
viewfinder window, and tapping the shutter captures a photo that ejects from the
film slot, develops, and can be flicked down into a gallery tray at the bottom.

Originally ported from a Jetpack Compose implementation.

## Features

- **Fully painted camera body** — the OneStep silhouette, rainbow stripe, lens
  with concentric barrel ribs and glass reflections, flash, red shutter button,
  exposure dial, "Supercolor 1000" sticker, speaker grille and film slot are all
  drawn in a single `CustomPainter` (no images/assets).
- **Live viewfinder** — the front camera renders inside a recessed bezel on the
  top-right of the body so you see what you're shooting.
- **Press-to-shoot shutter** — the red button hit-tests precisely and depresses
  on touch.
- **Camera flash** — a quick white burst with an exponential decay on capture.
- **Eject from the slot** — the print feeds out of the painted film slot and
  slides down over the camera's lower face into the preview area.
- **Develop phase** — a timed develop step before the photo is "done".
- **Sharpie drawing** — draw on the developed print by dragging on it.
- **Gallery tray** — tap a finished print to drop it (with a shrink-and-fall
  animation) into a horizontal strip of mini polaroids at the bottom.

## Project structure

```
lib/
├── main.dart                         App entry point + MaterialApp
├── theme/
│   └── polaroid_palette.dart         Colour tokens + PhotoState enum
├── painters/
│   └── polaroid_body_painter.dart    The hand-painted camera body + geometry helpers
├── widgets/
│   ├── skeuomorphic_polaroid.dart    Camera body + viewfinder + shutter hit testing
│   ├── live_camera_preview.dart      Cover-fit camera feed with a placeholder fallback
│   ├── polaroid_print.dart           Ejected print: eject/stow transforms + sharpie canvas
│   └── photo_gallery_strip.dart      Bottom tray of saved photos
├── services/
│   └── camera_service.dart           Front-camera init, capture, selfie mirroring
└── screens/
    └── polaroid_app_screen.dart      Layout + PhotoState machine + all animations
```

## How it works

### State machine

A capture moves through `PhotoState`:

```
idle → capturing → ejecting → developing → done → (idle)
```

- **idle** — live preview only.
- **capturing** — flash fires, camera takes the picture (print hidden).
- **ejecting** — the print slides out of the slot.
- **developing** — the develop animation runs.
- **done** — the print is interactive; tap to stow it into the gallery.

### Animations

All driven by `AnimationController`s in `PolaroidAppScreen`:

| Controller | Drives |
|------------|--------|
| `_flash`   | White flash overlay opacity (burst then exponential decay) |
| `_ejectY`  | Vertical slide of the print out of the slot |
| `_rotation`| Random ±3° tilt of the ejected print |
| `_develop` | Timing of the develop phase |
| `_stow`    | Shrink-and-fall of the print into the gallery tray |

The body painter exposes pure geometry helpers so the widget layer can line up
overlays with the painted body: `shutterHitArea`, `viewfinderRect`,
`viewfinderInnerRect`, and `filmSlotTopY`.

### Controls

- **Tap the red shutter** — take a photo.
- **Drag on a developed print** — draw with the sharpie.
- **Tap / double-tap a finished print** — stow it into the gallery tray.

## Getting started

```bash
flutter pub get
flutter run
```

Uses the [`camera`](https://pub.dev/packages/camera) plugin, so a physical
device (or a simulator with a camera) is needed for the live feed. Without a
camera the viewfinder falls back to a placeholder and the rest of the UI still
works.

### Permissions

Already configured in the project:

- **Android** — `CAMERA` permission and `minSdk 21` (`android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`).
- **iOS** — `NSCameraUsageDescription` (`ios/Runner/Info.plist`).

## Testing

```bash
flutter test
```

Tests live in `test/`:

- `widget_test.dart` — the app builds and shows the camera body + viewfinder.
- `polaroid_body_painter_test.dart` — geometry helpers stay within the body bounds.
- `photo_gallery_strip_test.dart` — the tray hides when empty and shows thumbnails when populated.
