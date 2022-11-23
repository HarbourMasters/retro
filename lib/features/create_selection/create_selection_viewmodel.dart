import 'package:flutter/material.dart';

class CreateSelectionViewModel with ChangeNotifier {
  onReplaceModelsCardFocused() {}
  onCustomCardFocused() {}

  onCardFocusLost() {
    notifyListeners();
  }
}
