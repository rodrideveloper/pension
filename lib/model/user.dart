import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  /// Document ID in Firestore (often the UID for an authenticated user,
  /// but here we might auto-generate or let user choose)
  final String uid;

  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdTimestamp = data['createdAt'] as Timestamp?;
    final date = createdTimestamp?.toDate() ?? DateTime.now();

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      createdAt: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
