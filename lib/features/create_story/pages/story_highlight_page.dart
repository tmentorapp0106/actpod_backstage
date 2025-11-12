import 'dart:async';
import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HighlightStep extends ConsumerStatefulWidget {
  const HighlightStep({super.key});

  @override
  ConsumerState<HighlightStep> createState() => _HighlightStepState();
}

class _HighlightStepState extends ConsumerState<HighlightStep> {
  // 你之後可以把 totalDuration 改成從 controller/state 取得
  Duration totalDuration = const Duration(minutes: 3, seconds: 20);

  // 精華長度（秒）
  int _clipLen = 20;
  // 開始時間（秒）
  int _startSec = 0;

  // --- 試聽播放器（模擬，之後可換 just_audio）---
  bool _playing = false;
  double _previewPos = 0; // 0~_clipLen
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===== Helpers =====
  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Duration _clampedEnd() {
    final end = _startSec + _clipLen;
    final maxEnd = totalDuration.inSeconds;
    return Duration(seconds: end.clamp(0, maxEnd));
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _timer?.cancel();
    if (_playing) {
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted) return;
        setState(() {
          _previewPos += 0.25;
          if (_previewPos >= _clipLen) {
            _previewPos = _clipLen.toDouble();
            _playing = false;
            _timer?.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.color.brand;

    final start = Duration(seconds: _startSec);
    final end = _clampedEnd();
    final remainForStart =
        (totalDuration.inSeconds - _clipLen).clamp(0, totalDuration.inSeconds);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('擷取精華',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),

            // ===== 精華長度 =====
            const Text('精華長度',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _clipLen,
              items: const [
                DropdownMenuItem(value: 10, child: Text('10 秒')),
                DropdownMenuItem(value: 20, child: Text('20 秒')),
                DropdownMenuItem(value: 30, child: Text('30 秒')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _clipLen = v;
                  // 重新校正 start，避免超出
                  final latestStart =
                      (totalDuration.inSeconds - _clipLen).clamp(0, totalDuration.inSeconds);
                  if (_startSec > latestStart) {
                    _startSec = latestStart;
                  }
                  // 重置試聽狀態
                  _previewPos = 0;
                  _playing = false;
                  _timer?.cancel();
                });
              },
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // ===== 開始時間（分：秒 兩格 + 選取按鈕） =====
            const Text('輸入精華開始時間',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            MmSsPicker(
              initialSeconds: _startSec,
              maxStartSeconds: remainForStart,
              onPick: (sec) {
                setState(() {
                  _startSec = sec;     // 套用選取結果
                  _previewPos = 0;     // 重置試聽進度
                  _playing = false;
                  _timer?.cancel();
                });
              },
            ),
            const SizedBox(height: 8),

            // 起迄區段顯示
            Row(
              children: [
                Icon(Icons.splitscreen_rounded, size: 18, color: brand),
                const SizedBox(width: 6),
                Text(
                  '本段：${_fmt(start)} – ${_fmt(end)} / 總長度 ${_fmt(totalDuration)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== 試聽播放器（模擬） =====
            const Text('精華試聽',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _previewPos.clamp(0, _clipLen).toDouble(),
                      min: 0,
                      max: _clipLen.toDouble(),
                      onChanged: (v) {
                        setState(() {
                          _previewPos = v;
                        });
                      },
                      activeColor: brand,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_fmt(Duration(seconds: _previewPos.floor()))),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _togglePlay,
                    style: FilledButton.styleFrom(
                      backgroundColor: brand,
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== 轉場音樂 =====
            const Text('轉場音樂',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: '無',
                    items: const [
                      DropdownMenuItem(value: '無', child: Text('無')),
                      DropdownMenuItem(value: '音樂1', child: Text('音樂1')),
                      DropdownMenuItem(value: '音樂2', child: Text('音樂2')),
                    ],
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('上傳'),
                  style: TextButton.styleFrom(foregroundColor: brand),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 可重用：mm:ss 選擇器（兩個數字框 +「選取」）
/// - 只接受數字
/// - 分 0–99、秒 0–59
/// - 會把選到的總秒數夾在 [0, maxStartSeconds] 之內
class MmSsPicker extends StatefulWidget {
  final int initialSeconds;              // 起始秒數（會自動拆成 mm:ss）
  final void Function(int seconds) onPick; // 按「選取」後回傳總秒數
  final int? maxStartSeconds;            // 允許的最大起點秒數（可選，超過會夾）
  final double boxWidth;                 // 輸入框寬
  final double boxHeight;                // 輸入框高

  const MmSsPicker({
    super.key,
    required this.initialSeconds,
    required this.onPick,
    this.maxStartSeconds,
    this.boxWidth = 72,
    this.boxHeight = 44,
  });

  @override
  State<MmSsPicker> createState() => _MmSsPickerState();
}

class _MmSsPickerState extends State<MmSsPicker> {
  late final TextEditingController _mm;
  late final TextEditingController _ss;

  @override
  void initState() {
    super.initState();
    final m = (widget.initialSeconds ~/ 60).clamp(0, 99);
    final s = (widget.initialSeconds % 60).clamp(0, 59);
    _mm = TextEditingController(text: m.toString().padLeft(2, '0'));
    _ss = TextEditingController(text: s.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _mm.dispose();
    _ss.dispose();
    super.dispose();
  }

  InputDecoration _box(BuildContext context) => InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      );

  Widget _numBox(TextEditingController c) {
    return SizedBox(
      width: widget.boxWidth,
      height: widget.boxHeight,
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: _box(context),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  int _parse2(TextEditingController c) {
    if (c.text.isEmpty) return 0;
    return int.parse(c.text);
  }

  void _onPick() {
    var mm = _parse2(_mm);
    var ss = _parse2(_ss);
    // 修正範圍
    if (ss > 59) ss = 59;
    if (mm < 0) mm = 0;
    var seconds = mm * 60 + ss;

    if (widget.maxStartSeconds != null) {
      seconds = seconds.clamp(0, widget.maxStartSeconds!);
    }

    // 回寫格式化
    _mm.text = (seconds ~/ 60).toString().padLeft(2, '0');
    _ss.text = (seconds % 60).toString().padLeft(2, '0');

    widget.onPick(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.color.brand;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _numBox(_mm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(fontSize: 18)),
        ),
        _numBox(_ss),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _onPick,
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('選取'),
        ),
      ],
    );
  }
}
