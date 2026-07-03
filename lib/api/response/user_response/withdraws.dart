import 'package:dio/dio.dart';

class WithdrawActionResponse {
  final String code;
  final String message;

  const WithdrawActionResponse({required this.code, required this.message});

  factory WithdrawActionResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return WithdrawActionResponse(
      code: _string(json['code']),
      message: _string(json['message']),
    );
  }
}

class GetWithdrawsResponse {
  final String code;
  final String message;
  final List<Withdraw> withdraws;

  const GetWithdrawsResponse({
    required this.code,
    required this.message,
    required this.withdraws,
  });

  factory GetWithdrawsResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetWithdrawsResponse(
      code: _string(json['code']),
      message: _string(json['message']),
      withdraws: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(Withdraw.fromJson)
                .toList()
          : const [],
    );
  }
}

class Withdraw {
  final String withdrawId;
  final String status;
  final String userId;
  final int podCash;
  final String email;
  final String phone;
  final DateTime? transferTime;
  final DateTime? createTime;
  final DateTime? updateTime;

  const Withdraw({
    required this.withdrawId,
    required this.status,
    required this.userId,
    required this.podCash,
    required this.email,
    required this.phone,
    required this.transferTime,
    required this.createTime,
    required this.updateTime,
  });

  factory Withdraw.fromJson(Map<String, dynamic> json) {
    return Withdraw(
      withdrawId: _string(json['withdrawId']),
      status: _string(json['status']),
      userId: _string(json['userId']),
      podCash: _int(json['podCash']),
      email: _string(json['email']),
      phone: _string(json['phone']),
      transferTime: _dateTime(json['transferTime']),
      createTime: _dateTime(json['createTime']),
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
