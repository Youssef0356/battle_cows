import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../router/app_router.dart';

class ResultScreen extends StatelessWidget {
  final String winner;
  final Map<String, int> scores;

  const ResultScreen({
    super.key,
    required this.winner,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '\ud83c\udfc6',
                      style: TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      winner == 'Draw' ? 'DRAW!' : '$winner WINS!',
                      style: GoogleFonts.bangers(
                        fontSize: 44,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: AppColors.primaryAction.withValues(alpha: 0.6),
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FINAL SCORES',
                            style: GoogleFonts.bangers(
                              fontSize: 22,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...scores.entries.map((entry) {
                            final name = entry.key;
                            final score = entry.value;
                            final isWinner = name == winner;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isWinner
                                      ? AppColors.primaryAction.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isWinner
                                      ? Border.all(
                                          color: AppColors.primaryAction,
                                          width: 2,
                                        )
                                      : Border.all(
                                          color: Colors.white.withValues(alpha: 0.1),
                                        ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name.toUpperCase(),
                                      style: GoogleFonts.bangers(
                                        fontSize: 20,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      '$score TILES',
                                      style: GoogleFonts.bangers(
                                        fontSize: 20,
                                        color: isWinner
                                            ? AppColors.primaryAction
                                            : Colors.white.withValues(alpha: 0.7),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondaryAction,
                                  AppColors.secondaryAction.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRouter.home,
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Text(
                                'MENU',
                                style: GoogleFonts.bangers(
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      offset: const Offset(2, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
