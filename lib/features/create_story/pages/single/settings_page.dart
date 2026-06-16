import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:actpod_studio/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';

class SettingsStep extends ConsumerWidget {
  final bool showPrice;

  const SettingsStep({super.key, this.showPrice = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(singleCreateControllerProvider); // 狀態
    final ctrl = ref.read(singleCreateControllerProvider.notifier); // 方法

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
      if (time == null) return;
      if (time.minute % 30 != 0) {
        final adjustedMinute = (time.minute ~/ 30) * 30;
        timeMinute = adjustedMinute;
      } else {
        timeMinute = time.minute;
      }
      ctrl.setScheduledAt(
        DateTime(date.year, date.month, date.day, time.hour, timeMinute),
      );
    }

    Future<void> addCollaborator() async {
      final controller = TextEditingController();
      await showDialog<bool>(
        context: context,
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final _scrollController = ScrollController();

            final state = ref.watch(singleCreateControllerProvider); // 狀態
            final ctrl = ref.read(
              singleCreateControllerProvider.notifier,
            ); // 方法

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

            if (showPrice) ...[
              const _SectionTitle('金額'),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final podcoinsField = _PriceNumberField(
                    key: const ValueKey('single_price_podcoins'),
                    label: 'Podcoins',
                    value: state.pricePodcoin,
                    onChanged: ctrl.setPricePodcoin,
                  );
                  final twdField = _PriceNumberField(
                    key: const ValueKey('single_price_twd'),
                    label: 'TWD',
                    value: state.priceTwd,
                    onChanged: ctrl.setPriceTwd,
                  );

                  if (constraints.maxWidth >= 560) {
                    return Row(
                      children: [
                        Expanded(child: podcoinsField),
                        const SizedBox(width: 12),
                        Expanded(child: twdField),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      podcoinsField,
                      const SizedBox(height: 12),
                      twdField,
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
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
                  visible:
                      state.collaborator == null ||
                      state.collaborator?.userId == "",
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

class _PriceNumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _PriceNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final digits = _normalizeDigits(value);
        onChanged(int.tryParse(digits) ?? 0);
      },
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

String _normalizeDigits(String value) {
  final buffer = StringBuffer();
  for (final codeUnit in value.codeUnits) {
    if (codeUnit >= 0x30 && codeUnit <= 0x39) {
      buffer.writeCharCode(codeUnit);
    } else if (codeUnit >= 0xff10 && codeUnit <= 0xff19) {
      buffer.writeCharCode(codeUnit - 0xff10 + 0x30);
    }
  }
  return buffer.toString();
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ModeButton({
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
