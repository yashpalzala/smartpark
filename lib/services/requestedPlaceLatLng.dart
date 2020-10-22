import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smartpark/models/placeinfo.dart';

class RequestedPlaceInfo {
  List<DetailedPlaceInfo> detailedPlaceInfoList = [];
  http.Response apiResponse;
  var apiResponseDecoded;
  Future<List<DetailedPlaceInfo>> getPlaceInfo(String api) async {
    apiResponse = await http.get(api);
    apiResponseDecoded = json.decode(apiResponse.body);
    for (var item in apiResponseDecoded['features']) {
      // DetailedPlaceInfo detailedPlaceInfo;
      detailedPlaceInfoList.add(DetailedPlaceInfo(
        name: item['text'],
        address: item['place_name'],
        latitude: item['center'][1],
        longitude: item['center'][0],
      ));
    }
    for (var item in detailedPlaceInfoList) {
      print(item.address);
    }
    return detailedPlaceInfoList;
  }
}
