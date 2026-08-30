import 'package:flutter/material.dart';
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
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedMove != null) ...[
            Text(
              'Split: $splitCount cows move, ${selectedMove!.stayCount - splitCount + 1} stay',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: splitCount.toDouble(),
              min: 1,
              max: (selectedMove!.stayCount + splitCount - 1).toDouble(),
              divisions: selectedMove!.stayCount + splitCount - 2,
              label: '$splitCount cows',
              activeColor: AppColors.primaryAction,
              onChanged: (value) => onSplitChanged(value.round()),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onCancelMove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryAction,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canConfirm ? onConfirmMove : null,
                child: const Text('Confirm Move'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
