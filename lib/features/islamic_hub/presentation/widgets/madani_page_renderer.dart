import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/ayah_entity.dart';
import '../cubits/quran_cubit.dart';

class MadaniPageRenderer extends StatefulWidget {
  final int pageNumber;
  final String surahName;
  final String juzName;
  final QuranReadingMode readingMode;
  final String primaryImageUrl;
  final List<String> alternativeUrls;
  final List<int> highlightLines;
  final List<AyahLineSegment> highlightSegments;
  final bool isCurrentlyPlaying;

  const MadaniPageRenderer({
    super.key,
    required this.pageNumber,
    required this.surahName,
    required this.juzName,
    required this.readingMode,
    required this.primaryImageUrl,
    required this.alternativeUrls,
    this.highlightLines = const [],
    this.highlightSegments = const [],
    this.isCurrentlyPlaying = false,
  });

  @override
  State<MadaniPageRenderer> createState() => _MadaniPageRendererState();
}

class _MadaniPageRendererState extends State<MadaniPageRenderer> with SingleTickerProviderStateMixin {
  int _currentUrlIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.25, end: 0.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<String> get _allUrls {
    final list = <String>[];
    if (widget.primaryImageUrl.isNotEmpty) {
      list.add(widget.primaryImageUrl);
    }
    for (final alt in widget.alternativeUrls) {
      if (!list.contains(alt) && alt.isNotEmpty) {
        list.add(alt);
      }
    }
    return list;
  }

  String get _currentUrl {
    final urls = _allUrls;
    if (urls.isEmpty) return widget.primaryImageUrl;
    return urls[_currentUrlIndex.clamp(0, urls.length - 1)];
  }

