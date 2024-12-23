class Room {
  /// Document ID in Firestore (can be auto-generated or manual, e.g. "room_101")
  final String id;

  /// The name of the room (e.g. "Deluxe Suite")
  final String name;

  /// A brief description of the room (e.g. "Room with ocean view...")
  final String description;

  /// Maximum capacity of people (e.g. 2, 4, etc.)
  final int capacity;

  /// Price per night for the room
  final double pricePerNight;

  /// Optional URL of the room's main image
  final String? imageUrl;

  /// Indicates if the room is currently available
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

  /// Builds a `Room` object from a Firestore document
  factory Room.fromJson(Map<String, dynamic> json, String documentId) {
    return Room(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  /// Converts a `Room` object to a Map for saving in Firestore
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
