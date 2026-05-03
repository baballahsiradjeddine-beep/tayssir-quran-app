import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/features/leaderboard/data/leaderboard_repository.dart';
import 'package:tayssir/features/leaderboard/state/leaderboard_state.dart';
import 'package:tayssir/features/onboarding/onboarding_notifier.dart';
import 'package:tayssir/providers/user/user_notifier.dart';
import '../../../exceptions/app_exception.dart';

class LeaderboardController extends StateNotifier<LeaderboardState> {
  final LeaderboardRepository _leaderboardRepository;
  final Ref ref;

  LeaderboardController(this._leaderboardRepository, this.ref)
      : super(LeaderboardState.initial()) {
    getLeaderboard();
  }

  /// Returns the division_id to filter the leaderboard.
  int? get _guestDivisionId {
    final user = ref.read(userNotifierProvider).valueOrNull;
    if (user != null) return null;
    return ref.read(onboardingProvider).divisionId;
  }

  Future<void> getLeaderboard({String? type}) async {
    if (type != null && type != state.type) {
      state = state.copyWith(type: type);
    }
    state = state.setIsLoading();
    try {
      final data = await _leaderboardRepository.getLeaderboard(
        divisionId: _guestDivisionId,
        type: state.type,
      );
      state = state.copyWithData(
        data.data, 
        totalPages: data.totalPages, 
        userRank: data.userRank
      );
    } catch (e) {
      state = state
          .copyWithError(AppException.fromDartException(e, StackTrace.current));
    }
  }

  Future<void> fetchMoreLeaderboard() async {
    if (state.isFetchingMore) return;
    if (!state.canLoadMore) return;
    if (!state.hasData) return;
    state = state.setIsFetchingMore(true);
    try {
      final newData = await _leaderboardRepository.getLeaderboard(
        page: state.page + 1,
        divisionId: _guestDivisionId,
        type: state.type,
      );
      state = state.joinData(newData.data, userRank: newData.userRank);
    } catch (e) {
      state = state
          .copyWithError(AppException.fromDartException(e, StackTrace.current));
    } finally {
      state = state.setIsFetchingMore(false);
    }
  }
  
  void changeType(int index) {
     final types = ['daily', 'weekly', 'global'];
     final newType = index < types.length ? types[index] : 'global';
     if (newType != state.type) {
       getLeaderboard(type: newType);
     }
  }
}

final leaderboardControllerProvider =
    StateNotifierProvider<LeaderboardController, LeaderboardState>(
  (ref) => LeaderboardController(ref.watch(leaderboardRepositoryProvider), ref),
);
