import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../widgets/bouncy_pressable.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';

class LanguageOption {
  final String code;
  final String name;
  final String subtitle;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flag,
  });
}

class LanguageSelectionDialog extends StatefulWidget {
  final bool isFirstTime;

  const LanguageSelectionDialog({
    super.key,
    this.isFirstTime = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    bool isFirstTime = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return CartoonDialog.show<bool>(
      context: context,
      title: l10n.chooseLanguage,
      dismissible: !isFirstTime,
      child: LanguageSelectionDialog(isFirstTime: isFirstTime),
    );
  }

  @override
  State<LanguageSelectionDialog> createState() => _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  late String _selectedCode;

  static const List<LanguageOption> _languages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      subtitle: 'English',
      flag: '🇬🇧',
    ),
    LanguageOption(
      code: 'fr',
      name: 'Français',
      subtitle: 'French',
      flag: '🇫🇷',
    ),
    LanguageOption(
      code: 'ar',
      name: 'العربية',
      subtitle: 'Arabic',
      flag: '🇸🇦',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final currentCode = LocaleController.instance.languageCode;
    // On first launch if locale hasn't been chosen yet, check device system locale
    if (widget.isFirstTime && !LocaleController.instance.hasChosenLanguage) {
      final deviceCode =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (deviceCode == 'fr' || deviceCode == 'ar' || deviceCode == 'en') {
        _selectedCode = deviceCode;
      } else {
        _selectedCode = currentCode;
      }
    } else {
      _selectedCode = currentCode;
    }
  }

  Future<void> _onSelect(String code) async {
    if (_selectedCode == code) return;
    setState(() {
      _selectedCode = code;
    });
    // Immediately update locale so player gets live localized feedback
    await LocaleController.instance.setLocale(Locale(code));
  }

  Future<void> _confirm() async {
    await LocaleController.instance.setLocale(Locale(_selectedCode));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.chooseLanguageSubtitle,
          textAlign: TextAlign.center,
          style: AppFonts.bangers(
            fontSize: 13,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ..._languages.map((lang) => _buildLanguageCard(lang)),
        const SizedBox(height: 16),
        KenneyButton(
          label: l10n.confirm,
          isWide: true,
          style: KenneyBtnStyle.primary,
          onPressed: _confirm,
        ),
      ],
    );

    if (widget.isFirstTime) {
      return PopScope(
        canPop: false,
        child: content,
      );
    }

    return content;
  }

  Widget _buildLanguageCard(LanguageOption lang) {
    final isSelected = _selectedCode == lang.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BouncyPressable(
        onTap: () => _onSelect(lang.code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFF176) : Colors.white24,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(
                lang.flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.name,
                      style: AppFonts.bangers(
                        fontSize: 18,
                        color: isSelected
                            ? const Color(0xFF3E2723)
                            : Colors.white,
                      ),
                    ),
                    Text(
                      lang.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF5D4037)
                            : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF3E2723)
                      : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3E2723)
                        : Colors.white30,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFFFFD54F),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
