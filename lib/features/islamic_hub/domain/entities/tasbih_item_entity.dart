import 'package:equatable/equatable.dart';

class TasbihItemEntity extends Equatable {
  final String id;
  final String text;
  final int target;
  final String? reward;
  final int currentCount;
  final int totalAllTimeCount;

  const TasbihItemEntity({
    required this.id,
    required this.text,
    required this.target,
    this.reward,
    this.currentCount = 0,
    this.totalAllTimeCount = 0,
  });

  TasbihItemEntity copyWith({
    String? id,
    String? text,
    int? target,
    String? reward,
    int? currentCount,
    int? totalAllTimeCount,
  }) {
    return TasbihItemEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      target: target ?? this.target,
      reward: reward ?? this.reward,
      currentCount: currentCount ?? this.currentCount,
      totalAllTimeCount: totalAllTimeCount ?? this.totalAllTimeCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        target,
        reward,
        currentCount,
        totalAllTimeCount,
      ];
}
