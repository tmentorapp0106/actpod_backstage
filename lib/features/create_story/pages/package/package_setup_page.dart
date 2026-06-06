import 'package:actpod_studio/features/create_story/controllers/create_flow_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageSetupStep extends ConsumerStatefulWidget {
  const PackageSetupStep({super.key});

  @override
  ConsumerState<PackageSetupStep> createState() => _PackageSetupStepState();
}

class _PackageSetupStepState extends ConsumerState<PackageSetupStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(packageCreateControllerProvider);
    _nameController = TextEditingController(text: state.packageName ?? '');
    _descriptionController = TextEditingController(
      text: state.packageDescription ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flow = ref.read(createFlowControllerProvider);
      if (flow.flowType == CreateFlowType.editPackage) {
        ref
            .read(packageCreateControllerProvider.notifier)
            .loadSelectedPackageInfo();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(packageCreateControllerProvider, (previous, next) {
      if (previous?.packageName != next.packageName &&
          _nameController.text != (next.packageName ?? '')) {
        _nameController.text = next.packageName ?? '';
      }
      if (previous?.packageDescription != next.packageDescription &&
          _descriptionController.text != (next.packageDescription ?? '')) {
        _descriptionController.text = next.packageDescription ?? '';
      }
    });

    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '套裝資訊',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                if (state.loadingPackageInfo)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (state.error != null && state.error!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              onChanged: ctrl.setPackageName,
              decoration: const InputDecoration(
                labelText: '套裝名稱',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              onChanged: ctrl.setPackageDescription,
              maxLines: 5,
              maxLength: 800,
              decoration: const InputDecoration(
                labelText: '套裝描述',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            _PackageImagePicker(state: state, ctrl: ctrl),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final spaceField = _SpaceField(state: state, ctrl: ctrl);
                final channelField = _ChannelField(state: state, ctrl: ctrl);

                if (constraints.maxWidth >= 720) {
                  return Row(
                    children: [
                      Expanded(child: spaceField),
                      const SizedBox(width: 16),
                      Expanded(child: channelField),
                    ],
                  );
                }

                return Column(
                  children: [
                    spaceField,
                    const SizedBox(height: 12),
                    channelField,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _PackagePricesEditor(state: state, ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

class _PackageImagePicker extends StatelessWidget {
  final PackageCreateState state;
  final PackageCreateController ctrl;

  const _PackageImagePicker({required this.state, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '套裝封面',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: state.pickingPackageImage
                  ? null
                  : ctrl.pickPackageImage,
              icon: const Icon(Icons.image_rounded),
              label: Text(
                state.packageImageBytes == null &&
                        (state.packageImageUrl == null ||
                            state.packageImageUrl!.isEmpty)
                    ? '上傳封面'
                    : '更換封面',
              ),
            ),
            if (state.pickingPackageImage)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (state.packageImagePath != null)
              Chip(
                avatar: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(state.packageImagePath!),
              ),
          ],
        ),
        if (state.packageImageBytes != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              state.packageImageBytes!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ] else if (state.packageImageUrl != null &&
            state.packageImageUrl!.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              state.packageImageUrl!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image_rounded),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SpaceField extends StatelessWidget {
  final PackageCreateState state;
  final PackageCreateController ctrl;

  const _SpaceField({required this.state, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('space_${state.selectedSpace ?? ''}'),
      initialValue: state.selectedSpace,
      items: state.spaces
          .map(
            (space) => DropdownMenuItem<String>(
              value: space.name,
              child: Text(space.name),
            ),
          )
          .toList(),
      onChanged: ctrl.setSpace,
      decoration: const InputDecoration(
        labelText: '套裝 Space',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _ChannelField extends StatelessWidget {
  final PackageCreateState state;
  final PackageCreateController ctrl;

  const _ChannelField({required this.state, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('channel_${state.selectedChannel ?? ''}'),
      initialValue: state.selectedChannel,
      items: state.channels
          .map(
            (channel) => DropdownMenuItem<String>(
              value: channel.channelName,
              child: Text(channel.channelName),
            ),
          )
          .toList(),
      onChanged: ctrl.setChannel,
      decoration: const InputDecoration(
        labelText: '套裝 Channel',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _PackagePricesEditor extends StatelessWidget {
  final PackageCreateState state;
  final PackageCreateController ctrl;

  const _PackagePricesEditor({required this.state, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '價格設定',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: ctrl.addPackagePrice,
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增價格'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.packagePrices.map(
          (price) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PackagePriceRow(
              price: price,
              canRemove:
                  state.packagePrices.length > 1 &&
                  price.packagePriceId.isEmpty,
              ctrl: ctrl,
            ),
          ),
        ),
      ],
    );
  }
}

class _PackagePriceRow extends StatelessWidget {
  final PackagePriceDraft price;
  final bool canRemove;
  final PackageCreateController ctrl;

  const _PackagePriceRow({
    required this.price,
    required this.canRemove,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fields = [
            DropdownButtonFormField<String>(
              initialValue: price.priceType,
              items: const [
                DropdownMenuItem(value: 'package', child: Text('整套購買')),
                DropdownMenuItem(value: 'single', child: Text('單集購買')),
              ],
              onChanged: (value) {
                if (value != null) ctrl.setPackagePriceType(price.id, value);
              },
              decoration: const InputDecoration(
                labelText: '購買類型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            TextFormField(
              key: ValueKey('${price.id}_lable'),
              initialValue: price.lable,
              onChanged: (value) => ctrl.setPackagePriceLable(price.id, value),
              decoration: const InputDecoration(
                labelText: 'Price 名稱',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            _NumberField(
              key: ValueKey('${price.id}_podcoins'),
              label: 'Podcoins',
              value: price.podcoins,
              onChanged: (value) =>
                  ctrl.setPackagePricePodcoins(price.id, value),
            ),
            _NumberField(
              key: ValueKey('${price.id}_twd'),
              label: 'TWD',
              value: price.twd,
              onChanged: (value) => ctrl.setPackagePriceTwd(price.id, value),
            ),
          ];

          if (constraints.maxWidth >= 920) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < fields.length; i++) ...[
                  Expanded(child: fields[i]),
                  if (i != fields.length - 1) const SizedBox(width: 12),
                ],
                const SizedBox(width: 8),
                _PriceActions(price: price, canRemove: canRemove, ctrl: ctrl),
              ],
            );
          }

          return Column(
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                fields[i],
                const SizedBox(height: 12),
              ],
              _PriceActions(price: price, canRemove: canRemove, ctrl: ctrl),
            ],
          );
        },
      ),
    );
  }
}

class _PriceActions extends StatelessWidget {
  final PackagePriceDraft price;
  final bool canRemove;
  final PackageCreateController ctrl;

  const _PriceActions({
    required this.price,
    required this.canRemove,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('啟用'),
        Switch(
          value: price.isActive,
          onChanged: (value) => ctrl.setPackagePriceActive(price.id, value),
        ),
        IconButton(
          tooltip: '刪除價格',
          onPressed: canRemove ? () => ctrl.removePackagePrice(price.id) : null,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberField({
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
      onChanged: (v) {
        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
        onChanged(int.tryParse(digits) ?? 0);
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
