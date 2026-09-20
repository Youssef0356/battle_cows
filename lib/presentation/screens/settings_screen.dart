import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD54F),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.bangers(fontSize: 24, letterSpacing: 2),
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
                  _buildSectionHeader('Audio'),
                  _buildToggleRow(
                    '🔊 Sound Effects',
                    _soundEnabled,
                    () => setState(() => _soundEnabled = !_soundEnabled),
                  ),
                  _buildToggleRow(
                    '🎵 Music',
                    _musicEnabled,
                    () => setState(() => _musicEnabled = !_musicEnabled),
                  ),
                  _buildToggleRow(
                    '📳 Haptic Feedback',
                    _hapticEnabled,
                    () => setState(() => _hapticEnabled = !_hapticEnabled),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Game'),
                  _buildDifficultySelector(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Account'),
                  _buildStatCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Support'),
                  _buildKenneyButton('SHARE', Icons.share, () {
                    Share.share(
                      'Check out Battle Cows! 🐮 https://play.google.com/store/apps/details?id=com.battlecows.game',
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildKenneyButton('RATE', Icons.star, () async {
                    final inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  }),
                  const SizedBox(height: 10),
                  _buildKenneyButton('EXIT', Icons.exit_to_app_rounded, () {
                    CartoonDialog.show(
                      context: context,
                      title: 'EXIT GAME?',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure you want to exit?',
                            style: GoogleFonts.bangers(
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
                                  label: 'CANCEL',
                                  isWide: true,
                                  style: KenneyBtnStyle.neutral,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Builder(
                                  builder: (context) => KenneyButton(
                                    label: 'EXIT',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.bangers(
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
            style: GoogleFonts.bangers(fontSize: 16, color: Colors.white70),
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

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['EASY', 'MEDIUM', 'HARD'].asMap().entries.map((entry) {
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? colors[idx] : Colors.black54,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSel ? colors[idx] : Colors.white24),
            ),
            child: Text(
              entry.value,
              style: GoogleFonts.bangers(
                fontSize: 12,
                color: isSel ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard() {
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
          _buildStatRow('⭐ Level', '1'),
          _buildStatRow('💰 Coins', '0'),
          _buildStatRow('⚔️ Matches', '0'),
          _buildStatRow('🥇 Wins', '0'),
          _buildStatRow('🔥 Streak', '0'),
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
            style: GoogleFonts.bangers(fontSize: 14, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.bangers(
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
