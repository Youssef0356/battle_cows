import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

enum ChallengeMode {
  standard,
  timed,
  fenceChallenge,
  goldenPasture,
  stampedeRush,
}

extension ChallengeModeDetails on ChallengeMode {
  bool get hasTimer => this == ChallengeMode.timed;
  bool get isFenceBattle => this == ChallengeMode.fenceChallenge;
  bool get isGoldenPasture => this == ChallengeMode.goldenPasture;
  bool get isStampedeRush => this == ChallengeMode.stampedeRush;
  bool get hasObjective => this == ChallengeMode.goldenPasture;

  String localizedTitle([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (this) {
      case ChallengeMode.standard:
        return l10n.modeStandardTitle;
      case ChallengeMode.timed:
        return l10n.modeTimedTitle;
      case ChallengeMode.fenceChallenge:
        return l10n.modeFenceTitle;
      case ChallengeMode.goldenPasture:
        return l10n.modeGoldenTitle;
      case ChallengeMode.stampedeRush:
        return l10n.modeStampedeTitle;
    }
  }

  String get title => localizedTitle();

  String localizedDescription([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (this) {
      case ChallengeMode.standard:
        return l10n.modeStandardDesc;
      case ChallengeMode.timed:
        return l10n.modeTimedDesc;
      case ChallengeMode.fenceChallenge:
        return l10n.modeFenceDesc;
      case ChallengeMode.goldenPasture:
        return l10n.modeGoldenDesc;
      case ChallengeMode.stampedeRush:
        return l10n.modeStampedeDesc;
    }
  }

  String get description => localizedDescription();

  String get icon {
    switch (this) {
      case ChallengeMode.standard:
        return '🌾';
      case ChallengeMode.timed:
        return '⏱️';
      case ChallengeMode.fenceChallenge:
        return '🪵';
      case ChallengeMode.goldenPasture:
        return '🍀';
      case ChallengeMode.stampedeRush:
        return '🌱';
    }
  }
}
