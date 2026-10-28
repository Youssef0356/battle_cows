import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../data/services/premium_service.dart';
import '../../data/services/progress_service.dart';
import '../../flame/audio_manager.dart';
import '../dialogs/premium_dialog.dart';
import '../widgets/kenney_button.dart';
import '../widgets/cartoon_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  int _difficultyIndex = 1;
  ProgressService? _progress;

  @override
  void initState() {
    super.initState();
    _soundEnabled = AudioManager().sfxEnabled;
    _musicEnabled = AudioManager().musicEnabled;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressService.getInstance();
    if (mounted) setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD54F),
        title: Text(
          l10n.settingsTitle.toUpperCase(),
          style: AppFonts.bangers(fontSize: 24, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Wooden background, matching the main menu's rustic look.
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Wood planks.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: const Color(0xFF3E2723)),
            ),
          ),
          // Dark wash so the settings text stays readable on the wood.
          const Positioned.fill(child: ColoredBox(color: Colors.black54)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                kToolbarHeight + 12,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(l10n.languageSection),
                  _buildLanguageSelector(l10n),
                  const SizedBox(height: 20),
                  _buildSectionHeader(l10n.audioSection),
                  _buildToggleRow(
                    l10n.soundEffects,
                    _soundEnabled,
                    () async {
                      setState(() => _soundEnabled = !_soundEnabled);
                      await AudioManager().toggleSfx();
                    },
                  ),
                  _buildToggleRow(
                    l10n.music,
                    _musicEnabled,
                    () async {
                      setState(() => _musicEnabled = !_musicEnabled);
                      await AudioManager().toggleMusic();
                    },
                  ),
                  _buildToggleRow(
                    l10n.hapticFeedback,
                    _hapticEnabled,
                    () => setState(() => _hapticEnabled = !_hapticEnabled),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(l10n.gameSection),
                  _buildDifficultySelector(l10n),
                  const SizedBox(height: 20),
                  _buildSectionHeader(l10n.accountSection),
                  _buildStatCard(l10n),
                  const SizedBox(height: 20),
                  _buildSectionHeader(l10n.premiumSection),
                  _buildPremiumTile(l10n),
                  const SizedBox(height: 20),
                  _buildSectionHeader(l10n.supportSection),
                  _buildKenneyButton(l10n.share, Icons.share, () {
                    Share.share(l10n.shareMessage);
                  }),
                  const SizedBox(height: 10),
                  _buildKenneyButton(l10n.rate, Icons.star, () async {
                    final inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  }),
                  const SizedBox(height: 10),
                  _buildKenneyButton(l10n.exit, Icons.exit_to_app_rounded, () {
                    CartoonDialog.show(
                      context: context,
                      title: l10n.exitGameTitle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.exitGameConfirm,
                            style: AppFonts.bangers(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: KenneyButton(
                                  label: l10n.cancel,
                                  isWide: true,
                                  style: KenneyBtnStyle.neutral,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Builder(
                                  builder: (context) => KenneyButton(
                                    label: l10n.exit,
                                    isWide: true,
                                    style: KenneyBtnStyle.danger,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    final currentCode = LocaleController.instance.languageCode;
    final languages = [
      {'code': 'en', 'label': l10n.languageEnglish, 'flag': '🇬🇧'},
      {'code': 'fr', 'label': l10n.languageFrench, 'flag': '🇫🇷'},
      {'code': 'ar', 'label': l10n.languageArabic, 'flag': '🇸🇦'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: languages.map((lang) {
        final code = lang['code']!;
        final label = lang['label']!;
        final flag = lang['flag']!;
        final isSelected = currentCode == code;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              LocaleController.instance.setLocale(Locale(code));
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD54F) : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppFonts.bangers(
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF3E2723) : Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumTile(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: PremiumService.instance,
      builder: (context, _) {
        final premium = PremiumService.instance.isPremium;
        return _buildKenneyButton(
          premium ? l10n.premiumActive : l10n.removeAds,
          premium ? Icons.workspace_premium_rounded : Icons.block_rounded,
          () {
            if (!premium) PremiumDialog.show(context);
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppFonts.bangers(
          fontSize: 14,
          color: const Color(0xFFFFD54F),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.bangers(fontSize: 16, color: Colors.white70),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeThumbColor: const Color(0xFF689F38),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(AppLocalizations l10n) {
    final difficulties = [l10n.easy, l10n.medium, l10n.hard];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: difficulties.asMap().entries.map((entry) {
        final idx = entry.key;
        final isSel = _difficultyIndex == idx;
        final colors = [
          const Color(0xFF689F38),
          const Color(0xFFFFA000),
          const Color(0xFFD32F2F),
        ];
        return GestureDetector(
          onTap: () => setState(() => _difficultyIndex = idx),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? colors[idx] : Colors.black54,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSel ? colors[idx] : Colors.white24),
            ),
            child: Text(
              entry.value.toUpperCase(),
              style: AppFonts.bangers(
                fontSize: 12,
                color: isSel ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(AppLocalizations l10n) {
    final p = _progress?.progress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _buildStatRow(l10n.statLevel, '${p?.level ?? 1}'),
          _buildStatRow(l10n.statCoins, '${p?.coins ?? 0}'),
          _buildStatRow(l10n.statMatches, '${p?.matchesPlayed ?? 0}'),
          _buildStatRow(l10n.statWins, '${p?.matchesWon ?? 0}'),
          _buildStatRow(l10n.statStreak, '${p?.dailyStreak ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.bangers(fontSize: 14, color: Colors.white70),
          ),
          Text(
            value,
            style: AppFonts.bangers(
              fontSize: 14,
              color: const Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKenneyButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: KenneyButton(
        label: label,
        icon: icon,
        isWide: true,
        style: KenneyBtnStyle.primary,
        onPressed: onPressed,
      ),
    );
  }
}
