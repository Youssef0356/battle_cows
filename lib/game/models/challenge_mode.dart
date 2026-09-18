enum ChallengeMode {
  standard,
  timed,
  fenceChallenge,
  goldenPasture,
  kingOfTheHill,
}

extension ChallengeModeDetails on ChallengeMode {
  bool get hasTimer => this == ChallengeMode.timed;
  bool get isFenceBattle => this == ChallengeMode.fenceChallenge;

  bool get hasObjective =>
      this == ChallengeMode.goldenPasture || this == ChallengeMode.kingOfTheHill;

  String get title {
    switch (this) {
      case ChallengeMode.standard:
        return 'STANDARD PASTURE';
      case ChallengeMode.timed:
        return 'TIMED STRATEGY';
      case ChallengeMode.fenceChallenge:
        return 'FENCE BATTLE';
      case ChallengeMode.goldenPasture:
        return 'GOLDEN PASTURE';
      case ChallengeMode.kingOfTheHill:
        return 'KING OF THE HILL';
    }
  }

  String get description {
    switch (this) {
      case ChallengeMode.standard:
        return 'Classic territory battle. No turn timer.';
      case ChallengeMode.timed:
        return 'Every turn is on the clock. Run out of time and lose a heart.';
      case ChallengeMode.fenceChallenge:
        return 'Place & move wooden fences each turn to block and trap enemy herds!';
      case ChallengeMode.goldenPasture:
        return 'Hold the golden pasture each turn to bank gold. First to 5 wins.';
      case ChallengeMode.kingOfTheHill:
        return 'Stay on the hill for 3 turns in a row to be crowned.';
    }
  }

  String get icon {
    switch (this) {
      case ChallengeMode.standard:
        return '🌾';
      case ChallengeMode.timed:
        return '⏱️';
      case ChallengeMode.fenceChallenge:
        return '🪵';
      case ChallengeMode.goldenPasture:
        return '👑';
      case ChallengeMode.kingOfTheHill:
        return '⛰️';
    }
  }
}
