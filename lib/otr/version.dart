enum Version {
  // 1982: Bladerunner
  unknown(-1),
  deckard(0),
  roy(1),
  rachael(2),
  zhora(3),
  // 1982: Tron
  flynn(4),
  bradley(5);

  const Version(this.value);
  final int value;

  static Version fromValue(int value) {
    return Version.values.firstWhere((Version version) => version.value == value);
  }
}