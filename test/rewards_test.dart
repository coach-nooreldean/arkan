import 'package:flutter_test/flutter_test.dart';
import 'package:arkan/features/rewards/domain/entities/arkan_coin_transaction.dart';
import 'package:arkan/features/rewards/domain/entities/arkan_achievement.dart';
import 'package:arkan/features/rewards/presentation/cubits/arkan_coins_state.dart';

void main() {
  group('Arkan Rewards & Coins System Tests', () {
    test('ArkanCoinsState calculates rank titles correctly based on coin tiers', () {
      const state0 = ArkanCoinsState(totalCoins: 0);
      expect(state0.rankTitle, contains('مبتدئ'));

      const state45 = ArkanCoinsState(totalCoins: 45);
      expect(state45.rankTitle, contains('ساعٍ في الخير'));

      const state150 = ArkanCoinsState(totalCoins: 150);
      expect(state150.rankTitle, contains('حريص على الطاعات'));

      const state300 = ArkanCoinsState(totalCoins: 300);
      expect(state300.rankTitle, contains('ذاكر لله كثيراً'));

      const state600 = ArkanCoinsState(totalCoins: 600);
      expect(state600.rankTitle, contains('أوّاب منيب'));

      const state1200 = ArkanCoinsState(totalCoins: 1200);
      expect(state1200.rankTitle, contains('سابق بالخيرات'));
    });

    test('ArkanAchievement progress and unlock calculation', () {
      const achievement = ArkanAchievement(
        id: 'fajr_hero',
        title: 'فجر الأبرار',
        description: 'المحافظة على صلاة الفجر 7 مرات',
        iconEmoji: '🌅',
        target: 7,
        currentProgress: 3,
        rewardCoins: 25,
      );

      expect(achievement.isUnlocked, isFalse);
      expect(achievement.progressPercentage, closeTo(3 / 7, 0.01));

      final updated = achievement.copyWith(
        currentProgress: 7,
        isUnlocked: true,
      );
      expect(updated.isUnlocked, isTrue);
      expect(updated.progressPercentage, equals(1.0));
    });

    test('ArkanCoinTransaction json serialization test', () {
      final tx = ArkanCoinTransaction(
        id: 'tx_123',
        amount: 5,
        title: 'صلاة الفجر في وقتها',
        subtitle: 'المحافظة على الصلاة المكتوبة',
        source: ArkanCoinSource.prayerOnTime,
        timestamp: DateTime(2026, 9, 2, 5, 0),
      );

      final json = tx.toJson();
      expect(json['id'], equals('tx_123'));
      expect(json['amount'], equals(5));
      expect(json['source'], equals('prayerOnTime'));

      final fromJson = ArkanCoinTransaction.fromJson(json);
      expect(fromJson.id, equals('tx_123'));
      expect(fromJson.amount, equals(5));
      expect(fromJson.source, equals(ArkanCoinSource.prayerOnTime));
    });
  });
}
