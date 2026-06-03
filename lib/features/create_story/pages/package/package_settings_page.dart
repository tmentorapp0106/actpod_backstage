import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';

class PackageSettingsStep extends ConsumerWidget {
  const PackageSettingsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);

    Future<void> pickSchedule() async {
      final now = DateTime.now();
      var timeMinute = now.minute;

      final date = await showDatePicker(
        context: context,
        initialDate: state.scheduledAt ?? now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 90)),
      );
      if (date == null) return;

      final time = await showIntervalTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        interval: 30,
        visibleStep: VisibleStep.thirtieths,
      );
      if (time == null) return;

      if (time.minute % 30 != 0) {
        timeMinute = (time.minute ~/ 30) * 30;
      } else {
        timeMinute = time.minute;
      }

      ctrl.setScheduledAt(
        DateTime(date.year, date.month, date.day, time.hour, timeMinute),
      );
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '套裝發布設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            const Text(
              '發布時間',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ModeButton(
                  label: '即時',
                  selected: state.publishMode == PublishMode.now,
                  onTap: () => ctrl.setPublishMode(PublishMode.now),
                ),
                const SizedBox(width: 12),
                _ModeButton(
                  label: '排程',
                  selected: state.publishMode == PublishMode.schedule,
                  onTap: () async {
                    ctrl.setPublishMode(PublishMode.schedule);
                    await pickSchedule();
                  },
                ),
                const Spacer(),
                if (state.publishMode == PublishMode.schedule)
                  TextButton.icon(
                    onPressed: pickSchedule,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      state.scheduledAt == null
                          ? '選擇時間'
                          : _fmtDateTime(state.scheduledAt!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.color.brand;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}
