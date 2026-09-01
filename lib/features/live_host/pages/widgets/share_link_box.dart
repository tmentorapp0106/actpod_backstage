part of '../live_host_page.dart';

class _ShareLinkBox extends StatelessWidget {
  final String shareUrl;
  final VoidCallback? onCopy;

  const _ShareLinkBox({required this.shareUrl, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final displayUrl = shareUrl.isEmpty ? '-' : shareUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分享連結',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 14, right: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.link_rounded,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: displayUrl,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Text(
                    displayUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(
                tooltip: '複製分享連結',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
