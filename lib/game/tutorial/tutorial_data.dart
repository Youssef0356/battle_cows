import 'package:flutter/material.dart';

enum TutorialPhase {
  tilePlacement,
  herdPlacement,
  gameplay,
}

/// Game events that auto-advance a tutorial step once the player performs
/// the taught action.
enum TutorialEvent {
  tilePlacementDone,
  herdPlacementDone,
  /// The local player completed a move (fires on every one of their moves;
  /// whichever step is showing consumes the next one).
  playerMove,
}

class TutorialStep {
  final String title;
  final String description;
  final TutorialPhase phase;
  final Color accentColor;

  /// Intro/outro cards cover the screen until acknowledged; action steps are
  /// compact coach banners that let the player interact with the board.
  final bool blocking;

  /// Game event that auto-advances this step (null = button-only).
  final TutorialEvent? advanceOn;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.phase,
    this.accentColor = const Color(0xFFFFD54F),
    this.blocking = false,
    this.advanceOn,
  });
}

class TutorialScenario {
  static const int playerCount = 2;
  static const int herdSize = 16;
  static const int tilesPerPlayer = 3;
  static const int boardSize = 7;

  static const List<TutorialStep> steps = [
    TutorialStep(
      title: 'WELCOME, COWPUNCHER!',
      description:
          'In this quick match you\'ll learn everything you need. Goal: fill the pasture — when the board is full, the player with the BIGGEST herd wins!',
      phase: TutorialPhase.tilePlacement,
      accentColor: Color(0xFFFFD54F),
      blocking: true,
    ),
    TutorialStep(
      title: 'BUILD THE PASTURE',
      description:
          'Tap the board to drop your pasture tiles. Press ROTATE to turn a tile first. Tap the glowing button to place it!',
      phase: TutorialPhase.tilePlacement,
      accentColor: Color(0xFF42A5F5),
      advanceOn: TutorialEvent.tilePlacementDone,
    ),
    TutorialStep(
      title: 'PLACE YOUR HERD',
      description:
          'Now tap a glowing hex on the edge to drop your herd of 16 cows. That\'s your home base!',
      phase: TutorialPhase.herdPlacement,
      accentColor: Color(0xFF66BB6A),
      advanceOn: TutorialEvent.herdPlacementDone,
    ),
    TutorialStep(
      title: 'SELECT & MOVE',
      description:
          'Tap YOUR herd to select it. Use the slider to choose how many cows split off, then tap a lit hex to move!',
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFFFB74D),
      advanceOn: TutorialEvent.playerMove,
    ),
    TutorialStep(
      title: 'CLAIM TO WIN',
      description:
          'Every hex you reach becomes yours. Keep splitting and expanding — when the pasture is full, the player with the MOST hexes wins!',
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFFE74C3C),
      advanceOn: TutorialEvent.playerMove,
    ),
    TutorialStep(
      title: 'YOU\'RE READY!',
      description:
          'That\'s the whole game! Expand your territory, crush rival herds, and when the pasture is full — count the cows. HAVE FUN!',
      phase: TutorialPhase.gameplay,
      accentColor: Color(0xFF81C784),
      blocking: true,
    ),
  ];
}
