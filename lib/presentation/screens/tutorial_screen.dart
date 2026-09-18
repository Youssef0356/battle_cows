import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'HOW TO PLAY',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: const Color(0xFFFFD54F),
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              icon: '🎯',
              title: 'OBJECTIVE',
              body: 'Control more territory than your opponent by the end of the game. The player with the most hex tiles wins!',
            ),
            _buildSection(
              icon: '🐮',
              title: 'PLACING COWS',
              body: 'After placing all your tiles, you get cows on your starting hexes. Each herd has a number of cows.',
            ),
            _buildSection(
              icon: '➡️',
              title: 'MOVING COWS',
              body: 'On your turn, select a herd and choose how many cows to move to an adjacent hex. Keep at least 1 cow behind!',
            ),
            _buildSection(
              icon: '🏴',
              title: 'TERRITORY',
              body: 'Move onto unclaimed hexes to capture them for your color. Move onto enemy hexes to steal their territory!',
            ),
            _buildSection(
              icon: '⚔️',
              title: 'COMBAT',
              body: 'When you move onto an enemy herd, the stronger herd wins. Equal strength = both survive. Loser loses 1 heart.',
            ),
            _buildSection(
              icon: '❤️',
              title: 'HEARTS',
              body: 'Each player starts with 3 hearts. Lose all 3 and you are eliminated!',
            ),
            _buildSection(
              icon: '🗺️',
              title: 'SPECIAL TILES',
              body: 'Hills give defense bonuses. Hay bales block movement. Water ponds slow movement. Golden pastures score extra!',
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  ),
                  child: Text(
                    'GOT IT!',
                    style: GoogleFonts.bangers(
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bangers(
                    fontSize: 16,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.bangers(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
