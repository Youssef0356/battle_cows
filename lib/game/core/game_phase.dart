/// Explicit state machine phases for Battle Cows.
enum GamePhase {
  setup,
  playerTurn,
  selectingStack,
  selectingAmount,
  selectingDestination,
  animatingMove,
  turnEnd,
  gameOver,
  paused;

  bool get isInteractive =>
      this == GamePhase.playerTurn ||
      this == GamePhase.selectingStack ||
      this == GamePhase.selectingAmount ||
      this == GamePhase.selectingDestination;

  bool get isBusy => this == GamePhase.animatingMove || this == GamePhase.setup;
}
