import 'package:flutter/material.dart';

enum AppState {
  none,
  creation,
}

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;

  void onCreationState() {
    currentState = AppState.creation;
    notifyListeners();
  }
}
