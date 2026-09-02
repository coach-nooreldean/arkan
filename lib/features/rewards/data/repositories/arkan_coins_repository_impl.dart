import 'package:uuid/uuid.dart';
import '../../domain/entities/arkan_coin_transaction.dart';
import '../../domain/entities/arkan_achievement.dart';
import '../../domain/repositories/arkan_coins_repository.dart';
import '../datasources/arkan_coins_local_datasource.dart';

class ArkanCoinsRepositoryImpl implements ArkanCoinsRepository {
  final ArkanCoinsLocalDatasource _datasource;
  final Uuid _uuid = const Uuid();

  ArkanCoinsRepositoryImpl({ArkanCoinsLocalDatasource? datasource})
      : _datasource = datasource ?? ArkanCoinsLocalDatasource();

  @override
  Future<int> getBalance() => _datasource.getCoinsBalance();

  @override
  Future<int> addCoins({
    required int amount,
    required String title,
    String? subtitle,
    required ArkanCoinSource source,
  }) async {
    final current = await _datasource.getCoinsBalance();
    final newBalance = (current + amount).clamp(0, 9999999);
    await _datasource.saveCoinsBalance(newBalance);

    final tx = ArkanCoinTransaction(
      id: _uuid.v4(),
      amount: amount,
      title: title,
      subtitle: subtitle,
      source: source,
      timestamp: DateTime.now(),
    );
    await _datasource.addTransaction(tx);

    return newBalance;
  }

  @override
  Future<List<ArkanCoinTransaction>> getTransactions() =>
      _datasource.getTransactions();

  @override
  Future<List<ArkanAchievement>> getAchievements() =>
      _datasource.getAchievements();

  @override
  Future<List<ArkanAchievement>> recordProgress({
    required String achievementId,
    int incrementBy = 1,
  }) async {
    final list = await _datasource.getAchievements();
    final updatedList = <ArkanAchievement>[];

    for (final item in list) {
      if (item.id == achievementId && !item.isUnlocked) {
        final newProgress = (item.currentProgress + incrementBy).clamp(0, item.target);
        final isNowUnlocked = newProgress >= item.target;
        final updated = item.copyWith(
          currentProgress: newProgress,
          isUnlocked: isNowUnlocked,
          unlockedAt: isNowUnlocked ? DateTime.now() : null,
        );

        if (isNowUnlocked) {
          // Award achievement bonus coins!
          await addCoins(
            amount: item.rewardCoins,
            title: 'إنجاز شارة: ${item.title}',
            subtitle: item.description,
            source: ArkanCoinSource.manual,
          );
        }

        updatedList.add(updated);
      } else {
        updatedList.add(item);
      }
    }

    await _datasource.saveAchievements(updatedList);
    return updatedList;
  }
}
