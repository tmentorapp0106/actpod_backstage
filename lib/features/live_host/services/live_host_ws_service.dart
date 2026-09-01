import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class LiveHostWsService {
  LiveHostWsService({this.wsBaseUrl = 'wss://apiv1.actpodapp.com'});

  final String wsBaseUrl;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionState = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messages.stream;
  Stream<bool> get connectionState => _connectionState.stream;

  Future<void> connect(String userId) async {
    await close();
    final uri = Uri.parse(
      '$wsBaseUrl/live/ws?userId=${Uri.encodeQueryComponent(userId)}',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    await channel.ready.timeout(const Duration(seconds: 12));
    _connectionState.add(true);

    _subscription = channel.stream.listen(
      _handleIncoming,
      onError: (Object error) {
        _connectionState.add(false);
        _messages.add({'cmd': 'error', 'content': error.toString()});
      },
      onDone: () => _connectionState.add(false),
      cancelOnError: false,
    );
  }

  void sendJson(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  Future<void> close() async {
    final hadConnection = _subscription != null || _channel != null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(1000);
    _channel = null;
    if (hadConnection) {
      _connectionState.add(false);
    }
  }

  Future<void> dispose() async {
    await close();
    await _messages.close();
    await _connectionState.close();
  }

  void _handleIncoming(dynamic event) {
    final text = event is String ? event : utf8.decode(event as List<int>);
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        _messages.add(decoded);
      }
    } catch (_) {
      _messages.add({'cmd': 'text', 'content': text});
    }
  }
}
