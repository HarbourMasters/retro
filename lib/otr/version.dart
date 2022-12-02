enum Version {
  // 1982: Bladerunner
  deckard(0),
  roy(1),
  rachael(2),
  zhora(3),
  // 1982: Tron
  flynn(4),
  bradley(5);

  const Version(this.value);
  final int value;
}