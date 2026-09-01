import 'package:actpod_studio/features/live_host/models/live_host_enums.dart';
import 'package:actpod_studio/features/live_host/models/live_host_flow_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostFlowController extends Notifier<LiveHostFlowState> {
  @override
  LiveHostFlowState build() => const LiveHostFlowState();

  void startLiveFlow() {
    state = state.copyWith(step: LiveHostStep.storySelection);
  }

  void goToLiveSettings() {
    state = state.copyWith(step: LiveHostStep.liveSettings);
  }

  void goToLiveRoom() {
    state = state.copyWith(step: LiveHostStep.liveRoom);
  }

  void backToLanding() {
    state = state.copyWith(step: LiveHostStep.landing);
  }

  void backToStorySelection() {
    state = state.copyWith(step: LiveHostStep.storySelection);
  }
}

final liveHostFlowControllerProvider =
    NotifierProvider<LiveHostFlowController, LiveHostFlowState>(
      LiveHostFlowController.new,
    );
