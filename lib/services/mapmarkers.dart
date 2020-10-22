import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartpark/models/placeinfo.dart';
import 'package:smartpark/services/distancecalculator.dart';

class MarkerList {
  Function(DetailedPlaceInfo item) markerTap;
  MarkerList({@required this.markerTap});

  Set<Marker> mapMarkers(
      List<DetailedPlaceInfo> detailedPlaceInfoList, Position localPosition) {
    Set<Marker> markersList = {};

    if (detailedPlaceInfoList != null)
      for (var item in detailedPlaceInfoList)
        if (distanceCalculator(localPosition.latitude, localPosition.longitude,
                    item.latitude, item.longitude) /
                1000 <
            5)
          Marker(
            markerId: MarkerId(item.name),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(item.latitude, item.longitude),
            onTap: () {
              markerTap(item);
            },
          );
    return markersList;
  }
}
