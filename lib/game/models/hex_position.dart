class HexPosition {
  final int q;
  final int r;

  const HexPosition(this.q, this.r);

  int get s => -q - r;

  HexPosition operator +(HexPosition other) {
    return HexPosition(q + other.q, r + other.r);
  }

  HexPosition operator -(HexPosition other) {
    return HexPosition(q - other.q, r - other.r);
  }

  HexPosition operator *(int scalar) {
    return HexPosition(q * scalar, r * scalar);
  }

  double distanceTo(HexPosition other) {
    final diff = this - other;
    return ((diff.q.abs() + diff.r.abs() + diff.s.abs()) / 2).toDouble();
  }

  List<HexPosition> neighbors() {
    return const [
      HexPosition(1, 0),
      HexPosition(1, -1),
      HexPosition(0, -1),
      HexPosition(-1, 0),
      HexPosition(-1, 1),
      HexPosition(0, 1),
    ].map((d) => this + d).toList();
  }

  static const List<HexPosition> directions = [
    HexPosition(1, 0),
    HexPosition(1, -1),
    HexPosition(0, -1),
    HexPosition(-1, 0),
    HexPosition(-1, 1),
    HexPosition(0, 1),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexPosition && runtimeType == other.runtimeType && q == other.q && r == other.r;

  @override
  int get hashCode => q.hashCode ^ r.hashCode;

  @override
  String toString() => '($q, $r)';
}
