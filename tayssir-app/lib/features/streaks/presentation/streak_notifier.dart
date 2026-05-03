import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/features/streaks/data/streak_model.dart';
import 'package:tayssir/features/streaks/data/streak_repository.dart';
import 'package:tayssir/providers/user/user_notifier.dart';


class StreakNotifier extends StateNotifier<AsyncValue<StreakModel?>> {
  final StreakRepository _repository;
  final Ref ref;

  StreakNotifier(this._repository, this.ref) : super(const AsyncValue.loading()) {
    _fetchStreak();
  }

  Future<void> _fetchStreak() async {
    final user = ref.read(userNotifierProvider).valueOrNull;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final streak = await _repository.getStreakInfo();
      state = AsyncValue.data(streak);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<StreakModel?> pingStreak() async {
    try {
      final result = await _repository.pingStreak();
      if (result != null) {
        state = AsyncValue.data(result);
        return result;
      }
    } catch (e) {
      // Don't change state to error on ping failure so UI doesn't crash
    }
    return null;
  }
}

final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, AsyncValue<StreakModel?>>((ref) {
  final repo = ref.watch(streakRepositoryProvider);
  return StreakNotifier(repo, ref);
});
