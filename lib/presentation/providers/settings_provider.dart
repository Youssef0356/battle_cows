import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }
}
