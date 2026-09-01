part of '../live_host_page.dart';

class _LiveSettingsForm extends StatefulWidget {
  final LiveHostViewState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<LiveHostRoomType> onRoomTypeChanged;
  final ValueChanged<String> onCapacityChanged;
  final ValueChanged<bool> onNotifyFansChanged;
  final ValueChanged<String> onNotyetOwnedPriceChanged;
  final ValueChanged<String> onAlreadyOwnedPriceChanged;

  const _LiveSettingsForm({
    required this.state,
    required this.onTitleChanged,
    required this.onRoomTypeChanged,
    required this.onCapacityChanged,
    required this.onNotifyFansChanged,
    required this.onNotyetOwnedPriceChanged,
    required this.onAlreadyOwnedPriceChanged,
  });

  @override
  State<_LiveSettingsForm> createState() => _LiveSettingsFormState();
}
