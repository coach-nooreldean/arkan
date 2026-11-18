import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/azkar_category_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

class AzkarState extends Equatable {
  final List<AzkarCategoryEntity> categories;
  final AzkarCategoryEntity? selectedCategory;
  final bool isLoading;
  final int earnedCoinsLastAction;
  final String? completionCelebrationCategory;

  const AzkarState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.earnedCoinsLastAction = 0,
    this.completionCelebrationCategory,
  });

  AzkarState copyWith({
    List<AzkarCategoryEntity>? categories,
    AzkarCategoryEntity? selectedCategory,
    bool? isLoading,
    int? earnedCoinsLastAction,
    String? completionCelebrationCategory,
    bool clearCelebration = false,
  }) {
    return AzkarState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      earnedCoinsLastAction: earnedCoinsLastAction ?? this.earnedCoinsLastAction,
      completionCelebrationCategory: clearCelebration
          ? null
          : (completionCelebrationCategory ?? this.completionCelebrationCategory),
    );
  }

  @override
  List<Object?> get props => [
        categories,
        selectedCategory,
        isLoading,
        earnedCoinsLastAction,
        completionCelebrationCategory,
      ];
}

class AzkarCubit extends Cubit<AzkarState> {
  final IslamicHubRepository _repository;

  AzkarCubit({required IslamicHubRepository repository})
      : _repository = repository,
        super(const AzkarState()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true));
    final list = await _repository.getAllAzkarCategories();
    emit(state.copyWith(categories: list, isLoading: false));
  }

  void selectCategory(String categoryId) {
    final cat = state.categories.where((c) => c.id == categoryId).firstOrNull;
    emit(state.copyWith(selectedCategory: cat, clearCelebration: true));
  }

  /// Builds a virtual category containing all currently favorited Azkar items.
  AzkarCategoryEntity buildFavoritesCategory(List<String> favoriteIds) {
    final favSet = favoriteIds.toSet();
    final matchedItems = <AzkarItemEntity>[];
    final seen = <String>{};
    for (final cat in state.categories) {
      for (final item in cat.items) {
        if (favSet.contains(item.id) && seen.add(item.id)) {
          matchedItems.add(item);
        }
      }
    }
    return AzkarCategoryEntity(
      id: 'favorites',
      name: 'أذكاري المفضلة',
      icon: 'heart-circle',
      colorValue: 0xFFE11D48,
      rewardCoins: 3,
      items: matchedItems,
    );
  }

  void selectFavoritesCategory(List<String> favoriteIds) {
    emit(state.copyWith(
      selectedCategory: buildFavoritesCategory(favoriteIds),
      clearCelebration: true,
    ));
  }

  Future<void> incrementItemCount({
    required String itemId,
    String? userId,
  }) async {
    final currentCat = state.selectedCategory;
    if (currentCat == null) return;

    bool justCompletedAll = false;

    final updatedItems = currentCat.items.map((item) {
      if (item.id == itemId && !item.isCompleted) {
        final nextCount = item.currentCount + 1;
        final isNowCompleted = nextCount >= item.count;

        if (isNowCompleted) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }

        return item.copyWith(
          currentCount: nextCount,
          isCompleted: isNowCompleted,
        );
      }
      return item;
    }).toList();

    final updatedCat = currentCat.copyWith(items: updatedItems);

    final updatedCategories = state.categories.map((c) {
      if (c.id == currentCat.id) {
        return updatedCat;
      }
      if (currentCat.id == 'favorites' &&
          c.items.any((existing) => existing.id == itemId)) {
        final syncedItems = c.items.map((existing) {
          if (existing.id == itemId) {
            return updatedItems.firstWhere(
              (u) => u.id == itemId,
              orElse: () => existing,
            );
          }
          return existing;
        }).toList();
        return c.copyWith(items: syncedItems);
      }
      return c;
    }).toList();

    // Check if category is now 100% completed
    if (updatedCat.isCompleted && !currentCat.isCompleted) {
      justCompletedAll = true;
      HapticFeedback.heavyImpact();
    }

    emit(state.copyWith(
      categories: updatedCategories,
      selectedCategory: updatedCat,
      completionCelebrationCategory: justCompletedAll ? updatedCat.name : null,
    ));

    // Claim reward if completed and user logged in
    if (justCompletedAll &&
        updatedCat.id != 'favorites' &&
        userId != null &&
        userId.isNotEmpty) {
      final rewardResult = await _repository.claimAzkarReward(userId, updatedCat.id);
      await rewardResult.fold(
        (_) async {},
        (coins) async {
          emit(state.copyWith(earnedCoinsLastAction: coins));
          final freshCategories = await _repository.getAllAzkarCategories();
          final freshSelected = freshCategories.where((c) => c.id == updatedCat.id).firstOrNull;
          emit(state.copyWith(
            categories: freshCategories,
            selectedCategory: freshSelected ?? updatedCat,
          ));
        },
      );
    }
  }

  void resetCategoryProgress(String categoryId) {
    if (categoryId == 'favorites') {
      final currentSelected = state.selectedCategory;
      if (currentSelected != null && currentSelected.id == 'favorites') {
        final resetItems = currentSelected.items
            .map((i) => i.copyWith(currentCount: 0, isCompleted: false))
            .toList();
        emit(state.copyWith(
          selectedCategory: currentSelected.copyWith(items: resetItems),
          clearCelebration: true,
        ));
      }
      return;
    }

    final updatedCategories = state.categories.map((cat) {
      if (cat.id == categoryId) {
        final resetItems = cat.items.map((i) => i.copyWith(currentCount: 0, isCompleted: false)).toList();
        return cat.copyWith(items: resetItems);
      }
      return cat;
    }).toList();

    final selected = updatedCategories.where((c) => c.id == categoryId).firstOrNull;
    emit(state.copyWith(categories: updatedCategories, selectedCategory: selected, clearCelebration: true));
  }

  void clearCelebration() {
    emit(state.copyWith(clearCelebration: true));
  }
}
