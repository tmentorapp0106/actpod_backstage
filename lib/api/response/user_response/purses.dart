import 'package:dio/dio.dart';

class PursesResponse {
  final String code;
  final String message;
  final CoinsPurse? coinsPurse;
  final CashPurse? cashPurse;

  const PursesResponse({
    required this.code,
    required this.message,
    required this.coinsPurse,
    required this.cashPurse,
  });

  factory PursesResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final coinsPurse = dataMap['coinsPurse'];
    final cashPurse = dataMap['cashPurse'];

    return PursesResponse(
      code: _string(json['code']),
      message: _string(json['message']),
      coinsPurse: coinsPurse is Map<String, dynamic>
          ? CoinsPurse.fromJson(coinsPurse)
          : null,
      cashPurse: cashPurse is Map<String, dynamic>
          ? CashPurse.fromJson(cashPurse)
          : null,
    );
  }
}

class CoinsPurse {
  final String userId;
  final int podCoins;
  final DateTime? updateTime;

  const CoinsPurse({
    required this.userId,
    required this.podCoins,
    required this.updateTime,
  });

  factory CoinsPurse.fromJson(Map<String, dynamic> json) {
    return CoinsPurse(
      userId: _string(json['userId']),
      podCoins: _int(json['podCoins']),
      updateTime: _dateTime(json['updateTime']),
    );
  }
}

class CashPurse {
  final String userId;
  final int podCash;
  final DateTime? updateTime;

  const CashPurse({
    required this.userId,
    required this.podCash,
    required this.updateTime,
  });

  factory CashPurse.fromJson(Map<String, dynamic> json) {
    return CashPurse(
      userId: _string(json['userId']),
      podCash: _int(json['podCash']),
      updateTime: _dateTime(json['updateTime']),
    );
  }
}

String _string(dynamic value) {
  if (value is String) return value;
  return '';
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
