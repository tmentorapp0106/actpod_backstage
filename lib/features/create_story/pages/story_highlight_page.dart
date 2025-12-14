import 'dart:async';
import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';



class HighlightStep extends ConsumerStatefulWidget {
  const HighlightStep({super.key});

  @override
  ConsumerState<HighlightStep> createState() => _HighlightStepState();
}

class _HighlightStepState extends ConsumerState<HighlightStep> {
  

  late final AudioPlayer _player;
  StreamSubscription<Duration>? _posSub;

  // 你之後可以把 totalDuration 改成從 controller/state 取得
  Duration totalDuration = const Duration(minutes: 00, seconds:000);

  // 預設精華長度（秒）
  int _clipLen = 20;
  // 開始時間（秒）
  int _startSec = 0;

  // --- 試聽播放器（模擬，之後可換 just_audio）---
  bool _playing = false;
  double _previewPos = 0; // 0~_clipLen
  // Timer? _timer;

  bool _highlightLocked = false; // false = 還在調整, true = 已選定



@override
void initState() {
  super.initState();
  _player = AudioPlayer();

  Future.microtask(() async {
    final state = ref.read(createControllerProvider);
    if (state.audios.isEmpty) return;

    final audio = state.audios.first;

    // ✅ 若有 bytes 就優先用 bytes 播（例如 Web 上傳）
    if (audio.fileBytes.isNotEmpty) {
      // 用 Data URI 把 bytes 包成一個可以播放的 Uri
      final uri = Uri.dataFromBytes(
        audio.fileBytes,
        mimeType: 'audio/mpeg', // 如果是 m4a / wav 等，記得改成正確的 mimeType
      );

      await _player.setAudioSource(
        AudioSource.uri(uri),
      );
    }
    // ✅ 否則用 path（本機或遠端 URL）
    else if (audio.path.isNotEmpty) {
      // 如果是本機檔案
      await _player.setAudioSource(
        AudioSource.file(audio.path),
      );

      // 如果未來是純 URL（例如後端給的 mp3 網址），可以改成：
      // await _player.setAudioSource(AudioSource.uri(Uri.parse(audio.path)));
    }

    final dur = _player.duration;
    if (!mounted || dur == null) return;

    setState(() {
      totalDuration = dur;
      _clipLen = _clipLen.clamp(5, dur.inSeconds);
    });

  });
}


@override
void dispose() {
  _posSub?.cancel();
  _player.dispose();
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


  void _toggleLock() {
    setState(() {
      _highlightLocked = !_highlightLocked;
    });
  }

void _togglePlay() async {
  // 目前是「播放中」→ 那就暫停
  if (_playing) {
    await _player.pause();
    setState(() => _playing = false);
    return;
  }

  // 精華開始＆結束時間
  final start = Duration(seconds: _startSec);
  final end = Duration(seconds: _startSec + _clipLen);

  // 從精華開始秒數播
  await _player.seek(start);
  await _player.play();

  setState(() {
    _playing = true;
    _previewPos = 0; // 精華內部的 0 秒
  });

  // 監聽播放進度
  _posSub?.cancel();
  _posSub = _player.positionStream.listen((pos) {
    if (!mounted) return;

    final sec = pos.inSeconds;

    // 超過精華結束 → 自動停 & 回到開頭
    if (sec >= end.inSeconds) {
      _player.pause();
      _player.seek(start);
      setState(() {
        _playing = false;
        _previewPos = 0;
      });
    } else {
      // 更新精華區段內的 slider（0 ~ _clipLen）
      setState(() {
        _previewPos =
            (sec - _startSec).toDouble().clamp(0, _clipLen.toDouble());
      });
    }
  });
}





  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createControllerProvider);
    final ctrl = ref.read(createControllerProvider.notifier);

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
                DropdownMenuItem(value: 20, child: Text('20 秒')),
                DropdownMenuItem(value: 40, child: Text('40 秒')),
                DropdownMenuItem(value: 60, child: Text('60 秒')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _clipLen = v;
                  // 重新校正 start，避免超出
                  ctrl.setHighlightLength(Duration(seconds: v));
                  final latestStart =
                      (totalDuration.inSeconds - _clipLen).clamp(0, totalDuration.inSeconds);
                  if (_startSec > latestStart) {
                    _startSec = latestStart;
                  }
                  // 重置試聽狀態
                  _previewPos = 0;
                  _playing = false;
                  // _timer?.cancel();
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
                  // _timer?.cancel();
                  ctrl.setSelection(
                    start: Duration(seconds: _startSec),
                  );
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
                      onChanged: (v) async {
                        final newSec = _startSec + v.floor(); // 精華區段內第 v 秒 → 總時間軸上的秒數
                        await _player.seek(Duration(seconds: newSec));
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
                  SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _toggleLock,
                    style: FilledButton.styleFrom(
                      backgroundColor:context.color.border ,
                      minimumSize: const Size(80, 36),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      _highlightLocked ? Icons.lock_open_rounded : Icons.lock_outline,
                      color: Colors.white,
                    ),
                    label: Text(_highlightLocked ? '選定' : '重選'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
    // _mm.text = (seconds ~/ 60).toString().padLeft(2, '0');
    // _ss.text = (seconds % 60).toString().padLeft(2, '0');

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
