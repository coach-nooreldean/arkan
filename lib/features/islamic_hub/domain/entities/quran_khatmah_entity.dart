import 'package:equatable/equatable.dart';

class QuranKhatmahEntity extends Equatable {
  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final int startPage;
  final int endPage;
  final int currentPage;
  final DateTime? lastReadDate;
  final int pagesReadToday;
  final bool isCompleted;
  final bool isRewardClaimedToday;

  const QuranKhatmahEntity({
    required this.id,
    required this.title,
    this.targetDays = 30,
    required this.startDate,
    this.startPage = 1,
    this.endPage = 604,
    this.currentPage = 1,
    this.lastReadDate,
    this.pagesReadToday = 0,
    this.isCompleted = false,
    this.isRewardClaimedToday = false,
  });

  int get totalPages => (endPage - startPage + 1).clamp(1, 604);
  int get pagesReadTotal => (currentPage - startPage).clamp(0, totalPages);
  int get pagesPerDay => (totalPages / (targetDays > 0 ? targetDays : 1)).ceil();
  double get progressPercentage => (pagesReadTotal / totalPages).clamp(0.0, 1.0);
  int get daysElapsed => DateTime.now().difference(startDate).inDays + 1;
  int get daysRemaining => (targetDays - daysElapsed).clamp(0, targetDays);
  int get remainingPagesToday => (pagesPerDay - pagesReadToday).clamp(0, pagesPerDay);

  QuranKhatmahEntity copyWith({
    String? id,
    String? title,
    int? targetDays,
    DateTime? startDate,
    int? startPage,
    int? endPage,
    int? currentPage,
    DateTime? lastReadDate,
    int? pagesReadToday,
    bool? isCompleted,
    bool? isRewardClaimedToday,
  }) {
    return QuranKhatmahEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      currentPage: currentPage ?? this.currentPage,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      pagesReadToday: pagesReadToday ?? this.pagesReadToday,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimedToday: isRewardClaimedToday ?? this.isRewardClaimedToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'startPage': startPage,
      'endPage': endPage,
      'currentPage': currentPage,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'pagesReadToday': pagesReadToday,
      'isCompleted': isCompleted,
      'isRewardClaimedToday': isRewardClaimedToday,
    };
  }

  factory QuranKhatmahEntity.fromJson(Map<String, dynamic> json) {
    return QuranKhatmahEntity(
      id: json['id'] as String? ?? 'khatmah_1',
      title: json['title'] as String? ?? 'ختمتي',
      targetDays: json['targetDays'] as int? ?? 30,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      startPage: json['startPage'] as int? ?? 1,
      endPage: json['endPage'] as int? ?? 604,
      currentPage: json['currentPage'] as int? ?? 1,
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.tryParse(json['lastReadDate'] as String)
          : null,
      pagesReadToday: json['pagesReadToday'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isRewardClaimedToday: json['isRewardClaimedToday'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        targetDays,
        startDate,
        startPage,
        endPage,
        currentPage,
        lastReadDate,
        pagesReadToday,
        isCompleted,
        isRewardClaimedToday,
      ];
}
