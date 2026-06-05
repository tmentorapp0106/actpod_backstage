import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditPackageSelectStep extends ConsumerStatefulWidget {
  const EditPackageSelectStep({super.key});

  @override
  ConsumerState<EditPackageSelectStep> createState() =>
      _EditPackageSelectStepState();
}

class _EditPackageSelectStepState extends ConsumerState<EditPackageSelectStep> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userControllerProvider)?.userId ?? '';
      if (userId.isEmpty) return;
      ref
          .read(packageCreateControllerProvider.notifier)
          .loadEditablePackages(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '選擇套裝',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '選擇一個已建立的套裝，接著就可以編輯套裝資訊、價格與故事。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            if (userId.isEmpty)
              const _EmptyMessage(message: '尚未取得使用者資料，請重新登入後再試。')
            else if (state.loadingEditablePackages)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.editablePackages.isEmpty)
              const _EmptyMessage(message: '目前沒有可編輯的套裝。')
            else
              ...state.editablePackages.map(
                (package) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EditablePackageTile(
                    package: package,
                    selected: state.selectedEditPackageId == package.packageId,
                    onTap: () => ctrl.setEditPackage(package.packageId),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditablePackageTile extends StatelessWidget {
  final PremiumPackage package;
  final bool selected;
  final VoidCallback onTap;

  const _EditablePackageTile({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .06)
              : Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: package.packageImageUrl.isEmpty
                  ? Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.inventory_2_rounded),
                    )
                  : Image.network(
                      package.packageImageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_rounded),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.packageName.isEmpty ? '未命名套裝' : package.packageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.packageDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text('${package.packagePrices.length} 個價格'),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (package.packageType.isNotEmpty)
                        Chip(
                          label: Text(package.packageType),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Text(message, style: const TextStyle(color: Colors.black54)),
    );
  }
}
