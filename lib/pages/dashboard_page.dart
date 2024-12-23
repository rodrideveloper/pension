// import 'package:flutter/material.dart';
// import 'package:pension/model/room.dart';
// import 'package:pension/services/firestore_service.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({Key? key}) : super(key: key);

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   List<Room> rooms = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRooms();
//   }

//   Future<void> _loadRooms() async {
//     final result = await FirestoreService.getAllRooms();
//     setState(() {
//       rooms = result;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.people_alt),
//             onPressed: () => Navigator.pushNamed(context, '/users'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.hotel),
//             onPressed: () => Navigator.pushNamed(context, '/rooms'),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pushNamed(context, '/createReservation'),
//         child: const Icon(Icons.add),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildDashboardContent(),
//     );
//   }

//   Widget _buildDashboardContent() {
//     // Podrías calcular el porcentaje de ocupación:
//     // Este ejemplo asume que "isAvailable" = false => ocupada,
//     // Lo real implicaría revisar Reservations, pero mostramos lo básico.
//     final totalRooms = rooms.length;
//     final occupied = rooms.where((r) => !r.isAvailable).length;
//     final occupancyRate = totalRooms == 0 ? 0 : (occupied / totalRooms) * 100;

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Text(
//             'Ocupación: ${occupied} / $totalRooms ( ${occupancyRate.toStringAsFixed(2)}% )',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: GridView.builder(
//               itemCount: rooms.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.2,
//               ),
//               itemBuilder: (context, index) {
//                 final room = rooms[index];
//                 return Card(
//                   color: room.isAvailable ? Colors.green[100] : Colors.red[100],
//                   child: Center(
//                     child: Text(
//                       room.name,
//                       style: const TextStyle(fontSize: 20),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pension/model/reservartion.dart';
import 'package:pension/model/room.dart';
import 'package:pension/model/user.dart';
import 'package:pension/services/firestore_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Room> rooms = [];
  List<Reservation> reservations = [];
  Map<String, UserModel> usersMap = {}; // Mapa para almacenar usuarios por ID
  bool isLoading = true;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Método para cargar habitaciones, reservas y usuarios
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener habitaciones
      final fetchedRooms = await FirestoreService.getAllRooms();

      // Obtener reservas para la fecha seleccionada
      final fetchedReservations =
          await FirestoreService.getReservationsByDate(selectedDate);

      // Obtener IDs únicos de usuarios para optimizar las consultas
      final userIds = fetchedReservations.map((r) => r.userId).toSet().toList();

      // Obtener usuarios asociados a las reservas
      final fetchedUsers = await FirestoreService.getUsersByIds(userIds);

      // Crear un mapa de usuarios para acceso rápido
      final usersMapLocal = {
        for (var user in fetchedUsers) user.uid: user,
      };

      setState(() {
        rooms = fetchedRooms;
        reservations = fetchedReservations;
        usersMap = usersMapLocal;
        isLoading = false;
      });
    } catch (e) {
      // Manejo de errores
      setState(() {
        isLoading = false;
      });
      print(e);
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  // Método para seleccionar una fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt),
            onPressed: () => Navigator.pushNamed(context, '/users'),
          ),
          IconButton(
            icon: const Icon(Icons.hotel),
            onPressed: () => Navigator.pushNamed(context, '/rooms'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Seleccionar Fecha',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createReservation'),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(formattedDate),
    );
  }

  Widget _buildDashboardContent(String formattedDate) {
    // Calcular la ocupación basada en las reservas
    final totalRooms = rooms.length;
    final occupiedRoomIds =
        reservations.map((reservation) => reservation?.id).toSet();
    final occupied = occupiedRoomIds.length;
    final occupancyRate = totalRooms == 0 ? 0 : (occupied / totalRooms) * 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Mostrar la fecha seleccionada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fecha: $formattedDate',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Cambiar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mostrar la ocupación
          Text(
            'Ocupación: $occupied / $totalRooms (${occupancyRate.toStringAsFixed(2)}%)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Mostrar las habitaciones en una cuadrícula
          Expanded(
            child: GridView.builder(
              itemCount: rooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final room = rooms[index];
                final isOccupied = occupiedRoomIds.contains(room.id);
                final usersInRoom = reservations
                    .where((r) => r.roomId == room.id)
                    .map((r) =>
                        usersMap[r.userId]?.name ?? 'Usuario desconocido')
                    .toList();

                return Card(
                  color: isOccupied ? Colors.red[100] : Colors.green[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isOccupied ? 'Ocupada' : 'Disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: isOccupied ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isOccupied) ...[
                          const Text(
                            'Usuarios:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          ...usersInRoom
                              .map((user) => Text(
                                    user,
                                    style: const TextStyle(fontSize: 14),
                                  ))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
