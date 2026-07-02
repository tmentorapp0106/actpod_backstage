import 'package:actpod_studio/api/response/user_response/received_donation.dart';
import 'package:actpod_studio/api/user_system_api.dart';
import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class DonationState {
  final StatisticPeriod period;
  final StatisticTimeRange timeRange;
  final bool loading;
  final String? error;
  final List<ReceivedDonation> allDonations;
  final List<ReceivedDonation> donations;

  const DonationState({
    this.period = StatisticPeriod.day,
    required this.timeRange,
    this.loading = false,
    this.error,
    this.allDonations = const [],
    this.donations = const [],
  });

  factory DonationState.initial() {
    final period = StatisticPeriod.day;
    return DonationState(
      period: period,
      timeRange: period.rangeFor(DateTime.now()),
    );
  }

  int get totalReceivedPodCash {
    return donations.fold(0, (sum, item) => sum + item.receivedPodCash);
  }

  DonationState copyWith({
    StatisticPeriod? period,
    StatisticTimeRange? timeRange,
    bool? loading,
    Object? error = _unset,
    List<ReceivedDonation>? allDonations,
    List<ReceivedDonation>? donations,
  }) {
    return DonationState(
      period: period ?? this.period,
      timeRange: timeRange ?? this.timeRange,
      loading: loading ?? this.loading,
      error: error == _unset ? this.error : error as String?,
      allDonations: allDonations ?? this.allDonations,
      donations: donations ?? this.donations,
    );
  }
}

const _unset = Object();

class DonationController extends Notifier<DonationState> {
  @override
  DonationState build() => DonationState.initial();

  Future<void> changePeriod(StatisticPeriod period, String userId) async {
    if (period == StatisticPeriod.custom) return;
    final timeRange = period.rangeFor(DateTime.now());
    state = state.copyWith(period: period, timeRange: timeRange);

    if (state.allDonations.isEmpty) {
      await load(userId);
      return;
    }
    _applyFilter(timeRange);
  }

  Future<void> changeTimeRange(
    StatisticTimeRange timeRange,
    String userId,
  ) async {
    state = state.copyWith(
      period: StatisticPeriod.custom,
      timeRange: timeRange,
    );

    if (state.allDonations.isEmpty) {
      await load(userId);
      return;
    }
    _applyFilter(timeRange);
  }

  Future<void> load(String userId) async {
    if (userId.isEmpty || state.loading) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final response = await UserApi().getReceivedDonation(userId);
      final sorted = [...response.donations]
        ..sort((a, b) {
          final aTime = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      final timeRange = _activeTimeRange();
      state = state.copyWith(
        allDonations: sorted,
        donations: _filter(sorted, timeRange),
        timeRange: timeRange,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  StatisticTimeRange _activeTimeRange() {
    if (state.period == StatisticPeriod.custom) return state.timeRange;
    return state.period.rangeFor(DateTime.now());
  }

  void _applyFilter(StatisticTimeRange timeRange) {
    state = state.copyWith(
      donations: _filter(state.allDonations, timeRange),
      timeRange: timeRange,
    );
  }

  List<ReceivedDonation> _filter(
    List<ReceivedDonation> donations,
    StatisticTimeRange timeRange,
  ) {
    return [
      for (final donation in donations)
        if (donation.createTime != null &&
            timeRange.contains(donation.createTime!))
          donation,
    ];
  }
}

final donationControllerProvider =
    NotifierProvider<DonationController, DonationState>(DonationController.new);
