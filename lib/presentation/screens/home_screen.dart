import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../game/models/player.dart';
import '../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _playerCount = 2;
  List<Player> _players = [];
  int _boardSize = 7;

  @override
  void initState() {
    super.initState();
    _updatePlayers();
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

    _boardSize = _getBoardSize(_playerCount);
  }

  int _getBoardSize(int playerCount) {
    switch (playerCount) {
      case 2:
        return 7;
      case 3:
        return 9;
      case 4:
        return 10;
      default:
        return 7;
    }
  }

  void _startGame() {
    Navigator.pushNamed(
      context,
      AppRouter.game,
      arguments: {
        'players': _players,
        'boardSize': _boardSize,
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
              color: Colors.black.withValues(alpha: 0.3),
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
                      '🐄',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'BATTLE COWS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightText,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Claim the pasture, outsmart your rivals!',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.lightText.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildPlayerCountSelector(),
                    const SizedBox(height: 24),
                    _buildPlayerList(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAction,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'START GAME',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _showTutorial,
                      child: const Text(
                        'How to Play',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.lightText,
                        ),
                      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Number of Players',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
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
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryAction
                          : AppColors.secondaryAction.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryAction
                            : AppColors.secondaryAction,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Board: $_boardSize hexes per side',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Players',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ..._players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.getPlayerPrimary(player.color),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: player.isAi
                          ? AppColors.secondaryAction.withValues(alpha: 0.2)
                          : AppColors.primaryAction.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      player.isAi ? 'AI' : 'Human',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: player.isAi
                            ? AppColors.secondaryAction
                            : AppColors.primaryAction,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
