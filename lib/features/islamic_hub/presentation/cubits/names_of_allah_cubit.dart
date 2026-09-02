import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/name_of_allah_entity.dart';

class NamesOfAllahState extends Equatable {
  final List<NameOfAllahEntity> names;
  final List<NameOfAllahEntity> filteredNames;
  final String searchQuery;
  final NameOfAllahEntity? selectedName;
  final List<int> favoriteIds;
  final bool isLoading;
  final String? error;

  const NamesOfAllahState({
    this.names = const [],
    this.filteredNames = const [],
    this.searchQuery = '',
    this.selectedName,
    this.favoriteIds = const [],
    this.isLoading = false,
    this.error,
  });

  NamesOfAllahState copyWith({
    List<NameOfAllahEntity>? names,
    List<NameOfAllahEntity>? filteredNames,
    String? searchQuery,
    NameOfAllahEntity? selectedName,
    List<int>? favoriteIds,
    bool? isLoading,
    String? error,
    bool clearSelected = false,
  }) {
    return NamesOfAllahState(
      names: names ?? this.names,
      filteredNames: filteredNames ?? this.filteredNames,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedName: clearSelected ? null : (selectedName ?? this.selectedName),
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        names,
        filteredNames,
        searchQuery,
        selectedName,
        favoriteIds,
        isLoading,
        error,
      ];
}

class NamesOfAllahCubit extends Cubit<NamesOfAllahState> {
  static const String _keyFavorites = 'islamic_names_favorites_v1';

  NamesOfAllahCubit() : super(const NamesOfAllahState()) {
    loadNames();
  }

  Future<void> loadNames() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final jsonString = await rootBundle.loadString('assets/data/names_of_allah.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      final names = list.map((item) => NameOfAllahEntity.fromJson(item as Map<String, dynamic>)).toList();

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_keyFavorites) ?? [];
      final favoriteIds = favList.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();

      emit(state.copyWith(
        names: names,
        filteredNames: names,
        favoriteIds: favoriteIds,
        isLoading: false,
      ));
    } catch (e) {
      AppLogger.warning('Failed to load names of allah: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل تحميل أسماء الله الحسنى: $e',
      ));
    }
  }

  void searchNames(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredNames: state.names,
      ));
      return;
    }

    final normalized = _normalizeArabic(trimmed);
    final filtered = state.names.where((item) {
      final nameNorm = _normalizeArabic(item.name.toLowerCase());
      final translit = item.transliteration.toLowerCase();
      final meaningNorm = _normalizeArabic(item.meaning.toLowerCase());
      return nameNorm.contains(normalized) ||
          translit.contains(trimmed) ||
          meaningNorm.contains(normalized);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredNames: filtered,
    ));
  }

  void selectName(NameOfAllahEntity? name) {
    emit(state.copyWith(selectedName: name));
  }

  Future<void> toggleFavorite(int id) async {
    final updated = List<int>.from(state.favoriteIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    emit(state.copyWith(favoriteIds: updated));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavorites, updated.map((e) => e.toString()).toList());
    } catch (e) {
      AppLogger.warning('Failed to save favorite names: $e');
    }
  }

  String _normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Remove tashkeel/harakat
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
