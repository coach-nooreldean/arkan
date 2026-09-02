import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/sound_effects_service.dart';
import '../../domain/entities/arkan_coin_transaction.dart';
import '../../domain/entities/arkan_achievement.dart';
import '../../domain/repositories/arkan_coins_repository.dart';
import 'arkan_coins_state.dart';

class ArkanCoinsCubit extends Cubit<ArkanCoinsState> {
  final ArkanCoinsRepository _repository;

  ArkanCoinsCubit({required ArkanCoinsRepository repository})
      : _repository = repository,
        super(const ArkanCoinsState());

  Future<void> loadCoinsData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final balance = await _repository.getBalance();
      final achievements = await _repository.getAchievements();
      final transactions = await _repository.getTransactions();

      emit(state.copyWith(
        totalCoins: balance,
        achievements: achievements,
        transactions: transactions,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> awardCoins({
    required int amount,
    required String title,
    String? subtitle,
    required ArkanCoinSource source,
    bool isFajrPrayer = false,
    int tasbihCount = 1,
  }) async {
    if (amount <= 0) return;

    try {
      // 1. Add coins & transaction
      await _repository.addCoins(
        amount: amount,
        title: title,
        subtitle: subtitle,
        source: source,
      );

      // 2. Play crystalline coin sound & haptics
      SoundEffectsService.instance.playCoinEarned();

      final recentTx = ArkanCoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        title: title,
        subtitle: subtitle,
        source: source,
        timestamp: DateTime.now(),
      );

      // 3. Update achievements progress depending on source
      List<ArkanAchievement> currentAchievements = state.achievements;
      ArkanAchievement? newUnlocked;

      if (source == ArkanCoinSource.prayerOnTime) {
        currentAchievements = await _repository.recordProgress(
          achievementId: 'prayers_on_time_25',
          incrementBy: 1,
        );
        if (isFajrPrayer) {
          currentAchievements = await _repository.recordProgress(
            achievementId: 'fajr_hero',
            incrementBy: 1,
          );
        }
      } else if (source == ArkanCoinSource.azkar) {
        currentAchievements = await _repository.recordProgress(
          achievementId: 'azkar_master_10',
          incrementBy: 1,
        );
      } else if (source == ArkanCoinSource.tasbih) {
        currentAchievements = await _repository.recordProgress(
          achievementId: 'tasbih_500',
          incrementBy: tasbihCount,
        );
      } else if (source == ArkanCoinSource.quranWird) {
        currentAchievements = await _repository.recordProgress(
          achievementId: 'quran_wird_7',
          incrementBy: 1,
        );
      } else if (source == ArkanCoinSource.khatmah) {
        currentAchievements = await _repository.recordProgress(
          achievementId: 'khatmah_complete',
          incrementBy: 1,
        );
      }

      // Check if any achievement was unlocked in this step
      final previouslyUnlocked = {
        for (var a in state.achievements)
          if (a.isUnlocked) a.id
      };
      for (final a in currentAchievements) {
        if (a.isUnlocked && !previouslyUnlocked.contains(a.id)) {
          newUnlocked = a;
          SoundEffectsService.instance.playStreakUp();
          break;
        }
      }

      final updatedTransactions = await _repository.getTransactions();
      final freshBalance = await _repository.getBalance();

      emit(state.copyWith(
        totalCoins: freshBalance,
        achievements: currentAchievements,
        transactions: updatedTransactions,
        recentRewardEvent: recentTx,
        newlyUnlockedAchievement: newUnlocked,
      ));
    } catch (_) {
      // Graceful fallback
    }
  }

  void clearRecentReward() {
    emit(state.copyWith(clearRecentReward: true));
  }

  void clearNewlyUnlockedAchievement() {
    emit(state.copyWith(clearUnlockedAchievement: true));
  }
}
