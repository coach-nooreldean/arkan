enum ArkanCoinSource {
  prayerOnTime,
  prayerLate,
  azkar,
  tasbih,
  quranWird,
  khatmah,
  streakBonus,
  manual,
}

class ArkanCoinTransaction {
  final String id;
  final int amount;
  final String title;
  final String? subtitle;
  final ArkanCoinSource source;
  final DateTime timestamp;

  const ArkanCoinTransaction({
    required this.id,
    required this.amount,
    required this.title,
    this.subtitle,
    required this.source,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'title': title,
        'subtitle': subtitle,
        'source': source.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ArkanCoinTransaction.fromJson(Map<String, dynamic> json) {
    return ArkanCoinTransaction(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      source: ArkanCoinSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ArkanCoinSource.manual,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
