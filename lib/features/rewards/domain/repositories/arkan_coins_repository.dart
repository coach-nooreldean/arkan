import '../entities/arkan_coin_transaction.dart';
import '../entities/arkan_achievement.dart';

abstract class ArkanCoinsRepository {
  Future<int> getBalance();
  Future<int> addCoins({
    required int amount,
    required String title,
    String? subtitle,
    required ArkanCoinSource source,
  });
  Future<List<ArkanCoinTransaction>> getTransactions();
  Future<List<ArkanAchievement>> getAchievements();
  Future<List<ArkanAchievement>> recordProgress({
    required String achievementId,
    int incrementBy = 1,
  });
}
