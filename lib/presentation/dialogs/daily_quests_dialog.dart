import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/player_progress.dart';
import '../../data/services/progress_service.dart';
import '../widgets/cartoon_dialog.dart';

class DailyQuestsDialog extends StatefulWidget {
  final ProgressService progress;

  const DailyQuestsDialog({super.key, required this.progress});

  static Future<void> show({
    required BuildContext context,
    required ProgressService progress,
  }) {
    return CartoonDialog.show(
      context: context,
      title: 'DAILY QUESTS',
      accentColor: const Color(0xFF81C784),
      child: DailyQuestsDialog(progress: progress),
    );
  }

  @override
  State<DailyQuestsDialog> createState() => _DailyQuestsDialogState();
}

class _DailyQuestsDialogState extends State<DailyQuestsDialog> {
  @override
  Widget build(BuildContext context) {
    widget.progress.refreshDailyQuests();
    final quests = widget.progress.progress.dailyQuests;

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Complete tactics, claim coins, and level up your herd.',
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 10),
          _buildProgressSummary(quests),
          const SizedBox(height: 12),
          ...quests.map((quest) => _buildQuestTile(quest)),
          const SizedBox(height: 12),
          CartoonButton(
            label: 'CLOSE',
            isWide: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(List<QuestProgress> quests) {
    final complete = quests.where((quest) => quest.isComplete).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF385C2B), Color(0xFF1E3319)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Row(
        children: [
          const Text('🐮', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(child: Text('$complete/${quests.length} tactics ready', style: GoogleFonts.bangers(fontSize: 16, color: Colors.white))),
          Text('TODAY', style: GoogleFonts.bangers(fontSize: 12, color: const Color(0xFFFFD54F), letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildQuestTile(QuestProgress quest) {
    final canClaim = quest.isComplete && !quest.claimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: quest.claimed
            ? Colors.white.withValues(alpha: 0.05)
            : canClaim
                ? const Color(0xFF81C784).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quest.claimed
              ? Colors.white12
              : canClaim
                  ? const Color(0xFF81C784)
                  : Colors.white24,
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(quest.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: GoogleFonts.bangers(
                    fontSize: 14,
                    color: quest.claimed ? Colors.white38 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: GoogleFonts.bangers(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          minHeight: 6,
                          backgroundColor: Colors.black26,
                          valueColor: AlwaysStoppedAnimation(
                            quest.isComplete ? const Color(0xFF81C784) : const Color(0xFFFFD54F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${quest.current}/${quest.target}',
                      style: GoogleFonts.bangers(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (quest.claimed)
            const Icon(Icons.check_circle, color: Colors.white24, size: 28)
          else
            GestureDetector(
              onTap: canClaim
                  ? () {
                      setState(() {
                        widget.progress.claimQuest(
                          widget.progress.progress.dailyQuests.indexOf(quest),
                        );
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: canClaim
                      ? const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFF9A825)])
                      : null,
                  color: canClaim ? null : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  canClaim ? '+${quest.coinReward}' : '💰${quest.coinReward}',
                  style: GoogleFonts.bangers(
                    fontSize: 13,
                    color: canClaim ? Colors.black : Colors.white54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
