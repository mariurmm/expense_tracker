// ─────────────────────────────────────────────────────────────────────────────
// tools/generate_icon.dart
//
// Generates assets/images/icon.png, icon_foreground.png, and logo.png
// programmatically using dart:ui so no external image editor is needed.
//
// Usage (run once from the project root via the Flutter tool):
//   flutter run -d flutter-tester --no-sound-null-safety tools/generate_icon.dart
//
// Or use flutter pub run approach — see README.
//
// After generating the images, produce launcher icons and the splash screen:
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<void> main() async {
  await _generateIcon();
  await _generateForeground();
  await _generateLogo();
  print('✓ All assets written to assets/images/');
}

// ── Full icon (192×192): deep-blue rounded square + white ₸ ─────────────────

Future<void> _generateIcon() async {
  const double size = 192;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Background
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(0, 0, size, size),
      const ui.Radius.circular(40),
    ),
    ui.Paint()..color = const ui.Color(0xFF1A237E),
  );

  // ₸ symbol
  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      fontSize: 110,
    ),
  )
    ..pushStyle(ui.TextStyle(
      color: const ui.Color(0xFFFFFFFF),
      fontWeight: ui.FontWeight.bold,
    ))
    ..addText('₸');

  final para = pb.build()
    ..layout(const ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(para, ui.Offset(0, (size - para.height) / 2));

  await _savePicture(recorder, size, 'assets/images/icon.png');
  print('  icon.png');
}

// ── Foreground only (transparent bg, white ₸ — for adaptive icon) ───────────

Future<void> _generateForeground() async {
  const double size = 192;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      fontSize: 110,
    ),
  )
    ..pushStyle(ui.TextStyle(
      color: const ui.Color(0xFFFFFFFF),
      fontWeight: ui.FontWeight.bold,
    ))
    ..addText('₸');

  final para = pb.build()
    ..layout(const ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(para, ui.Offset(0, (size - para.height) / 2));

  await _savePicture(recorder, size, 'assets/images/icon_foreground.png');
  print('  icon_foreground.png');
}

// ── Splash logo (white wallet outline on transparent background) ─────────────

Future<void> _generateLogo() async {
  const double size = 192;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  const cx = size / 2;
  const cy = size / 2;

  final strokePaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round;

  final fillPaint = ui.Paint()
    ..color = const ui.Color(0x33FFFFFF)
    ..style = ui.PaintingStyle.fill;

  // Wallet body
  final bodyRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromCenter(
        center: const ui.Offset(cx, cy + 10), width: 110, height: 70),
    const ui.Radius.circular(14),
  );
  canvas.drawRRect(bodyRect, fillPaint);
  canvas.drawRRect(bodyRect, strokePaint);

  // Wallet flap
  final flapRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(cx - 55, cy - 30, 110, 36),
    const ui.Radius.circular(10),
  );
  canvas.drawRRect(flapRect, fillPaint);
  canvas.drawRRect(flapRect, strokePaint);

  // Coin circle
  canvas.drawCircle(const ui.Offset(cx + 34, cy + 10), 16, fillPaint);
  canvas.drawCircle(const ui.Offset(cx + 34, cy + 10), 16, strokePaint);

  await _savePicture(recorder, size, 'assets/images/logo.png');
  print('  logo.png');
}

// ── Helper ────────────────────────────────────────────────────────────────────

Future<void> _savePicture(
    ui.PictureRecorder recorder, double size, String path) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await _writeBytes(path, bytes!);
}

Future<void> _writeBytes(String path, ByteData bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List());
}
