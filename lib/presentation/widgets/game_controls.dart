import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../game/models/move.dart';

class GameControls extends StatelessWidget {
  final Move? selectedMove;
  final int splitCount;
  final Function(int) onSplitChanged;
  final VoidCallback onConfirmMove;
  final VoidCallback onCancelMove;
  final bool canConfirm;

  const GameControls({
    super.key,
    this.selectedMove,
    this.splitCount = 1,
    required this.onSplitChanged,
    required this.onConfirmMove,
    required this.onCancelMove,
    this.canConfirm = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedMove != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryAction.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'SPLIT: $splitCount COWS MOVE, ${selectedMove!.stayCount} STAY',
                style: GoogleFonts.bangers(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primaryAction,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayColor: AppColors.primaryAction.withValues(alpha: 0.3),
                trackHeight: 6,
              ),
              child: Slider(
                value: splitCount.toDouble(),
                min: 1,
                max: (selectedMove!.stayCount + splitCount - 1).toDouble(),
                divisions: selectedMove!.stayCount + splitCount - 2,
                label: '$splitCount cows',
                onChanged: (value) => onSplitChanged(value.round()),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryAction,
                        AppColors.secondaryAction.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onCancelMove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.bangers(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: canConfirm
                        ? const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : LinearGradient(
                            colors: [Colors.grey, Colors.grey.withValues(alpha: 0.7)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: canConfirm
                        ? [
                            BoxShadow(
                              color: AppColors.primaryAction.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: ElevatedButton(
                    onPressed: canConfirm ? onConfirmMove : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'CONFIRM',
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
          ),
        ],
      ),
    );
  }
}
