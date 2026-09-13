import 'package:flutter/material.dart';

enum TutorialTarget {
  rotateButton,
  placeButton,
  boardHex,
  playerHerd,
  splitSlider,
  destinationHex,
  scoreboard,
  enemyHerd,
  none,
}

enum TutorialPhase {
  tilePlacement,
  herdPlacement,
  gameplay,
}

class TutorialStep {
  final String title;
  final String description;
  final TutorialTarget target;
  final TutorialPhase phase;
  final Color accentColor;
  final bool requiresTap;
  final VoidCallback? onAdvance;
  final String? tooltipPosition;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.target,
    required this.phase,
    this.accentColor = const Color(0xFFFFD54F),
    this.requiresTap = true,
    this.onAdvance,
    this.tooltipPosition,
  });
}

class TutorialScenario {
  static const int playerCount = 2;
  static const int herdSize = 16;
  static const int tilesPerPlayer = 3;
  static const int boardSize = 7;

  static const List<TutorialStep> steps = [
    TutorialStep(
      title: 'BUILD THE PASTURE',
      description: 'First, you build the board by placing tiles. Use ROTATE to change the tile shape.',
      target: TutorialTarget.rotateButton,
      phase: TutorialPhase.tilePlacement,
      accentColor: Color(0xFF42A5F5),
    ),
    TutorialStep(
      title: 'PLACE YOUR TILE',
      description: 'Tap anywhere on the board to position the tile, then press PLACE to confirm.',
      target: TutorialTarget.placeButton,
      phase: TutorialPhase.tilePlacement,
      accentColor: Color(0xFF66BB6A),
    ),
    TutorialStep(
      title: 'PLACE YOUR HERD',
      description: 'Now place your herd of cows on a highlighted hex. This is where your cows start!',
      target: TutorialTarget.boardHex,
      phase: TutorialPhase.herdPlacement,
      accentColor: Color(0xFF42A5F5),
    ),
    TutorialStep(
      title: 'SELECT YOUR HERD',
      description: 'Tap your herd to select it. You need at least 2 cows to move!',
      target: TutorialTarget.playerHerd,
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFF42A5F5),
    ),
    TutorialStep(
      title: 'SPLIT YOUR COWS',
      description: 'Drag the slider to choose how many cows split off and move. The rest stay behind.',
      target: TutorialTarget.splitSlider,
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFFFB74D),
    ),
    TutorialStep(
      title: 'MOVE YOUR COWS',
      description: 'Tap a highlighted hex to move your cows there. They slide in a straight line!',
      target: TutorialTarget.destinationHex,
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFF66BB6A),
    ),
    TutorialStep(
      title: 'CHECK THE SCORE',
      description: 'The scoreboard shows territory and cow count for each player. Most territory wins!',
      target: TutorialTarget.scoreboard,
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFAB47BC),
      requiresTap: false,
    ),
    TutorialStep(
      title: 'CAPTURE ENEMIES!',
      description: 'Move onto an enemy herd to CAPTURE it! Your cows replace theirs.',
      target: TutorialTarget.enemyHerd,
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFE74C3C),
    ),
  ];
}
