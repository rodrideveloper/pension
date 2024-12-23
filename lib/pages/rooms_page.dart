import 'package:flutter/material.dart';
import 'package:pension/model/room.dart';
import 'package:pension/services/firestore_service.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  List<Room> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final result = await FirestoreService.getAllRooms();
    setState(() {
      rooms = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitaciones'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  child: ListTile(
                    leading: room.imageUrl != null
                        ? Image.network(room.imageUrl!)
                        : const Icon(Icons.hotel),
                    title: Text(room.name),
                    subtitle: Text(
                      'Capacidad: ${room.capacity}\n'
                      'Precio por noche: \$${room.pricePerNight}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.book_online),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/createReservation',
                          arguments: room.id,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
