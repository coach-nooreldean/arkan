import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/quran_khatmah_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

class KhatmahState extends Equatable {
  final List<QuranKhatmahEntity> khatmahs;
  final QuranKhatmahEntity? activeKhatmah;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const KhatmahState({
    this.khatmahs = const [],
    this.activeKhatmah,
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  KhatmahState copyWith({
    List<QuranKhatmahEntity>? khatmahs,
    QuranKhatmahEntity? activeKhatmah,
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    bool clearActiveKhatmah = false,
    bool clearMessages = false,
  }) {
    return KhatmahState(
      khatmahs: khatmahs ?? this.khatmahs,
      activeKhatmah: clearActiveKhatmah ? null : (activeKhatmah ?? this.activeKhatmah),
      isLoading: isLoading ?? this.isLoading,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [khatmahs, activeKhatmah, isLoading, successMessage, errorMessage];
}

class KhatmahCubit extends Cubit<KhatmahState> {
  final IslamicHubRepository _repository;

  KhatmahCubit({required IslamicHubRepository repository})
      : _repository = repository,
        super(const KhatmahState()) {
    loadKhatmahs();
  }

  Future<void> loadKhatmahs() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final list = await _repository.getKhatmahs();
      final active = list.where((k) => !k.isCompleted).firstOrNull ?? list.firstOrNull;
      emit(state.copyWith(
        khatmahs: list,
        activeKhatmah: active,
        clearActiveKhatmah: active == null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'فشل تحميل الختمات: $e'));
    }
  }

  Future<void> createKhatmah({
    required String title,
    int targetDays = 30,
    int startPage = 1,
    int endPage = 604,
  }) async {
    try {
      final newKhatmah = QuranKhatmahEntity(
        id: const Uuid().v4(),
        title: title.trim().isNotEmpty ? title.trim() : 'ختمة القرآن الكريم',
        targetDays: targetDays > 0 ? targetDays : 30,
        startDate: DateTime.now(),
        startPage: startPage,
        endPage: endPage,
        currentPage: startPage,
        pagesReadToday: 0,
        isCompleted: false,
      );

      await _repository.saveKhatmah(newKhatmah);
      await loadKhatmahs();
      emit(state.copyWith(successMessage: 'تم إنشاء الختمة بنجاح! وفقك الله لإتمامها 🤲'));
    } catch (e) {
      AppLogger.error('Create khatmah error: $e');
      emit(state.copyWith(errorMessage: 'تعذر إنشاء الختمة: $e'));
    }
  }

  DateTime? _lastPageTurnTime;

  Future<void> updateCurrentPage(int page, {String? userId}) async {
    final active = state.activeKhatmah;
    if (active == null || active.isCompleted) return;

    // Strict Anti-Cheating Rule with Dual-Page Support:
    // User moves from active.currentPage forward by 1 page (single mode) or 2 pages (dual spread mode).
    // Any large jumps (searching, browsing surahs, jumping elsewhere) do NOT count as reading pages!
    final delta = page - active.currentPage;
    if (delta < 1 || delta > 2) {
      return;
    }

    final now = DateTime.now();
    // Anti-rapid-swipe protection (must spend at least 1.5 seconds on a page to count)
    if (_lastPageTurnTime != null && now.difference(_lastPageTurnTime!).inMilliseconds < 1500) {
      return;
    }
    _lastPageTurnTime = now;

    final today = DateTime.now();
    final isSameDay = active.lastReadDate != null &&
        active.lastReadDate!.year == today.year &&
        active.lastReadDate!.month == today.month &&
        active.lastReadDate!.day == today.day;

    final newPagesToday = isSameDay ? (active.pagesReadToday + delta) : delta;
    final isCompleted = page >= active.endPage;
    final rewardClaimed = isSameDay ? active.isRewardClaimedToday : false;

    bool shouldAwardReward = false;
    if (newPagesToday >= active.pagesPerDay && !rewardClaimed) {
      shouldAwardReward = true;
    }

    final updated = active.copyWith(
      currentPage: page.clamp(active.startPage, active.endPage),
      lastReadDate: today,
      pagesReadToday: newPagesToday,
      isCompleted: isCompleted,
      isRewardClaimedToday: shouldAwardReward ? true : rewardClaimed,
    );

    await _repository.saveKhatmah(updated);

    if (shouldAwardReward) {
      emit(state.copyWith(
        activeKhatmah: updated,
        successMessage: '🎉 مبارك! تقبل الله منك، أتممت ورد اليوم من القرآن الكريم بنجاح 📖',
      ));
    }

    await loadKhatmahs();
  }

  Future<void> setKhatmahBookmarkPage(int page) async {
    final active = state.activeKhatmah;
    if (active == null) return;
    final updated = active.copyWith(currentPage: page.clamp(active.startPage, active.endPage));
    await _repository.saveKhatmah(updated);
    await loadKhatmahs();
  }

  Future<void> claimManualWardReward({String? userId}) async {
    final active = state.activeKhatmah;
    if (active == null) return;
    if (active.isRewardClaimedToday) {
      emit(state.copyWith(successMessage: 'لقد حصلت بالفعل على مكافأة ورد اليوم 🪙'));
      return;
    }

    final today = DateTime.now();
    final updated = active.copyWith(
      lastReadDate: today,
      pagesReadToday: active.pagesPerDay,
      isRewardClaimedToday: true,
    );
    await _repository.saveKhatmah(updated);

    emit(state.copyWith(
      activeKhatmah: updated,
      successMessage: '🎉 تقبل الله طاعتكم، تم تسجيل إتمام ورد اليوم بنجاح 📖',
    ));
    await loadKhatmahs();
  }

  Future<void> deleteKhatmah(String id) async {
    try {
      await _repository.deleteKhatmah(id);
      final list = await _repository.getKhatmahs();
      final active = list.where((k) => !k.isCompleted).firstOrNull ?? list.firstOrNull;
      emit(state.copyWith(
        khatmahs: list,
        activeKhatmah: active,
        clearActiveKhatmah: active == null,
        successMessage: 'تم حذف الختمة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل حذف الختمة: $e'));
    }
  }
}
