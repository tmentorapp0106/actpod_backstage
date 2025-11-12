import 'package:flutter/material.dart';

class StepNavBar extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool showPrev;
  final bool busy;
  final bool isLast;
  final String? nextLabel;
final bool disableNext;  // 預設 false


  const StepNavBar({
    super.key,
    this.onPrev,
    this.onNext,
    this.showPrev = true,
    this.busy = false,
    this.isLast = false,
    this.nextLabel,
    this.disableNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showPrev)
          OutlinedButton.icon(
            onPressed: busy ? null : onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('上一步'),
          ),
        Spacer(),
        FilledButton.icon(
          onPressed: busy ? null : onNext,
          icon: busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(isLast ? Icons.cloud_upload_rounded : Icons.chevron_right_rounded),
          label: Text(nextLabel ?? (isLast ? '發布' : '下一步')),
        ),
      ],
    );
  }
}