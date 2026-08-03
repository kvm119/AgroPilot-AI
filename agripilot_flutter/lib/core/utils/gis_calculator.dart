import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// GIS Calculation engine for spherical surface area, perimeter, and GPS track filtering.
class GisCalculator {
  static const double earthRadiusMeters = 6371008.8; // Mean earth radius in meters

  /// Calculates geodesic area of a polygon defined by LatLng coordinates in Square Meters.
  /// Uses the Spherical Shoelace formula.
  static double calculatePolygonAreaSqMeters(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double totalAngle = 0.0;
    final int numPoints = points.length;

    for (int i = 0; i < numPoints; i++) {
      final LatLng p1 = points[i];
      final LatLng p2 = points[(i + 1) % numPoints];
      final LatLng p3 = points[(i + 2) % numPoints];

      final double lat1 = _toRadians(p1.latitude);
      final double lon1 = _toRadians(p1.longitude);
      final double lat2 = _toRadians(p2.latitude);
      final double lon2 = _toRadians(p2.longitude);
      final double lat3 = _toRadians(p3.latitude);
      final double lon3 = _toRadians(p3.longitude);

      // Spherical excess component
      final double dLon12 = lon2 - lon1;
      final double dLon23 = lon3 - lon2;

      totalAngle += (dLon12) * math.sin(lat2);
    }

    double area = (totalAngle.abs()) * earthRadiusMeters * earthRadiusMeters;
    
    // Fallback planar shoelace approximation for small agricultural fields if spherical excess is near 0
    if (area < 0.1) {
      area = _calculatePlanarAreaSqMeters(points);
    }

    return area;
  }

  /// Planar approximation accurate for agricultural plots (< 10,000 acres)
  static double _calculatePlanarAreaSqMeters(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    
    final LatLng ref = points.first;
    final double refLatRad = _toRadians(ref.latitude);

    // Meters per degree latitude & longitude at reference point
    final double metersPerDegLat = 111132.92 - 559.82 * math.cos(2 * refLatRad) + 1.17 * math.cos(4 * refLatRad);
    final double metersPerDegLon = 111412.84 * math.cos(refLatRad) - 93.5 * math.cos(3 * refLatRad);

    double sum = 0.0;
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];

      final x1 = (p1.longitude - ref.longitude) * metersPerDegLon;
      final y1 = (p1.latitude - ref.latitude) * metersPerDegLat;
      final x2 = (p2.longitude - ref.longitude) * metersPerDegLon;
      final y2 = (p2.latitude - ref.latitude) * metersPerDegLat;

      sum += (x1 * y2) - (x2 * y1);
    }

    return (sum.abs()) / 2.0;
  }

  /// Converts Square Meters to Acres (1 Acre = 4046.8564224 Sq Meters)
  static double sqMetersToAcres(double sqMeters) {
    return sqMeters / 4046.8564224;
  }

  /// Converts Square Meters to Hectares (1 Hectare = 10000 Sq Meters)
  static double sqMetersToHectares(double sqMeters) {
    return sqMeters / 10000.0;
  }

  /// Calculates perimeter of a list of points in meters (Haversine summation)
  static double calculatePerimeterMeters(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    const Distance distance = Distance();
    double totalMeters = 0.0;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      totalMeters += distance.as(LengthUnit.Meter, p1, p2);
    }

    return totalMeters;
  }

  /// Calculates centroid (center of mass) of a polygon
  static LatLng calculateCentroid(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(16.3067, 80.4365);
    if (points.length == 1) return points.first;

    double sumLat = 0.0;
    double sumLon = 0.0;

    for (final p in points) {
      sumLat += p.latitude;
      sumLon += p.longitude;
    }

    return LatLng(sumLat / points.length, sumLon / points.length);
  }

  /// Filters GPS noise by enforcing a minimum movement distance threshold (in meters)
  static List<LatLng> filterGpsNoise(List<LatLng> rawTrack, {double minDistanceMeters = 2.0}) {
    if (rawTrack.length <= 1) return List.from(rawTrack);

    const Distance distance = Distance();
    final List<LatLng> filtered = [rawTrack.first];

    for (int i = 1; i < rawTrack.length; i++) {
      final prev = filtered.last;
      final curr = rawTrack[i];

      final dist = distance.as(LengthUnit.Meter, prev, curr);
      if (dist >= minDistanceMeters) {
        filtered.add(curr);
      }
    }

    return filtered;
  }

  static double _toRadians(double degree) {
    return degree * (math.pi / 180.0);
  }
}
