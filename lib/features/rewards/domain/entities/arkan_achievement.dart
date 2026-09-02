class ArkanAchievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int target;
  final int currentProgress;
  final int rewardCoins;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const ArkanAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.target,
    required this.currentProgress,
    required this.rewardCoins,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage => (currentProgress / target).clamp(0.0, 1.0);

  ArkanAchievement copyWith({
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return ArkanAchievement(
      id: id,
      title: title,
      description: description,
      iconEmoji: iconEmoji,
      target: target,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardCoins: rewardCoins,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon_emoji': iconEmoji,
        'target': target,
        'current_progress': currentProgress,
        'reward_coins': rewardCoins,
        'is_unlocked': isUnlocked,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };

  factory ArkanAchievement.fromJson(Map<String, dynamic> json) {
    return ArkanAchievement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconEmoji: json['icon_emoji'] as String? ?? '🏆',
      target: json['target'] as int? ?? 1,
      currentProgress: json['current_progress'] as int? ?? 0,
      rewardCoins: json['reward_coins'] as int? ?? 10,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
    );
  }
}
