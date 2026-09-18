import 'package:flutter/foundation.dart';

class GameProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _gamesPlayed = 0;
  int get gamesPlayed => _gamesPlayed;

  void startNewGame() {
    _isLoading = true;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  void incrementGamesPlayed() {
    _gamesPlayed++;
    notifyListeners();
  }
}
