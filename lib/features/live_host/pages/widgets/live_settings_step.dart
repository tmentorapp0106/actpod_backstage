part of '../live_host_page.dart';

class _LiveSettingsStep extends StatelessWidget {
  final LiveHostViewState state;
  final VoidCallback onBack;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<LiveHostRoomType> onRoomTypeChanged;
  final ValueChanged<String> onCapacityChanged;
  final ValueChanged<bool> onNotifyFansChanged;
  final ValueChanged<String> onNotyetOwnedPriceChanged;
  final ValueChanged<String> onAlreadyOwnedPriceChanged;
  final VoidCallback onOpenRoom;

  const _LiveSettingsStep({
    required this.state,
    required this.onBack,
    required this.onTitleChanged,
    required this.onRoomTypeChanged,
    required this.onCapacityChanged,
    required this.onNotifyFansChanged,
    required this.onNotyetOwnedPriceChanged,
    required this.onAlreadyOwnedPriceChanged,
    required this.onOpenRoom,
  });

  @override
  Widget build(BuildContext context) {
    final story = state.selectedStory;

    return Column(
      key: const ValueKey('live-host-live-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.outlined(
              tooltip: '回到故事選擇',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '設定直播',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '確認直播資訊後，下一步會進入主持畫面。',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (state.error != null) ...[
          _ErrorBanner(message: state.error!),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final storyCard = _SelectedStoryCard(story: story);
              final formCard = _LiveSettingsForm(
                state: state,
                onTitleChanged: onTitleChanged,
                onRoomTypeChanged: onRoomTypeChanged,
                onCapacityChanged: onCapacityChanged,
                onNotifyFansChanged: onNotifyFansChanged,
                onNotyetOwnedPriceChanged: onNotyetOwnedPriceChanged,
                onAlreadyOwnedPriceChanged: onAlreadyOwnedPriceChanged,
              );

              if (isNarrow) {
                return ListView(
                  children: [storyCard, const SizedBox(height: 16), formCard],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: storyCard),
                  const SizedBox(width: 16),
                  Expanded(child: formCard),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                state.canSubmitLiveSettings ? '設定完成，可以進入下一步' : '請完成必填欄位',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed:
                  state.canSubmitLiveSettings &&
                      state.status != LiveHostStatus.connecting
                  ? onOpenRoom
                  : null,
              icon: state.status == LiveHostStatus.connecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.podcasts_rounded),
              label: Text(
                state.status == LiveHostStatus.connecting ? '連線中' : '開啟直播',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
