import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;

/// Axial Hex Coordinate representation (q, r) where s = -q - r.
class HexCoordinate {
  final int q;
  final int r;

  const HexCoordinate(this.q, this.r);

  int get s => -q - r;

  /// Six directional vectors in axial coordinates.
  static const List<HexCoordinate> directions = [
    HexCoordinate(1, 0), // E
    HexCoordinate(1, -1), // NE
    HexCoordinate(0, -1), // NW
    HexCoordinate(-1, 0), // W
    HexCoordinate(-1, 1), // SW
    HexCoordinate(0, 1), // SE
  ];

  /// Get the neighbor in one of the 6 directions (0..5).
  HexCoordinate neighbor(int directionIndex) {
    final dir = directions[directionIndex % 6];
    return HexCoordinate(q + dir.q, r + dir.r);
  }

  /// All 6 immediate neighbors.
  List<HexCoordinate> get neighbors => [
    for (int i = 0; i < 6; i++) neighbor(i),
  ];

  /// Hex distance between this coordinate and [other].
  int distanceTo(HexCoordinate other) {
    return ((q - other.q).abs() +
            (r - other.r).abs() +
            (s - other.s).abs()) ~/
        2;
  }

  /// Coordinate addition.
  HexCoordinate operator +(HexCoordinate other) =>
      HexCoordinate(q + other.q, r + other.r);

  /// Coordinate subtraction.
  HexCoordinate operator -(HexCoordinate other) =>
      HexCoordinate(q - other.q, r - other.r);

  /// Scale coordinate.
  HexCoordinate scale(int factor) => HexCoordinate(q * factor, r * factor);

  /// Convert axial coordinate to 3D world position (pointy-topped hex).
  ///
  /// For pointy-topped hexes with radius R:
  /// X = R * sqrt(3) * (q + r / 2)
  /// Z = R * (3/2) * r
  /// Y = height elevation
  vm.Vector3 toWorldPosition({
    double radius = 1.0,
    double spacing = 0.05,
    double elevation = 0.0,
  }) {
    final effectiveRadius = radius + spacing;
    final x = effectiveRadius * math.sqrt(3) * (q + r / 2.0);
    final z = effectiveRadius * 1.5 * r;
    return vm.Vector3(x, elevation, z);
  }

  /// Convert 3D world position (x, z) to fractional axial coordinates, then round to nearest integer HexCoordinate.
  static HexCoordinate fromWorldPosition(
    vm.Vector3 position, {
    double radius = 1.0,
    double spacing = 0.05,
  }) {
    final effectiveRadius = radius + spacing;
    final x = position.x;
    final z = position.z;

    final qFrac = (math.sqrt(3) / 3 * x - 1.0 / 3 * z) / effectiveRadius;
    final rFrac = (2.0 / 3 * z) / effectiveRadius;
    final sFrac = -qFrac - rFrac;

    int qRound = qFrac.round();
    int rRound = rFrac.round();
    int sRound = sFrac.round();

    final qDiff = (qRound - qFrac).abs();
    final rDiff = (rRound - rFrac).abs();
    final sDiff = (sRound - sFrac).abs();

    if (qDiff > rDiff && qDiff > sDiff) {
      qRound = -rRound - sRound;
    } else if (rDiff > sDiff) {
      rRound = -qRound - sRound;
    }

    return HexCoordinate(qRound, rRound);
  }

  Map<String, dynamic> toJson() => {'q': q, 'r': r};

  factory HexCoordinate.fromJson(Map<String, dynamic> json) =>
      HexCoordinate(json['q'] as int, json['r'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexCoordinate &&
          runtimeType == other.runtimeType &&
          q == other.q &&
          r == other.r;

  @override
  int get hashCode => q.hashCode * 31 + r.hashCode;

  @override
  String toString() => 'Hex($q, $r)';
}
