library;

import 'live_host_member.dart';

class LiveHostMembersState {
  final List<LiveHostMember> members;
  final List<String> onMicUserIds;

  const LiveHostMembersState({
    this.members = const [],
    this.onMicUserIds = const [],
  });

  LiveHostMembersState copyWith({
    List<LiveHostMember>? members,
    List<String>? onMicUserIds,
  }) {
    return LiveHostMembersState(
      members: members ?? this.members,
      onMicUserIds: onMicUserIds ?? this.onMicUserIds,
    );
  }

  LiveHostMember? findMember(String userId) {
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }
}
