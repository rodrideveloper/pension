// import 'package:cloud_firestore/cloud_firestore.dart';

// class Reservation {
//   final String id;
//   final String roomId;
//   final String userId;
//   final DateTime startDate;
//   final DateTime endDate;
//   final double totalPrice;
//   final String status; // e.g. 'pending', 'confirmed', 'canceled'

//   Reservation({
//     required this.id,
//     required this.roomId,
//     required this.userId,
//     required this.startDate,
//     required this.endDate,
//     required this.totalPrice,
//     required this.status,
//   });

//   factory Reservation.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final startTimestamp = data['startDate'] as Timestamp?;
//     final endTimestamp = data['endDate'] as Timestamp?;

//     return Reservation(
//       id: doc.id,
//       roomId: data['roomId'] ?? '',
//       userId: data['userId'] ?? '',
//       startDate: startTimestamp?.toDate() ?? DateTime.now(),
//       endDate: endTimestamp?.toDate() ?? DateTime.now(),
//       totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
//       status: data['status'] ?? 'pending',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'roomId': roomId,
//       'userId': userId,
//       'startDate': Timestamp.fromDate(startDate),
//       'endDate': Timestamp.fromDate(endDate),
//       'totalPrice': totalPrice,
//       'status': status,
//     };
//   }
// }

// models/reservation.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id; // ID de la reserva
  final String roomId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  Reservation({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required double totalPrice,
    required String status,
  });

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      status: 'pending',
      totalPrice: 123,
      id: doc.id,
      roomId: data['roomId'] ?? '',
      userId: data['userId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
