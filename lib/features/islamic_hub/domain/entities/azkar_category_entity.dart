import 'package:equatable/equatable.dart';

class AzkarItemEntity extends Equatable {
  final String id;
  final String text;
  final int count;
  final String? reward;
  final String? reference;
  final int currentCount;
  final bool isCompleted;

  const AzkarItemEntity({
    required this.id,
    required this.text,
    required this.count,
    this.reward,
    this.reference,
    this.currentCount = 0,
    this.isCompleted = false,
  });

  AzkarItemEntity copyWith({
    String? id,
    String? text,
    int? count,
    String? reward,
    String? reference,
    int? currentCount,
    bool? isCompleted,
  }) {
    return AzkarItemEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      count: count ?? this.count,
      reward: reward ?? this.reward,
      reference: reference ?? this.reference,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, text, count, reward, reference, currentCount, isCompleted];
}

class AzkarCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final int rewardCoins;
  final List<AzkarItemEntity> items;
  final int dailyClaimsToday;

  const AzkarCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.rewardCoins,
    required this.items,
    this.dailyClaimsToday = 0,
  });

  int get maxDailyClaims => id == 'after_prayer' ? 5 : 1;

  bool get isFullyClaimedToday => dailyClaimsToday >= maxDailyClaims;

  int get remainingClaimsToday => (maxDailyClaims - dailyClaimsToday).clamp(0, maxDailyClaims);

  bool get isCompleted => items.isNotEmpty && items.every((i) => i.isCompleted);

  int get totalCompletedItems => items.where((i) => i.isCompleted).length;

  double get progressPercentage => items.isEmpty ? 0.0 : totalCompletedItems / items.length;

  AzkarCategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    int? rewardCoins,
    List<AzkarItemEntity>? items,
    int? dailyClaimsToday,
  }) {
    return AzkarCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      items: items ?? this.items,
      dailyClaimsToday: dailyClaimsToday ?? this.dailyClaimsToday,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, colorValue, rewardCoins, items, dailyClaimsToday];
}
