import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_provider.dart';
import '../theme/app_theme.dart';

/// A compact EN | VI segmented switch for changing the UI language.
///
/// Use [onDark] = true on the pink gradient headers (light text on a
/// translucent pill) and [onDark] = false on light surfaces such as the
/// publication detail [AppBar].
class LanguageToggle extends StatelessWidget {
  final bool onDark;

  const LanguageToggle({super.key, this.onDark = true});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleProvider>().language;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.20)
            : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(context, 'EN', AppLanguage.en, current),
          _segment(context, 'VI', AppLanguage.vi, current),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    AppLanguage value,
    AppLanguage current,
  ) {
    final selected = value == current;
    final activeBg = onDark ? Colors.white : AppColors.primary;
    final activeFg = onDark ? AppColors.primary : Colors.white;
    final inactiveFg = onDark ? Colors.white : AppColors.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<LocaleProvider>().setLanguage(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? activeFg : inactiveFg,
          ),
        ),
      ),
    );
  }
}
