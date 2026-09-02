import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/tasbih_cubit.dart';
import '../widgets/tasbih_bead_counter.dart';
import '../../../rewards/presentation/cubits/arkan_coins_cubit.dart';
import '../../../rewards/domain/entities/arkan_coin_transaction.dart';

class SmartTasbihScreen extends StatelessWidget {
  const SmartTasbihScreen({super.key});

  void _showAddPhraseDialog(BuildContext context) {
    final textController = TextEditingController();
    final targetController = TextEditingController(text: '33');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF181E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          top: 20.h,
          left: 20.w,
          right: 20.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'islamic.tasbih.add_custom_title'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'islamic.tasbih.phrase_label'.tr(),
                hintText: 'islamic.tasbih.phrase_hint'.tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'islamic.tasbih.target_label'.tr(),
                hintText: 'islamic.tasbih.target_hint'.tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  final target = int.tryParse(targetController.text) ?? 33;
                  if (text.isNotEmpty) {
                    context.read<TasbihCubit>().addCustomPhrase(text, target);
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text('islamic.tasbih.save_phrase'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.smart_tasbih'.tr(),
        isTransparent: true,
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.add_circle),
            onPressed: () => _showAddPhraseDialog(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<TasbihCubit, TasbihState>(
            builder: (context, state) {
              final items = state.items;
              final selected = state.selectedItem;

              if (state.isLoading && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (selected == null) {
                return Center(child: Text('islamic.tasbih.no_phrases'.tr()));
              }

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Phrases Horizontal Scroll Chips
                  SizedBox(
                    height: 44.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = item.id == selected.id;

                        return ChoiceChip(
                          label: Text(item.text),
                          selected: isSelected,
                          onSelected: (_) => context.read<TasbihCubit>().selectItem(item.id),
                          selectedColor: const Color(0xFF3551AE),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Big Interactive Tasbih Bead Counter
                  TasbihBeadCounter(
                    phraseText: selected.text,
                    rewardText: selected.reward,
                    currentCount: selected.currentCount,
                    targetCount: selected.target,
                    totalCount: selected.totalAllTimeCount,
                    onTap: () {
                      context.read<TasbihCubit>().increment();
                      final current = selected.currentCount + 1;
                      if (current % selected.target == 0) {
                        context.read<ArkanCoinsCubit>().awardCoins(
                          amount: 2,
                          title: 'إتمام دورة تسبيح: ${selected.text}',
                          subtitle: 'المداومة على ذكر الله بالمسبحة',
                          source: ArkanCoinSource.tasbih,
                          tasbihCount: selected.target,
                        );
                      }
                    },
                    onReset: () => context.read<TasbihCubit>().resetCurrent(),
                  ),

                  const Spacer(),

                  // Bottom Settings Bar (Vibration toggle)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              IconsaxPlusLinear.mobile,
                              size: 18.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'islamic.vibrate_on_tap'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: state.enableVibration,
                          onChanged: (val) => context.read<TasbihCubit>().toggleVibration(val),
                          activeThumbColor: const Color(0xFF3551AE),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}
