library;

import 'live_host_chat_message.dart';

class LiveHostChatState {
  final List<LiveHostChatMessage> messages;

  const LiveHostChatState({this.messages = const []});

  LiveHostChatState copyWith({List<LiveHostChatMessage>? messages}) {
    return LiveHostChatState(messages: messages ?? this.messages);
  }
}
