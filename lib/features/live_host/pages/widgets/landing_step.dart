part of '../live_host_page.dart';

class _LandingStep extends StatelessWidget {
  final VoidCallback onStart;

  const _LandingStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('live-host-landing'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.podcasts_rounded,
              size: 64,
              color: AppColors.brand,
            ),
            const SizedBox(height: 18),
            const Text(
              '開始直播',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '建立主持人直播流程，選擇故事後再設定直播內容。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('開始直播'),
            ),
          ],
        ),
      ),
    );
  }
}
