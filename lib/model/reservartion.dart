import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  /// Document ID in Firestore (auto-generated)
  final String id;

  /// The ID of the reserved room (reference to the `Room` document)
  final String roomId;

  /// The ID of the user who made the reservation (reference to the `UserModel` / uid)
  final String userId;

  /// The start date of the reservation
  final DateTime startDate;

  /// The end date of the reservation
  final DateTime endDate;

  /// The total price of the reservation
  final double totalPrice;

  /// The reservation status: 'pending', 'confirmed', 'canceled', etc.
  final String status;

  Reservation({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  /// Builds a `Reservation` object from a Firestore document
  factory Reservation.fromJson(Map<String, dynamic> json, String documentId) {
    // Parse Timestamps for the start and end dates
    final startTimestamp = json['startDate'] as Timestamp?;
    final endTimestamp = json['endDate'] as Timestamp?;

    final start = startTimestamp?.toDate() ?? DateTime.now();
    final end = endTimestamp?.toDate() ?? DateTime.now();

    return Reservation(
      id: documentId,
      roomId: json['roomId'] ?? '',
      userId: json['userId'] ?? '',
      startDate: start,
      endDate: end,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }

  /// Converts a `Reservation` object to a Map for saving in Firestore
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'userId': userId,
      // Use Timestamp.fromDate to store as Firestore Timestamps
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
