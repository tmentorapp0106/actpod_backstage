import 'dart:async';
import 'dart:convert';

import 'package:actpod_studio/features/live_host/models/live_host_member.dart';
import 'package:actpod_studio/features/live_host/models/live_host_members_state.dart';
import 'package:actpod_studio/features/live_host/services/live_host_ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostMembersController extends Notifier<LiveHostMembersState> {
  StreamSubscription<Map<String, dynamic>>? _messageSub;

  @override
  LiveHostMembersState build() {
    final service = ref.watch(liveHostWsServiceProvider);
    _messageSub = service.messages.listen(_handleWsMessage);
    ref.onDispose(() => unawaited(_messageSub?.cancel()));
    return const LiveHostMembersState();
  }

  void reset() {
    state = const LiveHostMembersState();
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final cmd = message['cmd']?.toString() ?? '';
    if (cmd == 'accessRoom') {
      _addMemberFromContent(message['content']);
      return;
    }
    if (cmd == 'leaveRoom') {
      _removeMemberFromContent(message['content']);
      return;
    }
    if (cmd == 'handUp') {
      _setMemberHandsUp(message['from']?.toString() ?? '', true);
      return;
    }
    if (cmd == 'handDown') {
      _setMemberHandsUp(message['from']?.toString() ?? '', false);
      return;
    }
    if (cmd == 'updateMic') {
      _updateOnMicUserIds(message['content']);
    }
  }

  void _addMemberFromContent(dynamic content) {
    final member = _memberFromContent(content);
    if (member == null || member.userId.isEmpty) return;
    if (state.members.any((item) => item.userId == member.userId)) return;
    state = state.copyWith(members: [...state.members, member]);
  }

  void _removeMemberFromContent(dynamic content) {
    final member = _memberFromContent(content);
    if (member == null || member.userId.isEmpty) return;
    state = state.copyWith(
      members: state.members
          .where((item) => item.userId != member.userId)
          .toList(),
      onMicUserIds: state.onMicUserIds
          .where((userId) => userId != member.userId)
          .toList(),
    );
  }

  LiveHostMember? _memberFromContent(dynamic content) {
    if (content == null) return null;
    try {
      final decoded = content is String ? jsonDecode(content) : content;
      if (decoded is Map<String, dynamic>) {
        return LiveHostMember.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _setMemberHandsUp(String userId, bool isHandsUp) {
    if (userId.isEmpty) return;
    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (member.userId == userId)
            member.copyWith(isHandsUp: isHandsUp)
          else
            member,
      ],
    );
  }

  void _updateOnMicUserIds(dynamic content) {
    try {
      final decoded = content is String ? jsonDecode(content) : content;
      if (decoded is List) {
        state = state.copyWith(
          onMicUserIds: decoded.map((item) => item.toString()).toList(),
        );
      }
    } catch (_) {
      return;
    }
  }
}

final liveHostMembersControllerProvider =
    NotifierProvider<LiveHostMembersController, LiveHostMembersState>(
      LiveHostMembersController.new,
    );
