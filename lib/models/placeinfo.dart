import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailedPlaceInfo {
  String name = '';
  String address;
  double latitude;
  double longitude;

  DetailedPlaceInfo({this.name, this.address, this.latitude, this.longitude});
}
