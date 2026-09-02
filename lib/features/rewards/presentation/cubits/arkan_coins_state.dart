import '../../domain/entities/arkan_coin_transaction.dart';
import '../../domain/entities/arkan_achievement.dart';

class ArkanCoinsState {
  final int totalCoins;
  final List<ArkanAchievement> achievements;
  final List<ArkanCoinTransaction> transactions;
  final bool isLoading;
  final ArkanCoinTransaction? recentRewardEvent;
  final ArkanAchievement? newlyUnlockedAchievement;

  const ArkanCoinsState({
    this.totalCoins = 0,
    this.achievements = const [],
    this.transactions = const [],
    this.isLoading = false,
    this.recentRewardEvent,
    this.newlyUnlockedAchievement,
  });

  /// Spiritual rank based on accumulated coins
  String get rankTitle {
    if (totalCoins >= 1000) return 'سابق بالخيرات 🌟';
    if (totalCoins >= 500) return 'أوّاب منيب 🌙';
    if (totalCoins >= 250) return 'ذاكر لله كثيراً 📿';
    if (totalCoins >= 100) return 'حريص على الطاعات 🕌';
    if (totalCoins >= 30) return 'ساعٍ في الخير 🌱';
    return 'مبتدئ في العبادات ✨';
  }

  int get rankTier {
    if (totalCoins >= 1000) return 6;
    if (totalCoins >= 500) return 5;
    if (totalCoins >= 250) return 4;
    if (totalCoins >= 100) return 3;
    if (totalCoins >= 30) return 2;
    return 1;
  }

  int get unlockedAchievementsCount =>
      achievements.where((a) => a.isUnlocked).length;

  ArkanCoinsState copyWith({
    int? totalCoins,
    List<ArkanAchievement>? achievements,
    List<ArkanCoinTransaction>? transactions,
    bool? isLoading,
    ArkanCoinTransaction? recentRewardEvent,
    bool clearRecentReward = false,
    ArkanAchievement? newlyUnlockedAchievement,
    bool clearUnlockedAchievement = false,
  }) {
    return ArkanCoinsState(
      totalCoins: totalCoins ?? this.totalCoins,
      achievements: achievements ?? this.achievements,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      recentRewardEvent: clearRecentReward
          ? null
          : (recentRewardEvent ?? this.recentRewardEvent),
      newlyUnlockedAchievement: clearUnlockedAchievement
          ? null
          : (newlyUnlockedAchievement ?? this.newlyUnlockedAchievement),
    );
  }
}
