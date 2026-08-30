import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/game_button_styles.dart';
import '../../game/models/player.dart';
import '../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _playerCount = 2;
  List<Player> _players = [];
  late AnimationController _animController;
  late Animation<double> _titleScale;

  @override
  void initState() {
    super.initState();
    _updatePlayers();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _titleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updatePlayers() {
    _players = [];
    final colors = [PlayerColor.blue, PlayerColor.red, PlayerColor.yellow, PlayerColor.purple];
    final names = ['Blue', 'Red', 'Yellow', 'Purple'];

    for (var i = 0; i < _playerCount; i++) {
      _players.add(Player(
        id: i,
        name: names[i],
        color: colors[i],
        isAi: i > 0,
      ));
    }
  }

  void _startGame() {
    Navigator.pushNamed(
      context,
      AppRouter.tilePlacement,
      arguments: {
        'players': _players,
        'tilesPerPlayer': 5,
      },
    );
  }

  void _showTutorial() {
    Navigator.pushNamed(context, AppRouter.tutorial);
  }

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _titleScale,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Background/Title Text.png',
                            width: 280,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Claim the pasture, outsmart your rivals!',
                            style: GoogleFonts.bangers(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildPlayerCountSelector(),
                    const SizedBox(height: 24),
                    _buildPlayerList(),
                    const SizedBox(height: 32),
                    GameButtonStyles.primaryButton(
                      text: 'START GAME',
                      onPressed: _startGame,
                      width: double.infinity,
                      height: 60,
                    ),
                    const SizedBox(height: 16),
                    GameButtonStyles.secondaryButton(
                      text: 'HOW TO PLAY',
                      onPressed: _showTutorial,
                      width: 200,
                      height: 48,
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

  Widget _buildPlayerCountSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground.withValues(alpha: 0.95),
            AppColors.cardBackground.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'PLAYERS',
            style: GoogleFonts.bangers(
              fontSize: 22,
              color: AppColors.darkText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [2, 3, 4].map((count) {
              final isSelected = _playerCount == count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _playerCount = count;
                      _updatePlayers();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [
                                AppColors.secondaryAction.withValues(alpha: 0.3),
                                AppColors.secondaryAction.withValues(alpha: 0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.white : AppColors.secondaryAction,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryAction.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: GoogleFonts.bangers(
                          fontSize: 32,
                          color: isSelected ? Colors.white : AppColors.darkText,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground.withValues(alpha: 0.95),
            AppColors.cardBackground.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ROSTER',
            style: GoogleFonts.bangers(
              fontSize: 22,
              color: AppColors.darkText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ..._players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.getPlayerPrimary(player.color),
                            AppColors.getPlayerDark(player.color),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getPlayerPrimary(player.color).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.bangers(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        player.name,
                        style: GoogleFonts.bangers(
                          fontSize: 18,
                          color: AppColors.darkText,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: player.isAi
                            ? AppColors.secondaryAction.withValues(alpha: 0.3)
                            : AppColors.primaryAction.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: player.isAi
                              ? AppColors.secondaryAction
                              : AppColors.primaryAction,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        player.isAi ? 'CPU' : 'YOU',
                        style: GoogleFonts.bangers(
                          fontSize: 14,
                          color: player.isAi
                              ? AppColors.secondaryAction
                              : AppColors.primaryAction,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
