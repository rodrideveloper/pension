// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pension/model/reservartion.dart';
// import 'package:pension/model/room.dart';
// import 'package:pension/model/user.dart';

// class FirestoreService {
//   static final _db = FirebaseFirestore.instance;

//   /// COLLECTION REFERENCES
//   static CollectionReference get roomsRef => _db.collection('rooms');
//   static CollectionReference get usersRef => _db.collection('users');
//   static CollectionReference get reservationsRef =>
//       _db.collection('reservations');

//   // ------------------
//   // Rooms
//   // ------------------
//   static Future<List<Room>> getAllRooms() async {
//     final snapshot = await roomsRef.get();
//     return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
//   }

//   static Future<void> createRoom(Room room) async {
//     await roomsRef.doc(room.id).set(room.toJson());
//   }

//   // ------------------
//   // Users
//   // ------------------
//   static Future<List<UserModel>> getAllUsers() async {
//     final snapshot = await usersRef.get();
//     return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
//   }

//   static Future<void> createUser(UserModel user) async {
//     // Si quieres ID autogenerado, usa .add()
//     await usersRef.doc(user.uid).set(user.toJson());
//   }

//   // ------------------
//   // Reservations
//   // ------------------
//   static Future<List<Reservation>> getAllReservations() async {
//     final snapshot = await reservationsRef.get();
//     return snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
//   }

//   static Future<void> createReservation(Reservation reservation) async {
//     // ID autogenerado
//     await reservationsRef.add(reservation.toJson());
//   }
// }
// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pension/model/reservartion.dart';
import 'package:pension/model/room.dart';
import 'package:pension/model/user.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// REFERENCIAS A LAS COLECCIONES
  static CollectionReference get roomsRef => _db.collection('rooms');
  static CollectionReference get usersRef => _db.collection('users');
  static CollectionReference get reservationsRef =>
      _db.collection('reservations');

  // ------------------
  // Rooms
  // ------------------
  static Future<List<Room>> getAllRooms() async {
    final snapshot = await roomsRef.get();
    return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
  }

  static Future<void> createRoom(Room room) async {
    await roomsRef.doc(room.id).set(room.toJson());
  }

  // ------------------
  // Users
  // ------------------
  static Future<List<UserModel>> getAllUsers() async {
    final snapshot = await usersRef.get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  static Future<void> createUser(UserModel user) async {
    // Si quieres ID autogenerado, usa .add()
    await usersRef.doc(user.uid).set(user.toJson());
  }

  // ------------------
  // Reservations
  // ------------------
  static Future<List<Reservation>> getAllReservations() async {
    final snapshot = await reservationsRef.get();
    return snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
  }

  static Future<void> createReservation(Reservation reservation) async {
    // ID autogenerado
    await reservationsRef.add(reservation.toJson());
  }

  // ------------------
  // Métodos Adicionales
  // ------------------

  /// Obtener reservas para una fecha específica
  static Future<List<Reservation>> getReservationsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await reservationsRef
        .where('startDate', isLessThan: Timestamp.fromDate(endOfDay))
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
  }

  /// Obtener múltiples usuarios por sus IDs utilizando 'whereIn'
  static Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    List<UserModel> users = [];
    const int batchSize =
        10; // Firestore permite un máximo de 10 elementos en 'whereIn'

    for (var i = 0; i < userIds.length; i += batchSize) {
      final batch = userIds.skip(i).take(batchSize).toList();
      final snapshot =
          await usersRef.where(FieldPath.documentId, whereIn: batch).get();

      users.addAll(
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
    }

    return users;
  }
}
