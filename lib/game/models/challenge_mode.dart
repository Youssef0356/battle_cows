enum ChallengeMode {
  standard,
  timed,
  fenceChallenge,
}

extension ChallengeModeDetails on ChallengeMode {
  bool get hasTimer => this == ChallengeMode.timed;
  bool get isFenceBattle => this == ChallengeMode.fenceChallenge;
  bool get hasObjective => false;

  String get title {
    switch (this) {
      case ChallengeMode.standard:
        return 'STANDARD PASTURE';
      case ChallengeMode.timed:
        return 'TIMED STRATEGY';
      case ChallengeMode.fenceChallenge:
        return 'FENCE BATTLE';
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
    }
  }
}
