import 'dart:async';

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/app/theme/app_colors.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_chat_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_flow_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_members_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_player_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_room_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_settings_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_stories_controller.dart';
import 'package:actpod_studio/features/live_host/models/live_host_chat_message.dart';
import 'package:actpod_studio/features/live_host/models/live_host_chat_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_constants.dart';
import 'package:actpod_studio/features/live_host/models/live_host_enums.dart';
import 'package:actpod_studio/features/live_host/models/live_host_flow_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_member.dart';
import 'package:actpod_studio/features/live_host/models/live_host_members_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_player_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_room_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_settings_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_stories_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'widgets/live_host_page_state.dart';
part 'widgets/story_selection_scope.dart';
part 'widgets/live_settings_scope.dart';
part 'widgets/landing_step.dart';
part 'widgets/story_selection_step.dart';
part 'widgets/story_tile.dart';
part 'widgets/story_meta_chip.dart';
part 'widgets/live_settings_step.dart';
part 'widgets/live_room_step.dart';
part 'widgets/player_control_card.dart';
part 'widgets/story_control_preview.dart';
part 'widgets/player_controls.dart';
part 'widgets/chat_panel.dart';
part 'widgets/chat_message_tile.dart';
part 'widgets/members_panel.dart';
part 'widgets/member_tile.dart';
part 'widgets/room_info_card.dart';
part 'widgets/room_info_section.dart';
part 'widgets/share_link_box.dart';
part 'widgets/status_badge.dart';
part 'widgets/info_row.dart';
part 'widgets/selected_story_card.dart';
part 'widgets/live_settings_form.dart';
part 'widgets/live_settings_form_state.dart';
part 'widgets/error_banner.dart';
part 'widgets/empty_stories.dart';
part 'widgets/no_search_result.dart';

class LiveHostPage extends ConsumerStatefulWidget {
  const LiveHostPage({super.key});

  @override
  ConsumerState<LiveHostPage> createState() => _LiveHostPageState();
}

void _startNewLiveFlow(WidgetRef ref) {
  ref.read(liveHostRoomControllerProvider.notifier).resetForNewLive();
  unawaited(
    ref.read(liveHostPlayerControllerProvider.notifier).disposePlayer(),
  );
  ref.read(liveHostChatControllerProvider.notifier).reset();
  ref.read(liveHostMembersControllerProvider.notifier).reset();
  ref.read(liveHostStoriesControllerProvider.notifier).resetSelection();
  ref.read(liveHostSettingsControllerProvider.notifier).reset();
  ref.read(liveHostFlowControllerProvider.notifier).startLiveFlow();
}

LiveHostViewState _viewState({
  LiveHostFlowState flow = const LiveHostFlowState(),
  LiveHostStoriesState stories = const LiveHostStoriesState(),
  LiveHostSettingsState settings = const LiveHostSettingsState(),
  LiveHostRoomState room = const LiveHostRoomState(),
  LiveHostPlayerState player = const LiveHostPlayerState(),
  LiveHostChatState chat = const LiveHostChatState(),
  LiveHostMembersState members = const LiveHostMembersState(),
  String? error,
}) {
  return LiveHostViewState(
    step: flow.step,
    loadingStories: stories.loading,
    error: error ?? stories.error ?? room.error ?? player.error,
    stories: stories.stories,
    searchKeyword: stories.searchKeyword,
    selectedStory: stories.selectedStory,
    roomTitle: settings.roomTitle,
    roomType: settings.roomType,
    capacity: settings.capacity,
    notifyFans: settings.notifyFans,
    notyetOwnedStoryPrice: settings.notyetOwnedStoryPrice,
    alreadyOwnedStoryPrice: settings.alreadyOwnedStoryPrice,
    status: room.status,
    roomId: room.roomId,
    members: members.members,
    chatMessages: chat.messages,
    playerStatus: player.playerStatus,
    pendingPlayerAction: player.pendingAction,
    currentPosition: player.currentPosition,
    duration: player.duration,
    onMicUserIds: members.onMicUserIds,
  );
}

Future<void> _confirmCloseRoom(
  BuildContext context,
  Future<void> Function() onCloseRoom,
) async {
  final shouldClose = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('關閉直播'),
        content: const Text('確定要關閉目前直播房間嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('關閉直播'),
          ),
        ],
      );
    },
  );
  if (shouldClose == true) {
    await onCloseRoom();
  }
}

Future<void> _copyShareUrl(BuildContext context, String shareUrl) async {
  await Clipboard.setData(ClipboardData(text: shareUrl));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('已複製分享連結')));
}

String _storyImageUrl(StoryItem? story) {
  if (story == null) return '';
  if (story.storyImageUrl.isNotEmpty) return story.storyImageUrl;
  return story.storyImageUrls.isNotEmpty ? story.storyImageUrls.first : '';
}

String _formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)}';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String? _capacityErrorText(LiveHostViewState state) {
  if (state.capacity <= 0) return '人數上限需大於 0';
  if (state.roomType == LiveHostRoomType.interactive &&
      state.capacity > liveHostInteractiveCapacityLimit) {
    return '互動直播最多 $liveHostInteractiveCapacityLimit 人';
  }
  return null;
}
