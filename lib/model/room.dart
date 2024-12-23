import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  /// Document ID in Firestore (auto-generated or manual, e.g. "room_101")
  final String id;

  final String name;
  final String description;
  final int capacity;
  final double pricePerNight;
  final String? imageUrl;
  final bool isAvailable;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.pricePerNight,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      capacity: data['capacity'] ?? 0,
      pricePerNight: (data['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'pricePerNight': pricePerNight,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}
