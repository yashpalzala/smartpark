import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetails {
  String name;
  String address;
  Timestamp startTime;
  Timestamp endTime;
  Timestamp bookingTime;
  int amount;
  int totalHours;
  String paymentId;
  bool isExpanded;

  BookingDetails(
      {this.name,
      this.address,
      this.startTime,
      this.endTime,
      this.bookingTime,
      this.amount,
      this.totalHours,
      this.paymentId,
      this.isExpanded = false});
}
