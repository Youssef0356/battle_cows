import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/progress_service.dart';
import '../widgets/cartoon_dialog.dart';

class DailyRewardDialog extends StatelessWidget {
  final ProgressService progress;
  final int rewardAmount;

  const DailyRewardDialog({
    super.key,
    required this.progress,
    required this.rewardAmount,
  });

  static Future<void> show({
    required BuildContext context,
    required ProgressService progress,
    required int rewardAmount,
    bool barrierDismissible = false,
  }) {
    return CartoonDialog.show(
      context: context,
      title: 'DAILY REWARD!',
      dismissible: barrierDismissible,
      child: _DailyRewardContent(progress: progress, rewardAmount: rewardAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DailyRewardContent(progress: progress, rewardAmount: rewardAmount);
  }
}

class _DailyRewardContent extends StatelessWidget {
  final ProgressService progress;
  final int rewardAmount;

  const _DailyRewardContent({required this.progress, required this.rewardAmount});

  @override
  Widget build(BuildContext context) {
    final streak = progress.progress.dailyStreak;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎁', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Day $streak Streak!',
                style: GoogleFonts.bangers(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Text(
                    '+$rewardAmount',
                    style: GoogleFonts.bangers(
                      fontSize: 32,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Come back tomorrow for +${50 + ((streak + 1).clamp(1, 7)) * 25} coins!',
                style: GoogleFonts.bangers(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CartoonButton(
          label: 'CLAIM',
          icon: Icons.card_giftcard,
          isWide: true,
          baseColor: const Color(0xFF689F38),
          borderColor: const Color(0xFF8BC34A),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
