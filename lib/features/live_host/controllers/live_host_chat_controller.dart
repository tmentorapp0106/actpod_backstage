import 'dart:async';

import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_members_controller.dart';
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

  Future<void> sendChat({
    required String userId,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (userId.isEmpty || trimmedContent.isEmpty) return;
    ref.read(liveHostWsServiceProvider).sendJson({
      'cmd': 'sendChat',
      'from': userId,
      'content': trimmedContent,
      'params': ['text'],
    });
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final cmd = message['cmd']?.toString() ?? '';
    if (cmd != 'sendChat') return;
    final chatMessage = LiveHostChatMessage.fromJson(message);
    final host = ref.read(userControllerProvider);
    if (host != null && chatMessage.userId == host.userId) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          chatMessage.markHost(nickname: host.name, avatarUrl: host.avatarUrl),
        ],
      );
      return;
    }
    final member = ref
        .read(liveHostMembersControllerProvider)
        .findMember(chatMessage.userId);
    state = state.copyWith(
      messages: [...state.messages, chatMessage.fillMember(member)],
    );
  }
}

final liveHostChatControllerProvider =
    NotifierProvider<LiveHostChatController, LiveHostChatState>(
      LiveHostChatController.new,
    );
