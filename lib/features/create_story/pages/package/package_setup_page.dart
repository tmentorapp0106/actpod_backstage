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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '套裝資訊',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final packagePriceField = _PriceField(
                  label: '套裝價格',
                  value: state.packagePricePodcoin,
                  onChanged: ctrl.setPackagePrice,
                );
                final soloPriceField = _PriceField(
                  label: '單賣價格',
                  value: state.packageSoloPricePodcoin,
                  onChanged: ctrl.setPackageSoloPrice,
                );

                if (constraints.maxWidth >= 720) {
                  return Row(
                    children: [
                      Expanded(child: packagePriceField),
                      const SizedBox(width: 16),
                      Expanded(child: soloPriceField),
                    ],
                  );
                }

                return Column(
                  children: [
                    packagePriceField,
                    const SizedBox(height: 12),
                    soloPriceField,
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
              label: Text(state.packageImageBytes == null ? '上傳封面' : '更換封面'),
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
      value: state.selectedSpace,
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
      value: state.selectedChannel,
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

class _PriceField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _PriceField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<_PriceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
        widget.onChanged(int.tryParse(digits) ?? 0);
      },
      decoration: InputDecoration(
        labelText: '${widget.label} (Podcoin)',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
