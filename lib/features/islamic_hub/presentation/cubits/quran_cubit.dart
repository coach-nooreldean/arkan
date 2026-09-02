import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';

enum QuranReadingMode { classic, dark, sepia }

enum QuranAudioStatus { stopped, playing, paused, loading }

class QuranState extends Equatable {
  final int currentPage;
  final List<SurahEntity> surahs;
  final List<JuzEntity> juzs;
  final List<SurahEntity> filteredSurahs;
  final String searchQuery;
  final List<AyahEntity> currentPageAyahs;
  final bool isLoadingAyahs;
  final String? selectedAyahTafsir;
  final int? selectedAyahNumber;
  final QuranReadingMode readingMode;
  final QuranAudioStatus audioStatus;
  final String selectedReciter; // alafasy, alhusary, abdulbasit, minshawi
  final int? playingAyahNumber;
  final AyahEntity? playingAyah;
  final List<int> bookmarkedPages;

  // Memorization & Repeats
  final int ayahRepeatCount; // How many times each Ayah repeats (1, 2, 3, 5, 10)
  final int currentAyahRepeatProgress; // Current repeat of playing Ayah (1..ayahRepeatCount)
  final int rangeRepeatCount; // How many times the selected range repeats (1, 2, 3, 5, 10)
  final int currentRangeRepeatProgress; // Current repeat of range (1..rangeRepeatCount)
  final int? rangeStartAyahNumber; // Custom start Ayah number (optional)
  final int? rangeEndAyahNumber; // Custom end Ayah number (optional)
  final List<AyahEntity> activeRangePlaylist; // Custom range playlist across pages
  final int currentPlaylistIndex;

  // Offline Audio Download
  final bool isDownloadingSurah;
  final double? downloadProgress;
  final String? downloadingSurahName;
  final String? downloadingAyahInfo;
  final String? downloadCompletedMessage;

  const QuranState({
    this.currentPage = 1,
    this.surahs = const [],
    this.juzs = const [],
    this.filteredSurahs = const [],
    this.searchQuery = '',
    this.currentPageAyahs = const [],
    this.isLoadingAyahs = false,
    this.selectedAyahTafsir,
    this.selectedAyahNumber,
    this.readingMode = QuranReadingMode.classic,
    this.audioStatus = QuranAudioStatus.stopped,
    this.selectedReciter = 'alafasy',
    this.playingAyahNumber,
    this.playingAyah,
    this.bookmarkedPages = const [],
    this.ayahRepeatCount = 1,
    this.currentAyahRepeatProgress = 1,
    this.rangeRepeatCount = 1,
    this.currentRangeRepeatProgress = 1,
    this.rangeStartAyahNumber,
    this.rangeEndAyahNumber,
    this.activeRangePlaylist = const [],
    this.currentPlaylistIndex = 0,
    this.isDownloadingSurah = false,
    this.downloadProgress,
    this.downloadingSurahName,
    this.downloadingAyahInfo,
    this.downloadCompletedMessage,
  });

  SurahEntity? get currentSurah {
    for (final s in surahs) {
      if (currentPage >= s.startPage && currentPage <= s.endPage) {
        return s;
      }
    }
    return surahs.isNotEmpty ? surahs.first : null;
  }

  JuzEntity? get currentJuz {
    for (int i = juzs.length - 1; i >= 0; i--) {
      if (currentPage >= juzs[i].startPage) {
        return juzs[i];
      }
    }
    return juzs.isNotEmpty ? juzs.first : null;
  }

  AyahEntity? get currentPlayingAyah {
    if (playingAyahNumber == null) return null;

    if (activeRangePlaylist.isNotEmpty &&
        currentPlaylistIndex >= 0 &&
        currentPlaylistIndex < activeRangePlaylist.length) {
      return activeRangePlaylist[currentPlaylistIndex];
    }

    if (playingAyah != null) return playingAyah;

    for (final ayah in currentPageAyahs) {
      if (ayah.number == playingAyahNumber) {
        return ayah;
      }
    }
    return null;
  }

  bool get isCurrentPageBookmarked => bookmarkedPages.contains(currentPage);

