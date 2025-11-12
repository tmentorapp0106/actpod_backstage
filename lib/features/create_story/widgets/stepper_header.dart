import 'package:flutter/material.dart';

class StepperHeader extends StatelessWidget {
  final int active; // 0-based
  final List<String> titles;
  const StepperHeader({super.key, required this.active, required this.titles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (int i = 0; i < titles.length; i++) ...[
          _DotLabel(
            label: titles[i],
            active: i == active,
            done: i < active,
          ),
          if (i < titles.length - 1)
            Expanded(child: Divider(thickness: 2, indent: 8, endIndent: 8)),
        ],
      ],
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String label;
  final bool active, done;
  const _DotLabel({required this.label, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFFBC1F) : Colors.grey[400];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 10, backgroundColor: done ? Colors.green : color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: active ? Color(0xFFFFBC1F) : Colors.grey[600])),
      ],
    );
  }
}
