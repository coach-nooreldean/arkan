import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tasbih_item_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

class TasbihState extends Equatable {
  final List<TasbihItemEntity> items;
  final TasbihItemEntity? selectedItem;
  final bool isLoading;
  final bool enableVibration;
  final bool enableSound;
  final bool targetReachedCelebration;

  const TasbihState({
    this.items = const [],
    this.selectedItem,
    this.isLoading = false,
    this.enableVibration = true,
    this.enableSound = true,
    this.targetReachedCelebration = false,
  });

  TasbihState copyWith({
    List<TasbihItemEntity>? items,
    TasbihItemEntity? selectedItem,
    bool? isLoading,
    bool? enableVibration,
    bool? enableSound,
    bool? targetReachedCelebration,
  }) {
    return TasbihState(
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      isLoading: isLoading ?? this.isLoading,
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
      targetReachedCelebration: targetReachedCelebration ?? this.targetReachedCelebration,
    );
  }

  int get totalAllTimeCount => items.fold(0, (sum, i) => sum + i.totalAllTimeCount);

  @override
  List<Object?> get props => [
        items,
        selectedItem,
        isLoading,
        enableVibration,
        enableSound,
        targetReachedCelebration,
      ];
}

class TasbihCubit extends Cubit<TasbihState> {
  final IslamicHubRepository _repository;

  TasbihCubit({required IslamicHubRepository repository})
      : _repository = repository,
        super(const TasbihState()) {
    loadTasbih();
  }

  Future<void> loadTasbih() async {
    emit(state.copyWith(isLoading: true));
    final items = await _repository.getTasbihItems();
    final selected = items.isNotEmpty ? items.first : null;
    emit(state.copyWith(items: items, selectedItem: selected, isLoading: false));
  }

  void selectItem(String id) {
    final item = state.items.where((i) => i.id == id).firstOrNull;
    if (item != null) {
      emit(state.copyWith(selectedItem: item, targetReachedCelebration: false));
    }
  }

  void increment() {
    final current = state.selectedItem;
    if (current == null) return;

    final nextCount = current.currentCount + 1;
    final nextTotal = current.totalAllTimeCount + 1;
    final isTargetReached = nextCount % current.target == 0;

    if (state.enableVibration) {
      if (isTargetReached) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    final updatedItem = current.copyWith(
      currentCount: nextCount,
      totalAllTimeCount: nextTotal,
    );

    final updatedItems = state.items.map((i) => i.id == current.id ? updatedItem : i).toList();

    emit(state.copyWith(
      items: updatedItems,
      selectedItem: updatedItem,
      targetReachedCelebration: isTargetReached,
    ));

    _repository.updateTasbihCount(current.id, nextCount, nextTotal);
  }

  void resetCurrent() {
    final current = state.selectedItem;
    if (current == null) return;

    final updatedItem = current.copyWith(currentCount: 0);
    final updatedItems = state.items.map((i) => i.id == current.id ? updatedItem : i).toList();

    emit(state.copyWith(
      items: updatedItems,
      selectedItem: updatedItem,
      targetReachedCelebration: false,
    ));

    _repository.updateTasbihCount(current.id, 0, current.totalAllTimeCount);
  }

  Future<void> addCustomPhrase(String text, int target, {String? reward}) async {
    await _repository.addCustomTasbih(text, target, reward: reward);
    await loadTasbih();
  }

  Future<void> deletePhrase(String id) async {
    await _repository.deleteTasbih(id);
    await loadTasbih();
  }

  void toggleVibration(bool val) => emit(state.copyWith(enableVibration: val));
  void toggleSound(bool val) => emit(state.copyWith(enableSound: val));
  void clearCelebration() => emit(state.copyWith(targetReachedCelebration: false));
}