  QuranState copyWith({
    int? currentPage,
    List<SurahEntity>? surahs,
    List<JuzEntity>? juzs,
    List<SurahEntity>? filteredSurahs,
    String? searchQuery,
    List<AyahEntity>? currentPageAyahs,
    bool? isLoadingAyahs,
    String? selectedAyahTafsir,
    int? selectedAyahNumber,
    QuranReadingMode? readingMode,
    QuranAudioStatus? audioStatus,
    String? selectedReciter,
    int? playingAyahNumber,
    AyahEntity? playingAyah,
    List<int>? bookmarkedPages,
    int? ayahRepeatCount,
    int? currentAyahRepeatProgress,
    int? rangeRepeatCount,
    int? currentRangeRepeatProgress,
    int? rangeStartAyahNumber,
    int? rangeEndAyahNumber,
    List<AyahEntity>? activeRangePlaylist,
    int? currentPlaylistIndex,
    bool? isDownloadingSurah,
    double? downloadProgress,
    String? downloadingSurahName,
    String? downloadingAyahInfo,
    String? downloadCompletedMessage,
    bool clearTafsir = false,
    bool clearRange = false,
    bool clearPlayingAyah = false,
    bool clearDownloading = false,
    bool clearCompletedMessage = false,
  }) {
    return QuranState(
      currentPage: currentPage ?? this.currentPage,
      surahs: surahs ?? this.surahs,
      juzs: juzs ?? this.juzs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPageAyahs: currentPageAyahs ?? this.currentPageAyahs,
      isLoadingAyahs: isLoadingAyahs ?? this.isLoadingAyahs,
      selectedAyahTafsir: clearTafsir ? null : (selectedAyahTafsir ?? this.selectedAyahTafsir),
      selectedAyahNumber: clearTafsir ? null : (selectedAyahNumber ?? this.selectedAyahNumber),
      readingMode: readingMode ?? this.readingMode,
      audioStatus: audioStatus ?? this.audioStatus,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      playingAyahNumber: clearPlayingAyah ? null : (playingAyahNumber ?? this.playingAyahNumber),
      playingAyah: clearPlayingAyah ? null : (playingAyah ?? this.playingAyah),
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      ayahRepeatCount: ayahRepeatCount ?? this.ayahRepeatCount,
      currentAyahRepeatProgress: currentAyahRepeatProgress ?? this.currentAyahRepeatProgress,
      rangeRepeatCount: rangeRepeatCount ?? this.rangeRepeatCount,
      currentRangeRepeatProgress: currentRangeRepeatProgress ?? this.currentRangeRepeatProgress,
      rangeStartAyahNumber: clearRange ? null : (rangeStartAyahNumber ?? this.rangeStartAyahNumber),
      rangeEndAyahNumber: clearRange ? null : (rangeEndAyahNumber ?? this.rangeEndAyahNumber),
      activeRangePlaylist: clearRange ? const [] : (activeRangePlaylist ?? this.activeRangePlaylist),
      currentPlaylistIndex: clearRange ? 0 : (currentPlaylistIndex ?? this.currentPlaylistIndex),
      isDownloadingSurah: isDownloadingSurah ?? this.isDownloadingSurah,
      downloadProgress: clearDownloading ? null : (downloadProgress ?? this.downloadProgress),
      downloadingSurahName: clearDownloading ? null : (downloadingSurahName ?? this.downloadingSurahName),
      downloadingAyahInfo: clearDownloading ? null : (downloadingAyahInfo ?? this.downloadingAyahInfo),
      downloadCompletedMessage: clearCompletedMessage ? null : (downloadCompletedMessage ?? this.downloadCompletedMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        surahs,
        juzs,
        filteredSurahs,
        searchQuery,
        currentPageAyahs,
        isLoadingAyahs,
        selectedAyahTafsir,
        selectedAyahNumber,
        readingMode,
        audioStatus,
        selectedReciter,
        playingAyahNumber,
        playingAyah,
        bookmarkedPages,
        ayahRepeatCount,
        currentAyahRepeatProgress,
        rangeRepeatCount,
        currentRangeRepeatProgress,
        rangeStartAyahNumber,
        rangeEndAyahNumber,
        activeRangePlaylist,
        currentPlaylistIndex,
        isDownloadingSurah,
        downloadProgress,
        downloadingSurahName,
        downloadingAyahInfo,
        downloadCompletedMessage,
      ];
}

class QuranCubit extends Cubit<QuranState> {
  final IslamicHubRepository _repository;
  final AudioPlayer _audioPlayer;

  QuranCubit({required IslamicHubRepository repository, AudioPlayer? audioPlayer})
      : _repository = repository,
        _audioPlayer = audioPlayer ?? AudioPlayer(),
        super(const QuranState()) {
    _init();
  }

  Future<void> _init() async {
    final surahs = await _repository.getAllSurahs();
    final juzs = await _repository.getAllJuzs();
    final settings = await _repository.getSettings();

    QuranReadingMode mode = QuranReadingMode.classic;
    if (settings.quranReadingMode == 'dark') {
      mode = QuranReadingMode.dark;
    } else if (settings.quranReadingMode == 'sepia') {
      mode = QuranReadingMode.sepia;
    }

    emit(state.copyWith(
      surahs: surahs,
      juzs: juzs,
      filteredSurahs: surahs,
      currentPage: settings.lastReadQuranPage.clamp(1, 604),
      bookmarkedPages: settings.bookmarkedPages,
      readingMode: mode,
      selectedReciter: settings.quranSelectedReciter,
      ayahRepeatCount: settings.quranAyahRepeat.clamp(1, 20),
      rangeRepeatCount: settings.quranRangeRepeat.clamp(1, 20),
    ));

    _listenToAudioPlayer();
    loadAyahsForCurrentPage();
  }

  bool _isChangingTrack = false;

  void _listenToAudioPlayer() {
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (!_isChangingTrack && state.audioStatus != QuranAudioStatus.stopped && state.audioStatus != QuranAudioStatus.loading) {
          _playNextAyahInSequence();
        }
      } else if (playerState.playing) {
        emit(state.copyWith(audioStatus: QuranAudioStatus.playing));
      } else if (playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering) {
        emit(state.copyWith(audioStatus: QuranAudioStatus.loading));
      } else if (playerState.processingState == ProcessingState.idle) {
        emit(state.copyWith(audioStatus: QuranAudioStatus.stopped));
      } else {
        emit(state.copyWith(audioStatus: QuranAudioStatus.paused));
      }
    });
  }

  void clearDownloadCompletedMessage() {
    emit(state.copyWith(clearCompletedMessage: true));
  }

  Future<void> _playNextAyahInSequence() async {
    final currentAyah = state.currentPlayingAyah;
    if (currentAyah == null && state.playingAyahNumber == null) {
      emit(state.copyWith(audioStatus: QuranAudioStatus.stopped, clearPlayingAyah: true));
      return;
    }

    // 1. Handle Ayah Repeat count
    if (state.currentAyahRepeatProgress < state.ayahRepeatCount) {
      final nextRepeat = state.currentAyahRepeatProgress + 1;
      emit(state.copyWith(currentAyahRepeatProgress: nextRepeat));
      if (currentAyah != null) {
        await playAyah(currentAyah, isSubsequentRepeat: true);
        return;
      }
    }

    // Reset current ayah repeat counter
    emit(state.copyWith(currentAyahRepeatProgress: 1));

    // 2. If activeRangePlaylist is active (Custom Surah Range Repeat)
    if (state.activeRangePlaylist.isNotEmpty) {
      final nextIndex = state.currentPlaylistIndex + 1;
      if (nextIndex < state.activeRangePlaylist.length) {
        emit(state.copyWith(currentPlaylistIndex: nextIndex));
        final nextAyah = state.activeRangePlaylist[nextIndex];
        await playAyah(nextAyah);
      } else {
        // Reached end of range playlist! Check range repeat
        if (state.currentRangeRepeatProgress < state.rangeRepeatCount) {
          final nextRangeProgress = state.currentRangeRepeatProgress + 1;
          emit(state.copyWith(
            currentRangeRepeatProgress: nextRangeProgress,
            currentPlaylistIndex: 0,
            currentAyahRepeatProgress: 1,
          ));
          final firstAyah = state.activeRangePlaylist.first;
          await playAyah(firstAyah);
        } else {
          // Finished all range repeats!
          emit(state.copyWith(
            audioStatus: QuranAudioStatus.stopped,
            playingAyahNumber: null,
            clearPlayingAyah: true,
            currentRangeRepeatProgress: 1,
            currentAyahRepeatProgress: 1,
            clearRange: true,
          ));
        }
      }
      return;
    }

    // 3. Normal sequential playback (advance through Surah uninterruptedly)
    if (currentAyah != null) {
      final surahNum = currentAyah.surahNumber;
      final numInSurah = currentAyah.numberInSurah;
      final surah = state.surahs.where((s) => s.number == surahNum).firstOrNull;
      final totalAyahsInSurah = surah?.numberOfAyahs ?? 286;

      if (numInSurah < totalAyahsInSurah) {
        final nextNumInSurah = numInSurah + 1;
        // Check if next Ayah is on currently loaded page
        AyahEntity? nextAyah = state.currentPageAyahs
            .where((a) => a.surahNumber == surahNum && a.numberInSurah == nextNumInSurah)
            .firstOrNull;

        if (nextAyah == null) {
          final surahAyahs = await getAyahsForSurah(surahNum);
          nextAyah = surahAyahs
              .where((a) => a.numberInSurah == nextNumInSurah)
              .firstOrNull;
        }

        if (nextAyah != null) {
          await playAyah(nextAyah);
          return;
        }
      } else if (surahNum < 114) {
        // Advance to first Ayah of next Surah
        final nextSurahNum = surahNum + 1;
        final nextSurahAyahs = await getAyahsForSurah(nextSurahNum);
        if (nextSurahAyahs.isNotEmpty) {
          await playAyah(nextSurahAyahs.first);
          return;
        }
      }
    }

    // If no next ayah or reached end of Quran, stop audio
    emit(state.copyWith(
      audioStatus: QuranAudioStatus.stopped,
      playingAyahNumber: null,
      clearPlayingAyah: true,
    ));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

  void setPage(int page) {
    if (page < 1 || page > 604) return;
    emit(state.copyWith(
      currentPage: page,
      clearTafsir: true,
    ));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(lastReadQuranPage: page));
    });
    loadAyahsForCurrentPage();
  }

  void nextPage() => setPage(state.currentPage + 1);
  void previousPage() => setPage(state.currentPage - 1);

  void filterSurahs(String query) {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchQuery: '', filteredSurahs: state.surahs));
      return;
    }

    final q = query.trim().toLowerCase();
    final filtered = state.surahs.where((s) {
      final name = s.name.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
      final cleanQ = q.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
      return name.contains(cleanQ) ||
          s.englishName.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList();

    emit(state.copyWith(searchQuery: query, filteredSurahs: filtered));
  }

  Future<void> loadAyahsForCurrentPage() async {
    emit(state.copyWith(isLoadingAyahs: true));
    final result = await _repository.getAyahsForPage(state.currentPage);
    result.fold(
      (_) => emit(state.copyWith(isLoadingAyahs: false)),
      (ayahs) => emit(state.copyWith(currentPageAyahs: ayahs, isLoadingAyahs: false)),
    );
  }

  Future<List<AyahEntity>> getAyahsForSurah(int surahNumber) async {
    final result = await _repository.getAyahsForSurah(surahNumber);
    return result.fold((_) => [], (list) => list);
  }

  Future<void> showAyahTafsir(int ayahNumber) async {
    emit(state.copyWith(selectedAyahNumber: ayahNumber, selectedAyahTafsir: 'جاري تحميل التفسير الميسر...'));
    final result = await _repository.getAyahTafsir(ayahNumber);
    result.fold(
      (err) => emit(state.copyWith(selectedAyahTafsir: err)),
      (tafsir) => emit(state.copyWith(selectedAyahTafsir: tafsir)),
    );
  }

  void clearTafsir() {
    emit(state.copyWith(clearTafsir: true));
  }

  void setReadingMode(QuranReadingMode mode) {
    emit(state.copyWith(readingMode: mode));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(quranReadingMode: mode.name));
    });
  }

  void setReciter(String reciter) {
    emit(state.copyWith(selectedReciter: reciter));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(quranSelectedReciter: reciter));
    });
  }

  void setAyahRepeatCount(int count) {
    final clamped = count.clamp(1, 20);
    emit(state.copyWith(ayahRepeatCount: clamped, currentAyahRepeatProgress: 1));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(quranAyahRepeat: clamped));
    });
  }

  void setRangeRepeatCount(int count) {
    final clamped = count.clamp(1, 20);
    emit(state.copyWith(rangeRepeatCount: clamped, currentRangeRepeatProgress: 1));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(quranRangeRepeat: clamped));
    });
  }

  Future<void> playRange({
    required int surahNumber,
    required int startAyahInSurah,
    required int endAyahInSurah,
    int? ayahRepeat,
    int? rangeRepeat,
  }) async {
    final effectiveAyahRepeat = (ayahRepeat ?? state.ayahRepeatCount).clamp(1, 20);
    final effectiveRangeRepeat = (rangeRepeat ?? state.rangeRepeatCount).clamp(1, 20);
    if (ayahRepeat != null) setAyahRepeatCount(ayahRepeat);
    if (rangeRepeat != null) setRangeRepeatCount(rangeRepeat);

    emit(state.copyWith(
      audioStatus: QuranAudioStatus.loading,
      ayahRepeatCount: effectiveAyahRepeat,
      rangeRepeatCount: effectiveRangeRepeat,
      currentAyahRepeatProgress: 1,
      currentRangeRepeatProgress: 1,
    ));

    final allAyahs = await getAyahsForSurah(surahNumber);
    final filtered = allAyahs
        .where((a) => a.numberInSurah >= startAyahInSurah && a.numberInSurah <= endAyahInSurah)
        .toList();

    if (filtered.isEmpty) {
      emit(state.copyWith(audioStatus: QuranAudioStatus.stopped));
      return;
    }

    final firstAyah = filtered.first;
    final lastAyah = filtered.last;

    emit(state.copyWith(
      activeRangePlaylist: filtered,
      currentPlaylistIndex: 0,
      rangeStartAyahNumber: firstAyah.number,
      rangeEndAyahNumber: lastAyah.number,
    ));

    if (state.currentPage != firstAyah.page) {
      setPage(firstAyah.page);
    }

    await playAyah(firstAyah);
  }

  void stopRangePlayback() {
    emit(state.copyWith(clearRange: true));
  }

  void cancelRepeat() {
    emit(state.copyWith(
      ayahRepeatCount: 1,
      currentAyahRepeatProgress: 1,
      rangeRepeatCount: 1,
      currentRangeRepeatProgress: 1,
      clearRange: true,
    ));
    _repository.getSettings().then((s) {
      _repository.saveSettings(s.copyWith(
        quranAyahRepeat: 1,
        quranRangeRepeat: 1,
      ));
    });
  }

  String _getAudioUrlForAyah(AyahEntity ayah, String reciter) {
    final surahPadded = ayah.surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayah.numberInSurah.toString().padLeft(3, '0');
    final code = '$surahPadded$ayahPadded';

    switch (reciter) {
      case 'abdulbasit':
        return 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$code.mp3';
      case 'alhusary':
        return 'https://everyayah.com/data/Husary_128kbps/$code.mp3';
      case 'minshawi':
        return 'https://everyayah.com/data/Minshawy_Murattal_128kbps/$code.mp3';
      case 'alafasy':
      default:
        return 'https://everyayah.com/data/Alafasy_128kbps/$code.mp3';
    }
  }

  Future<String> _getAudioSourceForAyah(AyahEntity ayah, String reciter) async {
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = '${appDir.path}/quran_audio/$reciter/${ayah.number}.mp3';
        final file = File(localPath);
        if (await file.exists()) {
          return localPath;
        }
      } catch (_) {}
    }
    return _getAudioUrlForAyah(ayah, reciter);
  }

  Future<void> playAyah(AyahEntity ayah, {bool isSubsequentRepeat = false}) async {
    try {
      _isChangingTrack = true;
      if (!isSubsequentRepeat) {
        emit(state.copyWith(
          audioStatus: QuranAudioStatus.loading,
          playingAyahNumber: ayah.number,
          playingAyah: ayah,
          currentAyahRepeatProgress: 1,
        ));
      } else {
        emit(state.copyWith(
          audioStatus: QuranAudioStatus.loading,
          playingAyahNumber: ayah.number,
          playingAyah: ayah,
        ));
      }
      final source = await _getAudioSourceForAyah(ayah, state.selectedReciter);
      if (source.startsWith('http')) {
        await _audioPlayer.setUrl(source);
      } else {
        await _audioPlayer.setFilePath(source);
      }
      _isChangingTrack = false;
      await _audioPlayer.play();
    } catch (e) {
      _isChangingTrack = false;
      AppLogger.error('Audio playback error: $e');
      emit(state.copyWith(
        audioStatus: QuranAudioStatus.stopped,
        playingAyahNumber: null,
        clearPlayingAyah: true,
      ));
    }
  }

  Future<void> downloadSurahAudio(int surahNumber) async {
    if (kIsWeb) {
      emit(state.copyWith(
        downloadCompletedMessage: 'الاستماع متاح مباشرة عبر الإنترنت في نسخة الويب ✨',
      ));
      return;
    }

    try {
      final surah = state.surahs.where((s) => s.number == surahNumber).firstOrNull;
      final surahName = surah?.name ?? 'رقم $surahNumber';

      emit(state.copyWith(
        isDownloadingSurah: true,
        downloadProgress: 0,
        downloadingSurahName: surahName,
        downloadingAyahInfo: 'بدء التحميل...',
        clearCompletedMessage: true,
      ));

      final ayahs = await getAyahsForSurah(surahNumber);
      if (ayahs.isEmpty) {
        emit(state.copyWith(
          isDownloadingSurah: false,
          downloadProgress: null,
          clearDownloading: true,
        ));
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final reciter = state.selectedReciter;
      final dir = Directory('${appDir.path}/quran_audio/$reciter');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final dio = Dio();
      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        final filePath = '${dir.path}/${ayah.number}.mp3';
        final file = File(filePath);
        if (!await file.exists()) {
          final url = _getAudioUrlForAyah(ayah, reciter);
          await dio.download(url, filePath);
        }
        final progress = (i + 1) / ayahs.length;
        emit(state.copyWith(
          isDownloadingSurah: true,
          downloadProgress: progress,
          downloadingSurahName: surahName,
          downloadingAyahInfo: 'آية ${i + 1} من ${ayahs.length}',
        ));
      }

      emit(state.copyWith(
        isDownloadingSurah: false,
        downloadProgress: 1,
        downloadCompletedMessage: 'تم اكتمال تحميل سورة $surahName بنجاح للاستماع أوفلاين 🎉',
        clearDownloading: true,
      ));
    } catch (e) {
      AppLogger.warning('Download surah audio error: $e');
      emit(state.copyWith(
        isDownloadingSurah: false,
        downloadProgress: null,
        clearDownloading: true,
      ));
    }
  }

  Future<void> playAyahAudio(int ayahNumber) async {
    final match = state.currentPageAyahs.where((a) => a.number == ayahNumber).firstOrNull;
    if (match != null) {
      await playAyah(match);
    } else {
      try {
        emit(state.copyWith(
          audioStatus: QuranAudioStatus.loading,
          playingAyahNumber: ayahNumber,
          currentAyahRepeatProgress: 1,
        ));
        final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3';
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } catch (e) {
        emit(state.copyWith(
          audioStatus: QuranAudioStatus.stopped,
          playingAyahNumber: null,
          clearPlayingAyah: true,
        ));
      }
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    emit(state.copyWith(
      audioStatus: QuranAudioStatus.stopped,
      playingAyahNumber: null,
      clearPlayingAyah: true,
      currentAyahRepeatProgress: 1,
      currentRangeRepeatProgress: 1,
      clearRange: true,
    ));
  }

  Future<void> toggleBookmarkCurrentPage() async {
    final bookmarks = List<int>.from(state.bookmarkedPages);
    final page = state.currentPage;
    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
    }
    emit(state.copyWith(bookmarkedPages: bookmarks));
    final settings = await _repository.getSettings();
    await _repository.saveSettings(settings.copyWith(bookmarkedPages: bookmarks));
  }

  String getPageImageUrl(int pageNumber) => _repository.getPageImageUrl(pageNumber);
  List<String> getPageImageAlternativeUrls(int pageNumber) =>
      _repository.getPageImageAlternativeUrls(pageNumber);
}
