part of '../live_host_page.dart';

class _RoomInfoCard extends StatelessWidget {
  final LiveHostViewState state;
  final VoidCallback onStartNewLive;

  const _RoomInfoCard({required this.state, required this.onStartNewLive});

  @override
  Widget build(BuildContext context) {
    final shareUrl = state.shareUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _RoomInfoSection(
          state: state,
          onStartNewLive: onStartNewLive,
          shareUrl: shareUrl,
          onCopyShareUrl: shareUrl.isEmpty
              ? null
              : () => _copyShareUrl(context, shareUrl),
        ),
      ),
    );
  }
}
