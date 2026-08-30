import 'package:flutter/foundation.dart';

class GameProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void startNewGame() {
    _isLoading = true;
    notifyListeners();
    // TODO: Implement game start
    _isLoading = false;
    notifyListeners();
  }
}
