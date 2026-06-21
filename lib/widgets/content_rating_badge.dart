import 'package:flutter/material.dart';

class ContentRatingBadge extends StatelessWidget {
  final String contentRating;
  final bool compact;
  final bool overlay;

  const ContentRatingBadge({
    super.key,
    required this.contentRating,
    this.compact = false,
    this.overlay = false,
  });

  bool get isAdult => contentRating.toLowerCase() == "adult";

  @override
  Widget build(BuildContext context) {
    if (!isAdult) {
      return const SizedBox.shrink();
    }

    final backgroundColor =
      overlay ? Colors.black.withOpacity(0.72) : Colors.redAccent;
    const foregroundColor = Colors.white;
    final double horizontalPadding = (compact ? 6.0 : 8.0)
      .clamp(compact ? 6.0 : 8.0, compact ? 8.0 : 10.0)
      .toDouble();
    final double verticalPadding = (compact ? 2.0 : 4.0)
      .clamp(compact ? 2.0 : 4.0, compact ? 3.0 : 5.0)
      .toDouble();
    final double borderRadius = 12.0.clamp(12.0, 14.0).toDouble();
    final double fontSize = 11.0.clamp(11.0, compact ? 12.0 : 13.0).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "18+",
            style: TextStyle(
              color: foregroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
