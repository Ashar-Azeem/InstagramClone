import 'package:flutter/material.dart';

class AppStateModel extends ChangeNotifier {
  bool shouldRebuildView = false;

  void updateRebuildState(bool value) {
    shouldRebuildView = value;
    notifyListeners(); // Notify listeners of the change
  }
}
