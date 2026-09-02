import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.onPressed,
    this.isTransparent = false,
    this.showBackButton = true,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onPressed;
  final bool? centerTitle;
  final bool isTransparent;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showLead = showBackButton;

    void handleBack() {
      if (onPressed != null) {
        onPressed!();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }

    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: isTransparent ? Colors.transparent : null,
      shadowColor: Colors.transparent,
      title: titleWidget ??
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                ) ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
      leadingWidth: showLead ? 52.w : 16.w,
      leading: showLead
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: 12.w),
              child: Center(
                child: InkWell(
                  onTap: handleBack,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        IconsaxPlusLinear.arrow_right_3,
                        size: 20.sp,
                        color: theme.appBarTheme.iconTheme?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      iconTheme: theme.appBarTheme.iconTheme,
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
