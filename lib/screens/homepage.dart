import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartpark/models/placeinfo.dart';
import 'package:smartpark/screens/mybookings.dart';
import 'package:smartpark/screens/slotbook.dart';
import 'package:smartpark/services/distancecalculator.dart';

import 'package:smartpark/services/requestedPlaceLatLng.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//https://maps.googleapis.com/maps/api/place/nearbysearch/
class _MyHomePageState extends State<MyHomePage> {
  Position _localPosition;

  double infoContainerHeight = 100;
  double infoContainerBottomPadding = 40;
  bool isInfoContainerExpanded = false;
  double drawerWidth = 0;
  String name;
  String address;
  List<DetailedPlaceInfo> detailedPlaceInfoList = [];
  DetailedPlaceInfo selectedPlaceInfo;

  animateInfoContainer() {
    setState(() {
      infoContainerHeight == 100
          ? infoContainerHeight = 350
          : infoContainerHeight = 100;

      /*  infoContainerBottomPadding == 40
          ? infoContainerBottomPadding = 0
          : infoContainerBottomPadding = 40; */

      isInfoContainerExpanded = !isInfoContainerExpanded;
    });
  }

  @override
  void initState() {
    getCurrentLocation();

    super.initState();
  }

/*   getNearbyParkings() {
    print('nearby parkings');
    http
        .get(
            'https://api.mapbox.com/geocoding/v5/mapbox.places/parking.json?proximity=${_localPosition.longitude},${_localPosition.latitude}&access_token=pk.eyJ1IjoieWFzaDEyMzQ1IiwiYSI6ImNrZ2h0ZGNvcTA0Z2kycm85MzVvMGpldGgifQ.mA_Qol_AK84MTvSqTYloWQ')
        .then((value) {
      print(json.decode(value.body));
    });
  } */

  getCurrentLocation() async {
    print('getcurrentlocationcalled');
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((value) {
      print('insideresults');
      setState(() {
        _localPosition = value;
      });
      print('_localpos');
      RequestedPlaceInfo()
          .getPlaceInfo(
              'https://api.mapbox.com/geocoding/v5/mapbox.places/parking.json?proximity=${_localPosition.longitude},${_localPosition.latitude}&access_token=pk.eyJ1IjoieWFzaDEyMzQ1IiwiYSI6ImNrZ2h0ZGNvcTA0Z2kycm85MzVvMGpldGgifQ.mA_Qol_AK84MTvSqTYloWQ')
          .then((value) {
        setState(() {
          detailedPlaceInfoList = value;
        });
      });
    });
  }

  appDrawerHandler() {
    setState(() {
      drawerWidth == 0 ? drawerWidth = 250 : drawerWidth = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        child: Column(),
      ),
      body: SafeArea(
          child: Container(
        color: Colors.white,
        height: _height,
        width: _width,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: _localPosition != null
                    ? InkWell(
                        child: Container(
                          height: _height * 0.78,
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              print('clicked');
                              appDrawerHandler();
                            },
                            child: GoogleMap(
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(_localPosition.latitude,
                                      _localPosition.longitude),
                                  zoom: 12),
                              zoomGesturesEnabled: true,
                              markers: {
                                if (detailedPlaceInfoList != null)
                                  for (var item in detailedPlaceInfoList)
                                    if (distanceCalculator(
                                                _localPosition.latitude,
                                                _localPosition.longitude,
                                                item.latitude,
                                                item.longitude) /
                                            1000 <
                                        5)
                                      Marker(
                                        markerId: MarkerId(item.name),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: LatLng(
                                            item.latitude, item.longitude),
                                        onTap: () {
                                          setState(() {
                                            name = item.name;
                                            address = item.address;
                                            selectedPlaceInfo = item;
                                          });
                                        },
                                      )
                              },
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      )),
            Positioned(
              top: 40,
              left: 18,
              child: Card(
                elevation: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 40,
                  width: _width * 0.8,
                  child: Row(
                    children: [
                      Container(
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                              color: Colors.blueGrey[50],
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(2, 0))
                        ]),
                        child: IconButton(
                            icon: Icon(Icons.calendar_view_day),
                            onPressed: () => appDrawerHandler()),
                      ),
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white,
                                        style: BorderStyle.none))),
                          ),
                        ),
                      ),
                      Container(
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                                color: Colors.blueGrey[50],
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(-1, 0))
                          ]),
                          child: IconButton(
                              icon: Icon(Icons.search), onPressed: null))
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: infoContainerBottomPadding,
              //width: _width * 0.8,
              left: 20,
              right: 20,
              child: Builder(builder: (scaffoldcontext) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      if (name == null) {
                        Scaffold.of(scaffoldcontext).showSnackBar(SnackBar(
                            content: Row(
                          children: [
                            Text('Please select a '),
                            Icon(Icons.location_on),
                            Text('for more info !'),
                          ],
                        )));
                      } else
                        animateInfoContainer();
                    },
                    child: InfoContainer(
                      infoContainerHeight: infoContainerHeight,
                      width: _width,
                      isInfoContainerExpanded: isInfoContainerExpanded,
                      name: name,
                      address: address,
                      detailedPlaceInfoList: detailedPlaceInfoList,
                      selectedPlaceInfo: selectedPlaceInfo,
                      currentPos: _localPosition,
                    ),
                  ),
                );
              }),
            ),
            Positioned(
              bottom: -5,
              right: 2,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              Bookings(selectedPlaceInfo: selectedPlaceInfo)));
                },
                color: Colors.black,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('My Bookings',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17)),
                    Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                left: -4,
                child: AppDrawer(
                  drawerWidth: drawerWidth,
                  appDrawerHandler: () => appDrawerHandler(),
                ))
          ],
        ),
      )),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer(
      {Key key, @required this.drawerWidth, @required this.appDrawerHandler})
      : super(key: key);

  final double drawerWidth;
  final Function appDrawerHandler;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 100,
      child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          color: Colors.white,
          width: drawerWidth,
          height: MediaQuery.of(context).size.height,
          child: drawerWidth != 0
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_backspace),
                          onPressed: () => appDrawerHandler(),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 60,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'My Wallet',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Settings',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'My Profile',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Coupons',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                      /* Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'My Wallet',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      ), */
                      /* ListTile(
                        title: Text(
                          'My Wallet',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.navigate_next),
                      ), */
                      /* Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ) */
                    ],
                  ),
                )
              : Container()),
    );
  }
}

