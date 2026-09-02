import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/arkan_coin_transaction.dart';
import '../../domain/entities/arkan_achievement.dart';

class ArkanCoinsLocalDatasource {
  static const _kCoinsBalanceKey = 'arkan_coins_balance';
  static const _kTransactionsKey = 'arkan_coin_transactions_history';
  static const _kAchievementsKey = 'arkan_achievements_state';

  static final List<ArkanAchievement> _defaultAchievements = [
    const ArkanAchievement(
      id: 'fajr_hero',
      title: 'فجر الأبرار',
      description: 'المحافظة على صلاة الفجر في وقتها 7 مرات',
      iconEmoji: '🌅',
      target: 7,
      currentProgress: 0,
      rewardCoins: 25,
    ),
    const ArkanAchievement(
      id: 'prayers_on_time_25',
      title: 'عمّار المساجد',
      description: 'تسجيل 25 صلاة في وقتها المحدد',
      iconEmoji: '🕌',
      target: 25,
      currentProgress: 0,
      rewardCoins: 50,
    ),
    const ArkanAchievement(
      id: 'azkar_master_10',
      title: 'حصن المسلم',
      description: 'إتمام 10 أقسام من الأذكار اليومية',
      iconEmoji: '🛡️',
      target: 10,
      currentProgress: 0,
      rewardCoins: 30,
    ),
    const ArkanAchievement(
      id: 'tasbih_500',
      title: 'الذاكر الشاكر',
      description: 'تسبيح وذكر الله 500 مرة بالمسبحة الذكية',
      iconEmoji: '📿',
      target: 500,
      currentProgress: 0,
      rewardCoins: 20,
    ),
    const ArkanAchievement(
      id: 'quran_wird_7',
      title: 'صاحب القرآن',
      description: 'إتمام الورد القرآني لـ 7 أيام متتالية',
      iconEmoji: '📖',
      target: 7,
      currentProgress: 0,
      rewardCoins: 40,
    ),
    const ArkanAchievement(
      id: 'khatmah_complete',
      title: 'خاتم القرآن',
      description: 'إتمام ختمة كاملة لكتاب الله الكريم',
      iconEmoji: '👑',
      target: 1,
      currentProgress: 0,
      rewardCoins: 100,
    ),
  ];

  Future<int> getCoinsBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCoinsBalanceKey) ?? 0;
  }

  Future<void> saveCoinsBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCoinsBalanceKey, balance);
  }

  Future<List<ArkanCoinTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_kTransactionsKey);
    if (jsonList == null || jsonList.isEmpty) return [];

    return jsonList.map((str) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return ArkanCoinTransaction.fromJson(map);
      } catch (_) {
        return null;
      }
    }).whereType<ArkanCoinTransaction>().toList();
  }

  Future<void> addTransaction(ArkanCoinTransaction tx) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getTransactions();
    // Keep last 100 transactions
    final updated = [tx, ...existing].take(100).toList();
    final rawList = updated.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_kTransactionsKey, rawList);
  }

  Future<List<ArkanAchievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_kAchievementsKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _defaultAchievements;
    }

    try {
      final loaded = jsonList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return ArkanAchievement.fromJson(map);
      }).toList();

      // Merge with default if new achievements are added in updates
      final mapLoaded = {for (var a in loaded) a.id: a};
      return _defaultAchievements.map((def) {
        if (mapLoaded.containsKey(def.id)) {
          return mapLoaded[def.id]!;
        }
        return def;
      }).toList();
    } catch (_) {
      return _defaultAchievements;
    }
  }

  Future<void> saveAchievements(List<ArkanAchievement> list) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = list.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_kAchievementsKey, rawList);
  }
}
