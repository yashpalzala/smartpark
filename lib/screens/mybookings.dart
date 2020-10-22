import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpark/models/bookingdetails.dart';
import 'package:smartpark/models/placeinfo.dart';

class Bookings extends StatefulWidget {
  final DetailedPlaceInfo selectedPlaceInfo;

  Bookings({@required this.selectedPlaceInfo});
  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  List<BookingDetails> upcoming = [];
  List<BookingDetails> history = [];
  bool isLoaded = false;

  @override
  void initState() {
    getBookings();
    super.initState();
  }

  getBookings() {
    FirebaseFirestore.instance.collection('bookings').get().then((value) {
      print('Total elemants : ' + value.docs.length.toString());
      value.docs.forEach((element) {
        print(element.data()['startTime'].runtimeType);
        BookingDetails temp = BookingDetails(
            name: element.data()['name'],
            address: element.data()['address'],
            startTime: element.data()['startTime'],
            endTime: element.data()['endTime'],
            amount: element.data()['charged'],
            bookingTime: element.data()['bookingTime'],
            totalHours: element.data()['totalHours'],
            paymentId: element.data()['paymentId']);
        // print(element.data()['endTime'].cast<Timestamp>().runtimeType);
        if (DateTime.fromMillisecondsSinceEpoch(
                temp.endTime.millisecondsSinceEpoch)
            .isAfter(DateTime.now())) {
          upcoming.add(temp);
        } else {
          history.add(temp);
        }
      });
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('My Bookings'),
        ),
        body: isLoaded
            ? Container(
                child: SingleChildScrollView(
                  child: Column(children: [
                    /* SizedBox(
                      height: 20,
                    ), */
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      color: Colors.green,
                      alignment: Alignment.center,
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    upcoming.length != 0
                        ? Column(
                            children: [
                              for (int i = 0; i < upcoming.length; i++)
                                ExpansionTile(
                                  title: Text(
                                    upcoming[i].name,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    DateFormat.yMEd()
                                        .add_jms()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                upcoming[i]
                                                    .bookingTime
                                                    .millisecondsSinceEpoch))
                                        .toString(),
                                  ),
                                  children: [
                                    ListTile(
                                      title: Text('Slot start time : '),
                                      trailing: Text(
                                        DateFormat.yMEd().add_jms().format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                  upcoming[i]
                                                      .startTime
                                                      .millisecondsSinceEpoch),
                                            ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Slot end time : '),
                                      trailing: Text(
                                        DateFormat.yMEd().add_jms().format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                  upcoming[i]
                                                      .endTime
                                                      .millisecondsSinceEpoch),
                                            ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Total Hours : '),
                                      trailing: Text(
                                        upcoming[i].totalHours.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Amount Paid : '),
                                      trailing: Text(
                                        upcoming[i].amount.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  ],
                                )
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: Text(
                          'History',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                    history.length != 0
                        ? Column(
                            children: [
                              for (int i = 0; i < history.length; i++)
                                ExpansionTile(
                                  title: Text(
                                    history[i].name,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  subtitle: Text(DateFormat.yMEd()
                                      .add_jms()
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              history[i]
                                                  .bookingTime
                                                  .millisecondsSinceEpoch))
                                      .toString()),
                                  children: [
                                    ListTile(
                                      title: Text('Slot start time : '),
                                      trailing: Text(
                                        DateFormat.yMEd().add_jms().format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                  history[i]
                                                      .startTime
                                                      .millisecondsSinceEpoch),
                                            ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Slot end time : '),
                                      trailing: Text(
                                        DateTime.fromMillisecondsSinceEpoch(
                                                history[i]
                                                    .endTime
                                                    .millisecondsSinceEpoch)
                                            .toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Total Hours : '),
                                      trailing: Text(
                                        history[i].totalHours.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text('Amount Paid : '),
                                      trailing: Text(
                                        history[i].amount.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  ],
                                )
                            ],
                          )
                        : Container(),
                  ]),
                ),
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ),
              ));
  }
}
