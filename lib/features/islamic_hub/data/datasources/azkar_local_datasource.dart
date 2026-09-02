import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/azkar_category_entity.dart';
import '../../domain/entities/tasbih_item_entity.dart';

abstract class AzkarLocalDataSource {
  Future<List<AzkarCategoryEntity>> loadAzkarCategories({DateTime? date});
  Future<List<TasbihItemEntity>> loadDefaultTasbihPhrases();
  Future<Map<String, int>> getDailyAzkarClaimCounts(DateTime date);
  Future<void> recordAzkarClaim(String categoryId, DateTime date);
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  static const String _keyClaimsPrefix = 'islamic_azkar_claims_';

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Future<Map<String, int>> getDailyAzkarClaimCounts(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyClaimsPrefix${_formatDate(date)}';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return {};

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (e) {
      AppLogger.warning('Error reading daily azkar claims: $e');
      return {};
    }
  }

  @override
  Future<void> recordAzkarClaim(String categoryId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyClaimsPrefix${_formatDate(date)}';
      final currentMap = await getDailyAzkarClaimCounts(date);

      currentMap[categoryId] = (currentMap[categoryId] ?? 0) + 1;
      await prefs.setString(key, jsonEncode(currentMap));
    } catch (e) {
      AppLogger.warning('Error recording azkar claim: $e');
    }
  }

  @override
  Future<List<AzkarCategoryEntity>> loadAzkarCategories({DateTime? date}) async {
    try {
      final effectiveDate = date ?? DateTime.now();
      final claimsMap = await getDailyAzkarClaimCounts(effectiveDate);

      final jsonString = await rootBundle.loadString('assets/data/azkar.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['categories'] as List<dynamic>? ?? [];

      return list.map((catJson) {
        final catMap = catJson as Map<String, dynamic>;
        final itemsList = catMap['items'] as List<dynamic>? ?? [];

        final items = itemsList.map((itemJson) {
          final itemMap = itemJson as Map<String, dynamic>;
          return AzkarItemEntity(
            id: itemMap['id'] as String,
            text: itemMap['text'] as String,
            count: itemMap['count'] as int? ?? 1,
            reward: itemMap['reward'] as String?,
            reference: itemMap['reference'] as String?,
            currentCount: 0,
            isCompleted: false,
          );
        }).toList();

        final colorHex = int.tryParse(catMap['color'] as String? ?? '0xFF3551AE') ?? 0xFF3551AE;
        final catId = catMap['id'] as String;
        final claimsCount = claimsMap[catId] ?? 0;

        return AzkarCategoryEntity(
          id: catId,
          name: catMap['name'] as String,
          icon: catMap['icon'] as String? ?? 'book',
          colorValue: colorHex,
          rewardCoins: catMap['reward_coins'] as int? ?? 1,
          items: items,
          dailyClaimsToday: claimsCount,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to load Azkar categories from assets: $e');
      return [];
    }
  }

  @override
  Future<List<TasbihItemEntity>> loadDefaultTasbihPhrases() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/default_tasbih.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['phrases'] as List<dynamic>? ?? [];

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return TasbihItemEntity(
          id: map['id'] as String,
          text: map['text'] as String,
          target: map['target'] as int? ?? 33,
          reward: map['reward'] as String?,
          currentCount: 0,
          totalAllTimeCount: 0,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to load default tasbih phrases: $e');
      return [];
    }
  }
}
