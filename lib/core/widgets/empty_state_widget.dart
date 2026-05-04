import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// ── Illustration variant enum ─────────────────────────────────────────────────

enum EmptyIllustration { transactions, reports, categories }

// ── Reusable empty-state widget ───────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.illustration,
    required this.title,
    required this.subtitle,
    super.key,
    this.buttonLabel,
    this.onButtonPressed,
  });

  final EmptyIllustration illustration;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _EmptyIllustrationPainter(illustration),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── CustomPainter — draws all three illustration variants ─────────────────────

class _EmptyIllustrationPainter extends CustomPainter {
  const _EmptyIllustrationPainter(this.type);

  final EmptyIllustration type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EmptyIllustration.transactions:
        _drawWallet(canvas, size);
      case EmptyIllustration.reports:
        _drawBarChart(canvas, size);
      case EmptyIllustration.categories:
        _drawGrid(canvas, size);
    }
  }

  // ── Wallet with dotted border and "+" hint ──────────────────────────────

  void _drawWallet(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    // Background circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.46, bgPaint);

    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Wallet body
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy + 6),
          width: size.width * 0.58,
          height: size.height * 0.38),
      const Radius.circular(12),
    );
    canvas.drawRRect(walletRect, bodyPaint);
    _drawDashedRRect(canvas, walletRect, strokePaint);

    // Wallet flap
    final flapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - size.width * 0.29, cy - size.height * 0.22,
          size.width * 0.58, size.height * 0.2),
      const Radius.circular(10),
    );
    canvas.drawRRect(flapRect, bodyPaint);
    _drawDashedRRect(canvas, flapRect, strokePaint);

    // Coin circle
    final coinPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + size.width * 0.18, cy + 6),
        size.width * 0.1, coinPaint);

    // "+" hint
    final plusPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const ph = 8.0;
    const pw = 8.0;
    canvas
      ..drawLine(Offset(cx - pw, cy + 6), Offset(cx + pw, cy + 6), plusPaint)
      ..drawLine(Offset(cx, cy + 6 - ph), Offset(cx, cy + 6 + ph), plusPaint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rRect, Paint paint) {
    final path = Path()..addRRect(rRect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + 6).clamp(0, metric.length).toDouble();
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += 10;
      }
    }
  }

  // ── Bar chart with question marks ──────────────────────────────────────

  void _drawBarChart(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.46, bgPaint);

    final barHeights = [0.25, 0.45, 0.35, 0.55, 0.30];
    final barWidth = size.width * 0.08;
    final spacing = size.width * 0.07;
    final baseY = cy + size.height * 0.2;
    final maxBarH = size.height * 0.38;

    final totalW =
        barHeights.length * barWidth + (barHeights.length - 1) * spacing;
    var startX = cx - totalW / 2;

    for (var i = 0; i < barHeights.length; i++) {
      final barH = maxBarH * barHeights[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, baseY - barH, barWidth, barH),
        const Radius.circular(4),
      );
      final color = i == 1 || i == 3
          ? AppColors.primary.withValues(alpha: 0.25)
          : AppColors.primary.withValues(alpha: 0.12);
      canvas.drawRRect(rect, Paint()..color = color);
      startX += barWidth + spacing;
    }

    // Baseline
    canvas.drawLine(
      Offset(cx - totalW / 2 - 4, baseY),
      Offset(cx + totalW / 2 + 4, baseY),
      Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1.5,
    );

    // Question mark using TextPainter
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(cx - tp.width / 2, cy - size.height * 0.26 - tp.height / 2));
  }

  // ── Empty grid of rounded squares ──────────────────────────────────────

  void _drawGrid(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.46, bgPaint);

    const cols = 3;
    const rows = 3;
    final cellSize = size.width * 0.17;
    final gap = size.width * 0.05;
    final totalW = cols * cellSize + (cols - 1) * gap;
    final totalH = rows * cellSize + (rows - 1) * gap;
    final startX = cx - totalW / 2;
    final startY = cy - totalH / 2;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final left = startX + c * (cellSize + gap);
        final top = startY + r * (cellSize + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellSize, cellSize),
          const Radius.circular(6),
        );
        final isCenter = r == 1 && c == 1;
        canvas
          ..drawRRect(
            rect,
            Paint()
              ..color = isCenter
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.09)
              ..style = PaintingStyle.fill,
          )
          ..drawRRect(
            rect,
            Paint()
              ..color = AppColors.primary.withValues(alpha: 0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
      }
    }
  }

  @override
  bool shouldRepaint(_EmptyIllustrationPainter old) => old.type != type;
}
