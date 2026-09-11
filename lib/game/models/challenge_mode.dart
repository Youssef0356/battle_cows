enum ChallengeMode {
  standard,
  noTimer,
  goldenPasture,
  kingOfTheHill,
}

extension ChallengeModeDetails on ChallengeMode {
  String get title {
    switch (this) {
      case ChallengeMode.standard:
        return 'STANDARD PASTURE';
      case ChallengeMode.noTimer:
        return 'NO-TIMER STRATEGY';
      case ChallengeMode.goldenPasture:
        return 'GOLDEN PASTURE';
      case ChallengeMode.kingOfTheHill:
        return 'KING OF THE HILL';
    }
  }

  String get description {
    switch (this) {
      case ChallengeMode.standard:
        return 'Classic territory battle.';
      case ChallengeMode.noTimer:
        return 'Think as long as you need. No hearts lost.';
      case ChallengeMode.goldenPasture:
        return 'Capture the glowing pasture for bonus glory.';
      case ChallengeMode.kingOfTheHill:
        return 'Hold the center and control the hill.';
    }
  }

  String get icon {
    switch (this) {
      case ChallengeMode.standard:
        return '🌾';
      case ChallengeMode.noTimer:
        return '🧠';
      case ChallengeMode.goldenPasture:
        return '👑';
      case ChallengeMode.kingOfTheHill:
        return '⛰️';
    }
  }
}
