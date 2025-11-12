import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsStep extends ConsumerWidget {
  const SettingsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(createControllerProvider);              // 狀態
    final c = ref.read(createControllerProvider.notifier);      // 方法

    Future<void> pickSchedule() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: s.scheduledAt ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 2),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(s.scheduledAt ?? now),
      );
      if (time == null) return;
      c.setScheduledAt(DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }

    Future<void> addCollaborator() async {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('新增合作創作者'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '輸入名稱或 Email'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('新增')),
          ],
        ),
      );
      if (ok == true && controller.text.trim().isNotEmpty) {
        c.addCollaborator(controller.text.trim());
      }
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('上傳設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),

            // 金額 (Podcoin)
            const _SectionTitle('金額 (Podcoin)'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: s.pricePodcoin,
              onChanged: (v) => c.setPrice(v ?? 0),
              items: const [
                DropdownMenuItem(value: 0, child: Text('免費')),
                DropdownMenuItem(value: 10, child: Text('10 Podcoin')),
                DropdownMenuItem(value: 20, child: Text('20 Podcoin')),
                DropdownMenuItem(value: 50, child: Text('50 Podcoin')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 28),
            const _SectionTitle('發布時間'),
            const SizedBox(height: 12),
            Row(
              children: [
                _ModeButton(
                  label: '即時',
                  selected: s.publishMode == PublishMode.now,
                  onTap: () => c.setPublishMode(PublishMode.now),
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _ModeButton(
                  label: '排程',
                  selected: s.publishMode == PublishMode.schedule,
                  onTap: () async {
                    c.setPublishMode(PublishMode.schedule);
                    await pickSchedule();
                  },
                  theme: theme,
                ),
                const Spacer(),
                if (s.publishMode == PublishMode.schedule)
                  TextButton.icon(
                    onPressed: pickSchedule,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(s.scheduledAt == null ? '選擇時間' : _fmtDateTime(s.scheduledAt!)),
                  ),
              ],
            ),

            const SizedBox(height: 28),
            Row(
              children: [
                const _SectionTitle('合作創作者'),
                const SizedBox(width: 8),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: addCollaborator,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('此創作者也可回覆聽眾留言',
                style: TextStyle(color: Colors.black54.withOpacity(.5))),
            const SizedBox(height: 12),

            if (s.collaborators.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text('尚未新增合作創作者', style: TextStyle(color: Colors.black54)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in s.collaborators)
                    InputChip(
                      label: Text(name),
                      onDeleted: () => c.removeCollaborator(name),
                    ),
                ],
              ),

            const SizedBox(height: 24),
            const Divider(height: 32),
            // Row(
            //   children: [
            //     OutlinedButton(
            //       onPressed: s.canPrev ? c.prevStep : null,
            //       child: const Text('上一步'),
            //     ),
            //     const Spacer(),
            //     FilledButton(
            //       onPressed: c.nextStep,
            //       child: const Text('下一步'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.color.brand;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(
          label, // ✅ 改這裡
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


String _fmtDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}
