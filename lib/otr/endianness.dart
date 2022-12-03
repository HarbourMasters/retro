import 'dart:typed_data';

enum Endianness {
  big(1),
  little(0);

  const Endianness(this.value);
  final int value;

  static Endianness get native => Endian.host == Endian.little ? Endianness.little : Endianness.big;

  static Endianness fromValue(int value) {
    return Endianness.values.firstWhere((Endianness endianness) => endianness.value == value);
  }
}