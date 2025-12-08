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
    final state = ref.watch(createControllerProvider); // 狀態
    final ctrl = ref.read(createControllerProvider.notifier); // 方法

    Future<void> pickSchedule() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: state.scheduledAt ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 2),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(state.scheduledAt ?? now),
      );
      if (time == null) return;
      ctrl.setScheduledAt(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    }

    Future<void> addCollaborator() async {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) {
            final allUsers = ["111","221","222","223","224","225","226","227","228","229","230","231","333","444","555"];
           
            final filtered = allUsers
                .where(
                  (name) =>
                      controller.text.isNotEmpty &&
                      name.contains(controller.text),
                )
                .toList();
            final _scrollController = ScrollController();
            return AlertDialog(
              title: const Text('新增合作創作者'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: '輸入合作創作者名稱'),
                      autofocus: true,
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 12),
                    Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true, 
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final name = filtered[index];
                              return ListTile(
                                title: Text(name),
                                leading: const Icon(Icons.person_outline),
                                onTap: () {
                                  controller.text = name;
                                  setState(() {}); // 更新 TextField 顯示
                                  Navigator.pop(context, true);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                // FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('新增')),
              ],
            );
          },
        ),
      );
      if (ok == true && controller.text.trim().isNotEmpty) {
        ctrl.addCollaborator(controller.text.trim());
      }
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '上傳設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // 金額 (Podcoin)
            const _SectionTitle('金額 (Podcoin)'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: state.pricePodcoin,
              onChanged: (v) => ctrl.setPrice(v ?? 0),
              items: const [
                DropdownMenuItem(value: 0, child: Text('免費')),
                DropdownMenuItem(value: 10, child: Text('10 Podcoin')),
                DropdownMenuItem(value: 20, child: Text('20 Podcoin')),
                DropdownMenuItem(value: 30, child: Text('30 Podcoin')),
                DropdownMenuItem(value: 50, child: Text('50 Podcoin')),
                DropdownMenuItem(value: 100, child: Text('100 Podcoin')),
                DropdownMenuItem(value: 150, child: Text('150 Podcoin')),
                DropdownMenuItem(value: 200, child: Text('200 Podcoin')),
                DropdownMenuItem(value: 500, child: Text('500 Podcoin')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 28),
            const _SectionTitle('發布時間'),
            const SizedBox(height: 12),
            Row(
              children: [
                _ModeButton(
                  label: '即時',
                  selected: state.publishMode == PublishMode.now,
                  onTap: () => ctrl.setPublishMode(PublishMode.now),
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _ModeButton(
                  label: '排程',
                  selected: state.publishMode == PublishMode.schedule,
                  onTap: () async {
                    ctrl.setPublishMode(PublishMode.schedule);
                    await pickSchedule();
                  },
                  theme: theme,
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

            const SizedBox(height: 28),
            Row(
              children: [
                const _SectionTitle('合作創作者'),
                const SizedBox(width: 8),
                Visibility(
                  visible: state.collaborators.isEmpty == true,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: addCollaborator,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              '此創作者也可回覆聽眾留言',
              style: TextStyle(color: Colors.black54.withOpacity(.5)),
            ),
            const SizedBox(height: 12),

            if (state.collaborators.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  '尚未新增合作創作者',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in state.collaborators)
                    InputChip(
                      label: Text(name),
                      onDeleted: () => ctrl.removeCollaborator(name),
                    ),
                ],
              ),

            const SizedBox(height: 24),
            const Divider(height: 32),
            // Row(
            //   children: [
            //     OutlinedButton(
            //       onPressed: state.canPrev ? ctrl.prevStep : null,
            //       child: const Text('上一步'),
            //     ),
            //     const Spacer(),
            //     FilledButton(
            //       onPressed: ctrl.nextStep,
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
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
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
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}
