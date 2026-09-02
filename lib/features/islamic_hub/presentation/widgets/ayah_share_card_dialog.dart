import 'dart:ui' as ui;
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/ayah_entity.dart';

class AyahShareCardDialog extends StatefulWidget {
  final AyahEntity ayah;

  const AyahShareCardDialog({super.key, required this.ayah});

  static Future<void> show(BuildContext context, AyahEntity ayah) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AyahShareCardDialog(ayah: ayah),
    );
  }

  @override
  State<AyahShareCardDialog> createState() => _AyahShareCardDialogState();
}

class _AyahShareCardDialogState extends State<AyahShareCardDialog> {
  int _selectedThemeIndex = 0;
  bool _isSharing = false;
  final GlobalKey _cardKey = GlobalKey();

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'كحلي وذهبي',
      'bgGradient': [const Color(0xFF0F172A), const Color(0xFF1E293B)],
      'textColor': const Color(0xFFF8FAFC),
      'accentColor': const Color(0xFFF59E0B),
      'borderColor': const Color(0xFFD97706),
    },
    {
      'name': 'زمردي ملكي',
      'bgGradient': [const Color(0xFF064E3B), const Color(0xFF042F2C)],
      'textColor': const Color(0xFFECFDF5),
      'accentColor': const Color(0xFF34D399),
      'borderColor': const Color(0xFF059669),
    },
    {
      'name': 'ورقي دافئ',
      'bgGradient': [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
      'textColor': const Color(0xFF451A03),
      'accentColor': const Color(0xFF92400E),
      'borderColor': const Color(0xFFD97706),
    },
    {
      'name': 'فحمي فاخر',
      'bgGradient': [const Color(0xFF18181B), const Color(0xFF09090B)],
      'textColor': const Color(0xFFFAFAFA),
      'accentColor': const Color(0xFFE4E4E7),
      'borderColor': const Color(0xFF52525B),
    },
  ];

  void _copyAyahText() {
    final text =
        '﴿ ${widget.ayah.text} ﴾\n[${widget.ayah.surahName}: الآية ${widget.ayah.numberInSurah}]\n— تطبيق نور الدين';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('islamic.share_card.copied_toast'.tr(),
            style: const TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Capture the card widget as an image
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/ayah_${widget.ayah.number}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the image file
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/png')],
        text:
            '﴿ ${widget.ayah.surahName} — الآية ${widget.ayah.numberInSurah} ﴾\n— عبر تطبيق نور الدين 📱✨',
      );
    } catch (e) {
      debugPrint('Error sharing ayah card: $e');
      // Fallback to text sharing
      final text =
          '﴿ ${widget.ayah.text} ﴾\n\n[${widget.ayah.surahName} - الآية ${widget.ayah.numberInSurah}]\n\n— عبر تطبيق نور الدين 📱✨';
      await Share.share(text);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _themes[_selectedThemeIndex];
    final bgGradient = activeTheme['bgGradient'] as List<Color>;
    final textColor = activeTheme['textColor'] as Color;
    final accentColor = activeTheme['accentColor'] as Color;
    final borderColor = activeTheme['borderColor'] as Color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // The Card Itself — wrapped in RepaintBoundary for image capture
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: bgGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: borderColor.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Basmalah Ornate Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1.h,
                        width: 30.w,
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Amiri',
                            color: accentColor,
                          ),
                        ),
                      ),
                      Container(
                        height: 1.h,
                        width: 30.w,
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Ayah Text
                  Text(
                    widget.ayah.text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Amiri',
                      height: 1.8,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Footer (Surah Name & Watermark)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${widget.ayah.surahName} • الآية ${widget.ayah.numberInSurah}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      Text(
                        'نور الدين',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: textColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Theme Selector Pills
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_themes.length, (idx) {
                final isSelected = _selectedThemeIndex == idx;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedThemeIndex = idx),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.white24 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _themes[idx]['name'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                              isSelected ? Colors.white : Colors.white60,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 16.h),

          // Share Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copyAyahText,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text('islamic.share_card.copy_text_btn'.tr(),
                    style: const TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton.icon(
                onPressed: _isSharing ? null : _shareAsImage,
                icon: _isSharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      )
                    : const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  _isSharing ? 'islamic.share_card.sharing'.tr() : 'islamic.share_card.share_image_btn'.tr(),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3551AE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
