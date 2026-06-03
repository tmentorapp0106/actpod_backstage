import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_flow_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateTypeStep extends ConsumerWidget {
  const CreateTypeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createFlowControllerProvider);
    final ctrl = ref.read(createFlowControllerProvider.notifier);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '選擇建立類型',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '先決定這次要發布單一故事，或建立可包含多集的套裝。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final singleCard = _FlowTypeCard(
                  title: '單一 Story',
                  description: '建立一集故事，可設定免費或單集售價。',
                  icon: Icons.article_rounded,
                  selected: state.flowType == CreateFlowType.single,
                  onTap: () => ctrl.setFlowType(CreateFlowType.single),
                );
                final packageCard = _FlowTypeCard(
                  title: '套裝 Package',
                  description: '建立套裝資料與價格，再把故事加入套裝中。',
                  icon: Icons.inventory_2_rounded,
                  selected: state.flowType == CreateFlowType.package,
                  onTap: () => ctrl.setFlowType(CreateFlowType.package),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: singleCard),
                      const SizedBox(width: 16),
                      Expanded(child: packageCard),
                    ],
                  );
                }

                return Column(
                  children: [
                    singleCard,
                    const SizedBox(height: 12),
                    packageCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FlowTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.color.brand;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? brand : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? brand.withOpacity(.06) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? brand : Colors.black54, size: 30),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
