import 'dart:async';

import 'package:actpod_studio/features/live_host/models/live_host_chat_message.dart';
import 'package:actpod_studio/features/live_host/models/live_host_chat_state.dart';
import 'package:actpod_studio/features/live_host/services/live_host_ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostChatController extends Notifier<LiveHostChatState> {
  StreamSubscription<Map<String, dynamic>>? _messageSub;

  @override
  LiveHostChatState build() {
    final service = ref.watch(liveHostWsServiceProvider);
    _messageSub = service.messages.listen(_handleWsMessage);
    ref.onDispose(() => unawaited(_messageSub?.cancel()));
    return const LiveHostChatState();
  }

  void reset() {
    state = const LiveHostChatState();
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final cmd = message['cmd']?.toString() ?? '';
    if (cmd != 'sendChat') return;
    state = state.copyWith(
      messages: [...state.messages, LiveHostChatMessage.fromJson(message)],
    );
  }
}

final liveHostChatControllerProvider =
    NotifierProvider<LiveHostChatController, LiveHostChatState>(
      LiveHostChatController.new,
    );
