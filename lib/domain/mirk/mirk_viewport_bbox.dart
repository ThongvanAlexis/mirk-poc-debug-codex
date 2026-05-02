// Copyright (c) 2026 THONGVAN Alexis
// Licensed under the Good Old Software License v1.0
// See LICENSE file for details

/// Immutable lat/lon viewport bounds used by fog geometry.
///
/// `east < west` is permitted only for a viewport crossing the antimeridian,
/// matching the parent MirkFall bbox convention without pulling in Freezed.
class MirkViewportBbox {
  const MirkViewportBbox({required this.south, required this.west, required this.north, required this.east})
    : assert(south <= north, 'MirkViewportBbox: south must be <= north'),
      assert(west <= east || (west > 0.0 && east < 0.0), 'MirkViewportBbox: east < west only permitted on antimeridian wrap');

  final double south;
  final double west;
  final double north;
  final double east;

  bool get crossesAntimeridian => east < west;

  double get longitudeSpanDegrees {
    if (!crossesAntimeridian) return east - west;
    return east + 360.0 - west;
  }

  double normalizeLongitudeForProjection(double lon) {
    if (!crossesAntimeridian) return lon;
    return lon < west ? lon + 360.0 : lon;
  }

  double get projectionWest => west;

  double get projectionEast => crossesAntimeridian ? east + 360.0 : east;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MirkViewportBbox && other.south == south && other.west == west && other.north == north && other.east == east;
  }

  @override
  int get hashCode => Object.hash(south, west, north, east);

  @override
  String toString() => 'MirkViewportBbox(south: $south, west: $west, north: $north, east: $east)';
}
