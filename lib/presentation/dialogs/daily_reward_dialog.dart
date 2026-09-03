import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/progress_service.dart';

class DailyRewardDialog extends StatelessWidget {
  final ProgressService progress;
  final int rewardAmount;

  const DailyRewardDialog({
    super.key,
    required this.progress,
    required this.rewardAmount,
  });

  @override
  Widget build(BuildContext context) {
    final streak = progress.progress.dailyStreak;

    return AlertDialog(
      backgroundColor: const Color(0xFF2E1C0C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFD54F), width: 3),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎁', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            'DAILY REWARD!',
            style: GoogleFonts.bangers(
              fontSize: 24,
              color: const Color(0xFFFFD54F),
              letterSpacing: 2,
            ),
          ),
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
        ],
      ),
      actions: [
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF689F38), Color(0xFF33691E)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                'CLAIM',
                style: GoogleFonts.bangers(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
