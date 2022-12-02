import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  String focusedCardInfo = infoMadeWithLove;

  onCreateOTRCardFocused(String info) {
    focusedCardInfo = info;
    notifyListeners();
  }

  onCardFocusLost() {
    focusedCardInfo = infoMadeWithLove;
    notifyListeners();
  }

  static String infoMadeWithLove = "Made with ❤️";
}
