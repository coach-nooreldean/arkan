import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/hadith_entity.dart';

class HadithState extends Equatable {
  final List<HadithEntity> hadiths;
  final List<HadithEntity> filteredHadiths;
  final String searchQuery;
  final HadithEntity? selectedHadith;
  final List<int> favoriteIds;
  final bool isLoading;
  final String? error;

  const HadithState({
    this.hadiths = const [],
    this.filteredHadiths = const [],
    this.searchQuery = '',
    this.selectedHadith,
    this.favoriteIds = const [],
    this.isLoading = false,
    this.error,
  });

  HadithState copyWith({
    List<HadithEntity>? hadiths,
    List<HadithEntity>? filteredHadiths,
    String? searchQuery,
    HadithEntity? selectedHadith,
    List<int>? favoriteIds,
    bool? isLoading,
    String? error,
    bool clearSelected = false,
  }) {
    return HadithState(
      hadiths: hadiths ?? this.hadiths,
      filteredHadiths: filteredHadiths ?? this.filteredHadiths,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedHadith: clearSelected ? null : (selectedHadith ?? this.selectedHadith),
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        hadiths,
        filteredHadiths,
        searchQuery,
        selectedHadith,
        favoriteIds,
        isLoading,
        error,
      ];
}

class HadithCubit extends Cubit<HadithState> {
  static const String _keyFavorites = 'islamic_hadiths_favorites_v1';

  HadithCubit() : super(const HadithState()) {
    loadHadiths();
  }

  Future<void> loadHadiths() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final jsonString = await rootBundle.loadString('assets/data/nawawi_hadiths.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      final hadiths = list.map((item) => HadithEntity.fromJson(item as Map<String, dynamic>)).toList();

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_keyFavorites) ?? [];
      final favoriteIds = favList.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();

      emit(state.copyWith(
        hadiths: hadiths,
        filteredHadiths: hadiths,
        favoriteIds: favoriteIds,
        isLoading: false,
      ));
    } catch (e) {
      AppLogger.warning('Failed to load nawawi hadiths: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'فشل تحميل الأحاديث: $e',
      ));
    }
  }

  void searchHadiths(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredHadiths: state.hadiths,
      ));
      return;
    }

    final normalized = _normalizeArabic(trimmed);
    final filtered = state.hadiths.where((item) {
      final titleNorm = _normalizeArabic(item.title.toLowerCase());
      final narratorNorm = _normalizeArabic(item.narrator.toLowerCase());
      final textNorm = _normalizeArabic(item.hadithText.toLowerCase());
      final expNorm = _normalizeArabic(item.explanation.toLowerCase());

      return titleNorm.contains(normalized) ||
          narratorNorm.contains(normalized) ||
          textNorm.contains(normalized) ||
          expNorm.contains(normalized);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredHadiths: filtered,
    ));
  }

  void selectHadith(HadithEntity? hadith) {
    emit(state.copyWith(selectedHadith: hadith));
  }

  void selectHadithById(int id) {
    final found = state.hadiths.where((h) => h.id == id).firstOrNull;
    if (found != null) {
      emit(state.copyWith(selectedHadith: found));
    }
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
      AppLogger.warning('Failed to save favorite hadiths: $e');
    }
  }

  String _normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}