  void _onImageError() {
    final urls = _allUrls;
    if (_currentUrlIndex + 1 < urls.length) {
      if (mounted) {
        setState(() {
          _currentUrlIndex++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.readingMode == QuranReadingMode.dark;
    final isSepia = widget.readingMode == QuranReadingMode.sepia;

    Color bgColor = const Color(0xFFFFFDF5);
    Color textColor = const Color(0xFF1E2438);
    ColorFilter? colorFilter;

    if (isDark) {
      bgColor = const Color(0xFF141722);
      textColor = const Color(0xFFE2E8F0);
      colorFilter = const ColorFilter.matrix([
        -1.0,  0.0,  0.0, 0.0, 240.0,
         0.0, -1.0,  0.0, 0.0, 240.0,
         0.0,  0.0, -1.0, 0.0, 240.0,
         0.0,  0.0,  0.0, 1.0,   0.0,
      ]);
    } else if (isSepia) {
      bgColor = const Color(0xFFF6EEDF);
      textColor = const Color(0xFF4A3525);
      colorFilter = const ColorFilter.matrix([
        0.95, 0.05, 0.00, 0.0, 10.0,
        0.05, 0.88, 0.05, 0.0, 0.0,
        0.00, 0.05, 0.70, 0.0, -20.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ]);
    } else {
      // Classic
      bgColor = const Color(0xFFFFFDF5);
      textColor = const Color(0xFF1E2438);
      colorFilter = null;
    }

    final currentUrl = _currentUrl;
    final hasMoreFallbacks = _currentUrlIndex + 1 < _allUrls.length;

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double mushafAspectRatio = 1260.0 / 2038.0;
              double targetWidth = constraints.maxWidth;
              double targetHeight = targetWidth / mushafAspectRatio;

              if (constraints.maxHeight.isFinite && targetHeight > constraints.maxHeight) {
                targetHeight = constraints.maxHeight;
                targetWidth = targetHeight * mushafAspectRatio;
              }

              Widget buildFittedImage(String url) {
                if (kIsWeb) {
                  return Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.contain,
                    width: targetWidth,
                    height: targetHeight,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Skeletonizer(
                        enabled: true,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      if (hasMoreFallbacks) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _onImageError());
                        return Skeletonizer(
                          enabled: true,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded, size: 40.sp, color: textColor),
                            SizedBox(height: 8.h),
                            Text(
                              'تعذر تحميل الصفحة ${widget.pageNumber}',
                              style: TextStyle(color: textColor, fontSize: 13.sp),
                            ),
                            SizedBox(height: 8.h),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentUrlIndex = 0;
                                });
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return CachedNetworkImage(
                  key: ValueKey(url),
                  imageUrl: url,
                  fit: BoxFit.contain,
                  width: targetWidth,
                  height: targetHeight,
                  alignment: Alignment.center,
                  placeholder: (context, url) => Skeletonizer(
                    enabled: true,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    if (hasMoreFallbacks) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _onImageError());
                      return Skeletonizer(
                        enabled: true,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_rounded, size: 40.sp, color: textColor),
                          SizedBox(height: 8.h),
                          Text(
                            'تعذر تحميل الصفحة ${widget.pageNumber}',
                            style: TextStyle(color: textColor, fontSize: 13.sp),
                          ),
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentUrlIndex = 0;
                              });
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return SizedBox(
                width: targetWidth,
                height: targetHeight,
                child: Stack(
                  children: [
                    // Base Page Image
                    Positioned.fill(
                      child: colorFilter != null
                          ? ColorFiltered(
                              colorFilter: colorFilter,
                              child: buildFittedImage(currentUrl),
                            )
                          : buildFittedImage(currentUrl),
                    ),

                    // Ayah Highlight Overlay (Exact Word-level segment or line highlight)
                    if (widget.isCurrentlyPlaying &&
                        (widget.highlightSegments.isNotEmpty || widget.highlightLines.isNotEmpty))
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final highlightColor = isDark
                              ? const Color(0xFF3551AE).withValues(alpha: _pulseAnimation.value * 0.9)
                              : const Color(0xFFE0A922).withValues(alpha: _pulseAnimation.value);
                          final borderColor = isDark
                              ? const Color(0xFF4A68D6).withValues(alpha: 0.6)
                              : const Color(0xFFD4AF37).withValues(alpha: 0.6);

                          if (widget.highlightSegments.isNotEmpty) {
                            return Stack(
                              children: widget.highlightSegments.map((segment) {
                                final lineBox = _getLineBox(segment.line, widget.pageNumber, targetWidth, targetHeight);
                                final segLeft = lineBox.left + (segment.leftRatio * lineBox.width);
                                final segWidth = (segment.widthRatio * lineBox.width).clamp(16.0, lineBox.width);

                                return Positioned(
                                  top: lineBox.top,
                                  left: segLeft,
                                  width: segWidth,
                                  height: lineBox.height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: highlightColor,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }

                          return Stack(
                            children: widget.highlightLines.map((lineNum) {
                              final lineBox = _getLineBox(lineNum, widget.pageNumber, targetWidth, targetHeight);

                              return Positioned(
                                top: lineBox.top,
                                left: lineBox.left,
                                width: lineBox.width,
                                height: lineBox.height,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: highlightColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static _MadaniLineBox _getLineBox(int lineNum, int pageNumber, double screenWidth, double screenHeight) {
    if (pageNumber <= 2) {
      // Bounding boxes for Pages 1 & 2 (8 lines within central decorative ornate medallion)
      // Line 1: 200px (top), pitch: 98px per line, height: 78px
      const p12Boxes = <int, _MadaniLineRatio>{
        1: _MadaniLineRatio(top: 165 / 2038, height: 84 / 2038, left: 330 / 1260, width: 600 / 1260),
        2: _MadaniLineRatio(top: 298 / 2038, height: 78 / 2038, left: 250 / 1260, width: 760 / 1260),
        3: _MadaniLineRatio(top: 396 / 2038, height: 78 / 2038, left: 190 / 1260, width: 880 / 1260),
        4: _MadaniLineRatio(top: 494 / 2038, height: 78 / 2038, left: 190 / 1260, width: 880 / 1260),
        5: _MadaniLineRatio(top: 592 / 2038, height: 78 / 2038, left: 190 / 1260, width: 880 / 1260),
        6: _MadaniLineRatio(top: 690 / 2038, height: 78 / 2038, left: 250 / 1260, width: 760 / 1260),
        7: _MadaniLineRatio(top: 788 / 2038, height: 78 / 2038, left: 320 / 1260, width: 620 / 1260),
        8: _MadaniLineRatio(top: 886 / 2038, height: 78 / 2038, left: 340 / 1260, width: 580 / 1260),
      };
      final ratio = p12Boxes[lineNum.clamp(1, 8)] ?? p12Boxes[1]!;
      return _MadaniLineBox(
        top: ratio.top * screenHeight,
        height: ratio.height * screenHeight,
        left: ratio.left * screenWidth,
        width: ratio.width * screenWidth,
      );
    }

    // Standard pages (3..604: 15 lines of Madani Mushaf)
    // In authentic 1260x2038 page assets:
    // Line 1 starts at Y=60.0px, Line pitch is 128.7px per line, Line height is ~112px
    // Line 1: 60px (top), Line 8: 961px (mid), Line 15: 1862px (bottom)
    // Horizontal text area starts at X=86px with width 1090px
    final clampedLine = lineNum.clamp(1, 15);
    final top = ((60.0 + (clampedLine - 1) * 128.7) / 2038.0) * screenHeight;
    final height = (112.0 / 2038.0) * screenHeight;
    final left = (86.0 / 1260.0) * screenWidth;
    final width = (1090.0 / 1260.0) * screenWidth;

    return _MadaniLineBox(
      top: top,
      height: height,
      left: left,
      width: width,
    );
  }
}

class _MadaniLineRatio {
  final double top;
  final double height;
  final double left;
  final double width;

  const _MadaniLineRatio({
    required this.top,
    required this.height,
    required this.left,
    required this.width,
  });
}

class _MadaniLineBox {
  final double top;
  final double height;
  final double left;
  final double width;

  const _MadaniLineBox({
    required this.top,
    required this.height,
    required this.left,
    required this.width,
  });
}
