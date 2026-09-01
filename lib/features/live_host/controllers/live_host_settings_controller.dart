import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/features/live_host/models/live_host_enums.dart';
import 'package:actpod_studio/features/live_host/models/live_host_settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostSettingsController extends Notifier<LiveHostSettingsState> {
  @override
  LiveHostSettingsState build() => const LiveHostSettingsState();

  void applyStoryDefaultTitle(StoryItem story) {
    if (state.roomTitle.trim().isNotEmpty) return;
    state = state.copyWith(roomTitle: story.storyName);
  }

  void updateRoomTitle(String value) {
    state = state.copyWith(roomTitle: value);
  }

  void updateRoomType(LiveHostRoomType value) {
    state = state.copyWith(
      roomType: value,
      capacity: value == LiveHostRoomType.listenOnly ? 100 : null,
    );
  }

  void updateCapacity(String value) {
    if (value.isEmpty) {
      state = state.copyWith(capacity: 0);
      return;
    }
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(capacity: next);
  }

  void updateNotifyFans(bool value) {
    state = state.copyWith(notifyFans: value);
  }

  void updateNotyetOwnedStoryPrice(String value) {
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(notyetOwnedStoryPrice: next);
  }

  void updateAlreadyOwnedStoryPrice(String value) {
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(alreadyOwnedStoryPrice: next);
  }

  void reset() {
    state = const LiveHostSettingsState();
  }
}

final liveHostSettingsControllerProvider =
    NotifierProvider<LiveHostSettingsController, LiveHostSettingsState>(
      LiveHostSettingsController.new,
    );
