import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageSetupStep extends ConsumerWidget {
  const PackageSetupStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              initialValue: state.packageName ?? '',
              onChanged: ctrl.setPackageName,
              decoration: const InputDecoration(
                labelText: '套裝名稱',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.packageDescription ?? '',
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

class _PriceField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _PriceField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
      decoration: InputDecoration(
        labelText: '$label (Podcoin)',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
