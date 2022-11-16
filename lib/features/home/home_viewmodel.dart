import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  String focusedCardInfo = infoMadeWithLove;

  onCreateOTRCardFocused() {
    focusedCardInfo = "Create an OTR for SoH";
    notifyListeners();
  }

  onCardFocusLost() {
    focusedCardInfo = infoMadeWithLove;
    notifyListeners();
  }

  static String infoMadeWithLove = "Made with ❤️";
}
