import 'package:actpod_studio/api/response/user_response/purses.dart';
import 'package:actpod_studio/api/response/user_response/withdraws.dart';
import 'package:actpod_studio/api/user_system_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class WithdrawState {
  final bool loading;
  final bool submitting;
  final String? updatingWithdrawId;
  final String? error;
  final CashPurse? cashPurse;
  final CoinsPurse? coinsPurse;
  final List<Withdraw> withdraws;

  const WithdrawState({
    this.loading = false,
    this.submitting = false,
    this.updatingWithdrawId,
    this.error,
    this.cashPurse,
    this.coinsPurse,
    this.withdraws = const [],
  });

  int get availablePodCash => cashPurse?.podCash ?? 0;

  int get requestedPodCash {
    return withdraws.fold(0, (sum, item) => sum + item.podCash);
  }

  int get pendingCount {
    return withdraws
        .where((item) => item.status.toLowerCase() == 'pending')
        .length;
  }

  Withdraw? get latestEditableWithdraw {
    if (withdraws.isEmpty) return null;
    return withdraws.first;
  }

  WithdrawState copyWith({
    bool? loading,
    bool? submitting,
    Object? updatingWithdrawId = _unset,
    Object? error = _unset,
    Object? cashPurse = _unset,
    Object? coinsPurse = _unset,
    List<Withdraw>? withdraws,
  }) {
    return WithdrawState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      updatingWithdrawId: updatingWithdrawId == _unset
          ? this.updatingWithdrawId
          : updatingWithdrawId as String?,
      error: error == _unset ? this.error : error as String?,
      cashPurse: cashPurse == _unset ? this.cashPurse : cashPurse as CashPurse?,
      coinsPurse: coinsPurse == _unset
          ? this.coinsPurse
          : coinsPurse as CoinsPurse?,
      withdraws: withdraws ?? this.withdraws,
    );
  }
}

const _unset = Object();

class WithdrawController extends Notifier<WithdrawState> {
  @override
  WithdrawState build() => const WithdrawState();

  Future<void> load() async {
    if (state.loading) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final api = UserApi();
      final results = await Future.wait([api.getPurses(), api.getWithdraws()]);
      final purses = results[0] as PursesResponse;
      final withdrawsResponse = results[1] as GetWithdrawsResponse;
      final sorted = [...withdrawsResponse.withdraws]
        ..sort((a, b) {
          final aTime = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      state = state.copyWith(
        loading: false,
        cashPurse: purses.cashPurse,
        coinsPurse: purses.coinsPurse,
        withdraws: sorted,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> createWithdraw({
    required String email,
    required String phone,
    required int podcash,
  }) async {
    if (state.submitting) return false;

    state = state.copyWith(submitting: true, error: null);
    try {
      await UserApi().createWithdraw(email, phone, podcash);
      state = state.copyWith(submitting: false);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateWithdrawEmailPhone({
    required String withdrawId,
    required String email,
    required String phone,
  }) async {
    if (state.updatingWithdrawId != null) return false;

    state = state.copyWith(updatingWithdrawId: withdrawId, error: null);
    try {
      await UserApi().updateWithdrawEmailPhone(withdrawId, email, phone);
      state = state.copyWith(updatingWithdrawId: null);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(updatingWithdrawId: null, error: e.toString());
      return false;
    }
  }
}

final withdrawControllerProvider =
    NotifierProvider<WithdrawController, WithdrawState>(WithdrawController.new);