//<==============================================================================================>

class InfoContainer extends StatelessWidget {
  const InfoContainer(
      {Key key,
      @required this.infoContainerHeight,
      @required double width,
      @required this.isInfoContainerExpanded,
      @required this.name,
      @required this.address,
      @required this.detailedPlaceInfoList,
      @required this.selectedPlaceInfo,
      @required this.currentPos})
      : _width = width,
        super(key: key);

  final double infoContainerHeight;
  final double _width;
  final bool isInfoContainerExpanded;
  final String name;
  final String address;
  final List<DetailedPlaceInfo> detailedPlaceInfoList;
  final DetailedPlaceInfo selectedPlaceInfo;
  final Position currentPos;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 400),
        height: infoContainerHeight,
        width: _width * 0.8,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(5)),
        child: isInfoContainerExpanded
            ? Container(
                height: infoContainerHeight,
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Distance : ' +
                          (distanceCalculator(
                                      currentPos.latitude,
                                      currentPos.longitude,
                                      selectedPlaceInfo.latitude,
                                      selectedPlaceInfo.longitude) /
                                  1000)
                              .toStringAsPrecision(3) +
                          ' Km'),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        address,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text('Ratings : '),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RatingBarIndicator(
                              rating: Random().nextDouble() * 5.0,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 25.0,
                              direction: Axis.horizontal,
                            ),
                          ),
                          Text(
                            '(' + Random().nextInt(100).toString() + ')',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 65,
                      ),
                      // Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => SlotBook(
                                          selectedPlaceInfo: selectedPlaceInfo,
                                        )));
                          },
                          child: Text(
                            'Book Slot',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : ShrinkedInfoContainer(
                detailedPlaceInfoList: detailedPlaceInfoList,
                name: name,
                address: address,
                currentPos: currentPos,
                selectedPlaceInfo: selectedPlaceInfo,
              ));
  }
}

//<===================================================================================>

class ShrinkedInfoContainer extends StatelessWidget {
  const ShrinkedInfoContainer(
      {Key key,
      @required this.detailedPlaceInfoList,
      @required this.name,
      @required this.address,
      @required this.currentPos,
      @required this.selectedPlaceInfo})
      : super(key: key);

  final List<DetailedPlaceInfo> detailedPlaceInfoList;
  final String name;
  final String address;
  final DetailedPlaceInfo selectedPlaceInfo;
  final Position currentPos;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (detailedPlaceInfoList.length != 0 && name != null)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Distance : ' +
                      (distanceCalculator(
                                  currentPos.latitude,
                                  currentPos.longitude,
                                  selectedPlaceInfo.latitude,
                                  selectedPlaceInfo.longitude) /
                              1000)
                          .toStringAsPrecision(3) +
                      ' Km'),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '( ' + address + ' )',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              )
            else if (detailedPlaceInfoList.length != 0 && name == null)
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tap on a '),
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      Text('to get info about the place ! '),
                    ],
                  ),
                ),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Loading your Parking spot...')
                ],
              )
          ],
        ),
      ),
    );
  }
}
