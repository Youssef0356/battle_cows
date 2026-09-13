import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../game/models/player.dart';
import '../../game/tutorial/tutorial_data.dart';
import 'flame_game_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorialGame();
    });
  }

  void _startTutorialGame() {
    final players = [
      Player(
        id: 0,
        name: 'Player 1',
        color: PlayerColor.blue,
        isAi: false,
      ),
      Player(
        id: 1,
        name: 'AI Cow',
        color: PlayerColor.red,
        isAi: true,
      ),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlameGameScreen(
          players: players,
          herdSize: TutorialScenario.herdSize,
          boardSize: TutorialScenario.boardSize,
          tilesPerPlayer: TutorialScenario.tilesPerPlayer,
          isTutorial: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFD54F),
        ),
      ),
    );
  }
}
