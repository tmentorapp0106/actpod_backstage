import 'dart:math' as math;

import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:flutter/material.dart';

class StatBarChart extends StatelessWidget {
  final List<StoryStatistic> stories;

  const StatBarChart({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final items = stories.take(8).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '節目播放排行',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: items.isEmpty
                ? const Center(child: Text('尚無統計資料'))
                : CustomPaint(
                    painter: _BarChartPainter(items),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<StoryStatistic> items;

  _BarChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFBC1F), Color(0xFF22C55E)],
      ).createShader(Offset.zero & size);
    final interactionPaint = Paint()..color = const Color(0xFF2563EB);
    final labelStyle = const TextStyle(color: Color(0xFF6B7280), fontSize: 11);
    final valueStyle = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    const left = 42.0;
    const bottom = 30.0;
    const top = 10.0;
    final chartWidth = size.width - left - 8;
    final chartHeight = size.height - top - bottom;
    final maxListen = math.max(
      1,
      items.map((item) => item.listenCount).fold(0, math.max),
    );
    final groupWidth = chartWidth / items.length;
    final barWidth = math.min(34.0, groupWidth * .42);

    for (var i = 0; i <= 4; i++) {
      final y = top + chartHeight * i / 4;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), axisPaint);
    }

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final x = left + groupWidth * i + (groupWidth - barWidth) / 2;
      final listenHeight = chartHeight * item.listenCount / maxListen;
      final interactionHeight =
          chartHeight * math.min(item.totalInteractions, maxListen) / maxListen;
      final baseY = top + chartHeight;

      final listenRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baseY - listenHeight, barWidth, listenHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(listenRect, barPaint);

      if (interactionHeight > 0) {
        final interactionRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + barWidth * .62,
            baseY - interactionHeight,
            barWidth * .38,
            interactionHeight,
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(interactionRect, interactionPaint);
      }

      _drawText(
        canvas,
        item.listenCount.toString(),
        Offset(x + barWidth / 2, baseY - listenHeight - 16),
        valueStyle,
        alignCenter: true,
      );
      _drawText(
        canvas,
        (i + 1).toString(),
        Offset(x + barWidth / 2, baseY + 8),
        labelStyle,
        alignCenter: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    bool alignCenter = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final dx = alignCenter ? offset.dx - painter.width / 2 : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
