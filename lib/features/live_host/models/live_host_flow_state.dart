library;

import 'live_host_enums.dart';

class LiveHostFlowState {
  final LiveHostStep step;

  const LiveHostFlowState({this.step = LiveHostStep.landing});

  LiveHostFlowState copyWith({LiveHostStep? step}) {
    return LiveHostFlowState(step: step ?? this.step);
  }
}
