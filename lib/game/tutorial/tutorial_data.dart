import 'package:flutter/material.dart';

enum TutorialPhase {
  tilePlacement,
  herdPlacement,
  gameplay,
}

class TutorialStep {
  final String title;
  final String description;
  final TutorialPhase phase;
  final Color accentColor;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.phase,
    this.accentColor = const Color(0xFFFFD54F),
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
      description: 'Tap the board to place tiles and build the playing field. Tap ROTATE to change the tile shape before placing.',
      phase: TutorialPhase.tilePlacement,
      accentColor: Color(0xFF42A5F5),
    ),
    TutorialStep(
      title: 'PLACE YOUR HERD',
      description: 'Now tap a highlighted hex to place your herd of cows. This is your starting position!',
      phase: TutorialPhase.herdPlacement,
      accentColor: Color(0xFF66BB6A),
    ),
    TutorialStep(
      title: 'SELECT YOUR HERD',
      description: 'Tap your herd to select it. Drag the slider to choose how many cows split off, then tap a destination hex to move!',
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFFFB74D),
    ),
    TutorialStep(
      title: 'CAPTURE TERRITORY',
      description: 'Move onto empty hexes to capture them, or onto enemy herds to capture them! Most territory wins.',
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFE74C3C),
    ),
  ];
}
