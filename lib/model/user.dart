import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  /// Document ID in Firestore (usually the authenticated user's UID)
  final String uid;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// (Optional) user's phone number
  final String? phoneNumber;

  /// When the user was created, stored as a `DateTime` in the model
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.createdAt,
  });

  /// Builds a `UserModel` from a Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    // In Firestore, we typically store dates as Timestamps
    final createdTimestamp = json['createdAt'] as Timestamp?;
    // Convert to DateTime (default to now if null)
    final date = createdTimestamp?.toDate() ?? DateTime.now();

    return UserModel(
      uid: documentId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: date,
    );
  }

  /// Converts a `UserModel` object to a Map for saving in Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      // Use Timestamp.fromDate to store as Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
