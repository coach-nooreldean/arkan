import 'package:equatable/equatable.dart';

class PrayerLogEntity extends Equatable {
  final String id;
  final String userId;
  final String prayerName;
  final DateTime prayerDate;
  final bool isOnTime;
  final int coinsEarned;
  final DateTime createdAt;

  const PrayerLogEntity({
    required this.id,
    required this.userId,
    required this.prayerName,
    required this.prayerDate,
    required this.isOnTime,
    required this.coinsEarned,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        prayerName,
        prayerDate,
        isOnTime,
        coinsEarned,
        createdAt,
      ];
}
