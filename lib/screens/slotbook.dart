import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smartpark/models/placeinfo.dart';
import 'package:smartpark/screens/mybookings.dart';

class SlotBook extends StatefulWidget {
  final DetailedPlaceInfo selectedPlaceInfo;

  SlotBook({@required this.selectedPlaceInfo});

  @override
  _SlotBookState createState() => _SlotBookState();
}

class _SlotBookState extends State<SlotBook> {
  DateTime startDate;
  String today = 'Today';
  TimeOfDay startTime;
  DateTime endDate;
  TimeOfDay endTime;
  int totalHours;
  DateTime finalStart;
  DateTime finalEnd;
  Razorpay razorpay;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    startDate = DateTime.now();
    startTime = TimeOfDay.now();

    //======= Razor pay ===========

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    razorpay.on(Razorpay.PAYMENT_CANCELLED.toString(), handlerPaymentCancelled);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print("Payment successful");
    print(response);
    FirebaseFirestore.instance.collection('bookings').add({
      'name': widget.selectedPlaceInfo.name,
      'address': widget.selectedPlaceInfo.address,
      'startTime': finalStart,
      'endTime': finalEnd,
      'totalHours': totalHours,
      'charged': totalHours * 10,
      'bookingTime': DateTime.now(),
      'paymentId': response.paymentId,
      'orderId': response.orderId
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Bookings(
                  selectedPlaceInfo: widget.selectedPlaceInfo,
                )));
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print("Payment failed");
    showInSnackBar('Payment failed');
    print(response.code);
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print("External Wallet response");
    print(response);
  }

  void handlerPaymentCancelled(ExternalWalletResponse response) {
    print("Payment Cancelled");
    print(response);
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_lpetL9JbCMd5J1",
      "amount": totalHours * 10 * 100, // * 100 bcoz its in paise
      "name": "Sample App",
      "description": "Payment for the some random product",
      "prefill": {"contact": "Test No.", "email": "testing@gmail.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<DateTime> startSlotPickerDate() async {
    DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime.now().add(Duration(days: 60)));
    return pickedDate;
  }

  startSlotPickerTime(BuildContext scaffoldcontext) async {
    TimeOfDay pickedStartTime = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(startDate));

    if (pickedStartTime != null) {
      pickedStartTime.hour * 60 + pickedStartTime.minute <
              TimeOfDay.now().hour * 60 + TimeOfDay.now().minute
          ? Scaffold.of(scaffoldcontext).showSnackBar(
              SnackBar(content: Text('Please select a valid time')))
          : setState(() {
              startTime = pickedStartTime;
            });
    }
  }

  endSlotTimePicker() async {
    TimeOfDay pickedEndTime = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(startDate));
    if (pickedEndTime != null) {
      setState(() {
        endTime = pickedEndTime;
      });
    }
  }

  String hoursCalculator() {
    finalStart = DateTime(startDate.year, startDate.month, startDate.day,
        startTime.hour, startTime.minute);
    finalEnd = DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    print('start : ' + finalStart.toString());
    print('end : ' + finalEnd.toString());

    totalHours = finalEnd.difference(finalStart).inHours;
    return totalHours.toString();
  }

  @override
  Widget build(BuildContext context) {
    print('building widget');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Book Slot'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    color: Colors.black,
                    child: Text(
                      widget.selectedPlaceInfo.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        color: Colors.green,
                        child: Text('Slot start time :'))),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.green)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.green,
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Date : '),
                            Text(startDate.day == DateTime.now().day &&
                                    startDate.month == DateTime.now().month &&
                                    startDate.year == DateTime.now().year
                                ? today
                                : '${startDate.day} / ${startDate.month} / ${startDate.year}'),
                          ],
                        ),
                        onTap: () {
                          startSlotPickerDate().then((value) {
                            if (value != null) {
                              setState(() {
                                startDate = value;
                              });
                            }
                          });
                        },
                        // trailing: Text('(DD/MM/YYYY)'),
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.5),
                        thickness: 0.8,
                        indent: 10,
                        endIndent: 10,
                      ),
                      Builder(builder: (scaffoldcontext) {
                        return ListTile(
                          leading: Icon(
                            Icons.alarm,
                            color: Colors.green,
                          ),
                          title: Row(
                            children: [
                              Text('Time : '),
                              Text(
                                  '${startTime.hour > 12 ? startTime.hour - 12 : startTime.hour} : ${startTime.minute} ${startTime.hour >= 12 ? 'pm' : 'am'}'),
                            ],
                          ),
                          onTap: () => startSlotPickerTime(scaffoldcontext),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        color: Colors.red,
                        child: Text('Slot end time :'))),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.red)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.red,
                        ),
                        title: Text('Date : ' +
                            (endDate == null
                                ? 'Select a Date'
                                : endDate.day == DateTime.now().day &&
                                        endDate.month == DateTime.now().month &&
                                        endDate.year == DateTime.now().year
                                    ? today
                                    : '${endDate.day} / ${endDate.month} / ${endDate.year}')),
                        onTap: () {
                          startSlotPickerDate().then((value) {
                            print(value);
                            if (value != null) {
                              setState(() {
                                endDate = value;
                              });
                            }
                          });
                        },
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.5),
                        thickness: 0.8,
                        indent: 10,
                        endIndent: 10,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.alarm,
                          color: Colors.red,
                        ),
                        title: Text('Time : ' +
                            (endTime == null
                                ? 'Select a Time'
                                : '${endTime.hour > 12 ? endTime.hour - 12 : endTime.hour} : ${endTime.minute}  ${endTime.hour >= 12 ? 'pm' : 'am'}')),
                        onTap: () => endSlotTimePicker(),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                ListTile(
                  title: Text('Billed Hours : '),
                  trailing: Text(
                    startDate != null &&
                            startTime != null &&
                            endDate != null &&
                            endTime != null
                        ? hoursCalculator()
                        : '',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  title: Text('Payable amount : '),
                  trailing: Text(
                    startDate != null &&
                            startTime != null &&
                            endDate != null &&
                            endTime != null &&
                            totalHours != null
                        ? totalHours.toString() +
                            'hrs' +
                            '*' +
                            '10 Rs/hr' +
                            ' = ' +
                            (totalHours * 10).toString()
                        : '',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Builder(builder: (scaffoldcontext) {
        return InkWell(
          onTap: () {
            totalHours != null && totalHours > 0
                ? openCheckout()
                : Scaffold.of(scaffoldcontext).showSnackBar(SnackBar(
                    content:
                        Text('Please select an appropriate slot timing !')));
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.08,
            color: Colors.black,
            child: Center(
              child: Text(
                'Pay Now',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        );
      }),
    );
  }
}
