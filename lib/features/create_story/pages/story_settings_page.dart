import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:actpod_studio/widgets/avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

class SettingsStep extends ConsumerWidget {
  const SettingsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(createControllerProvider); // 狀態
    final ctrl = ref.read(createControllerProvider.notifier); // 方法

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
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        interval: 30,
        visibleStep: VisibleStep.thirtieths,
      );
      if (time!.minute % 30 != 0) {
        final adjustedMinute = (time.minute ~/ 30) * 30;
        timeMinute = adjustedMinute;
      } else {
        timeMinute = time.minute;
      }

      if (time == null) return;
      ctrl.setScheduledAt(
        DateTime(date.year, date.month, date.day, time!.hour, timeMinute),
      );
    }

    Future<void> addCollaborator() async {
       print(state.collaborator);
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final _scrollController = ScrollController();

            final state = ref.watch(createControllerProvider); // 狀態
            final ctrl = ref.read(createControllerProvider.notifier); // 方法

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
                        ctrl.searchUserList(controller.text);
                        // print(state.searchUserList);
                      },
                    ),
                    SizedBox(height: 12),

                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.searchUserList.length,
                          itemBuilder: (context, index) {
                            final name = state.searchUserList[index].name;
                            return ListTile(
                              title: Text(name),
                              leading: Avatar(
                                url: state.searchUserList[index].avatarUrl,
                              ),
                              onTap: () {
                                controller.text = name;
                                ctrl.addCollaborator(
                                  state.searchUserList[index],
                                );
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

            // // 金額 (Podcoin)
            // const _SectionTitle('金額 (Podcoin)'),
            // const SizedBox(height: 8),
            // DropdownButtonFormField<int>(
            //   value: state.pricePodcoin,
            //   onChanged: (v) => ctrl.setPrice(v ?? 0),
            //   items: const [
            //     DropdownMenuItem(value: 0, child: Text('免費')),
            //     DropdownMenuItem(value: 10, child: Text('10 Podcoin')),
            //     DropdownMenuItem(value: 20, child: Text('20 Podcoin')),
            //     DropdownMenuItem(value: 30, child: Text('30 Podcoin')),
            //     DropdownMenuItem(value: 50, child: Text('50 Podcoin')),
            //     DropdownMenuItem(value: 100, child: Text('100 Podcoin')),
            //     DropdownMenuItem(value: 150, child: Text('150 Podcoin')),
            //     DropdownMenuItem(value: 200, child: Text('200 Podcoin')),
            //     DropdownMenuItem(value: 500, child: Text('500 Podcoin')),
            //   ],
            //   decoration: InputDecoration(
            //     contentPadding: const EdgeInsets.symmetric(
            //       horizontal: 14,
            //       vertical: 12,
            //     ),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 28),
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
                  visible: state.collaborator == null || state.collaborator?.userId == "",
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

            if (state.collaborator == null || state.collaborator!.userId == "")
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
                  InputChip(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    avatar: Avatar(
                      url: state.collaborator?.avatarUrl ?? "",
                      radius: 40,
                    ),
                    label: Text(state.collaborator?.name ?? ""),
                    onDeleted: () {
                      ctrl.removeCollaborator();
                      print(state.collaborator);
                    },
                  ),
                ],
              ),

            const SizedBox(height: 24),
            const Divider(height: 32),
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
