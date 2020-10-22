import 'package:geolocator/geolocator.dart';

double distanceCalculator(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  return Geolocator.distanceBetween(
      startLatitude, startLongitude, endLatitude, endLongitude);
}
