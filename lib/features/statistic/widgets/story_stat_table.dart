import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:flutter/material.dart';

class StoryStatTable extends StatelessWidget {
  final List<StoryStatistic> stories;

  const StoryStatTable({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Text(
              '故事互動明細',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
              columns: const [
                DataColumn(label: Text('故事')),
                DataColumn(label: Text('套裝')),
                DataColumn(label: Text('播放'), numeric: true),
                DataColumn(label: Text('留言'), numeric: true),
                DataColumn(label: Text('即時留言'), numeric: true),
                DataColumn(label: Text('按讚'), numeric: true),
                DataColumn(label: Text('語音'), numeric: true),
                DataColumn(label: Text('互動率'), numeric: true),
              ],
              rows: [
                for (final story in stories)
                  DataRow(
                    cells: [
                      DataCell(_LimitedText(story.story.storyName)),
                      DataCell(_LimitedText(story.story.packageName)),
                      DataCell(Text(_formatNumber(story.listenCount))),
                      DataCell(Text(_formatNumber(story.commentCount))),
                      DataCell(Text(_formatNumber(story.instantCommentCount))),
                      DataCell(Text(_formatNumber(story.likeCount))),
                      DataCell(Text(_formatNumber(story.voiceMessageCount))),
                      DataCell(Text(_formatPercent(story.interactionRate))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  String _formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}

class _LimitedText extends StatelessWidget {
  final String text;

  const _LimitedText(this.text);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(
        text.isEmpty ? '-' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
