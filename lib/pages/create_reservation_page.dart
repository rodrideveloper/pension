import 'package:flutter/material.dart';
import 'package:pension/model/reservartion.dart';
import 'package:pension/model/room.dart';
import 'package:pension/model/user.dart';
import 'package:pension/services/firestore_service.dart';

class CreateReservationPage extends StatefulWidget {
  const CreateReservationPage({Key? key}) : super(key: key);

  @override
  State<CreateReservationPage> createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends State<CreateReservationPage> {
  List<Room> rooms = [];
  List<UserModel> users = [];

  String? selectedRoomId;
  String? selectedUserId;
  DateTime? startDate;
  DateTime? endDate;
  double totalPrice = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final roomList = await FirestoreService.getAllRooms();
    final userList = await FirestoreService.getAllUsers();

    setState(() {
      rooms = roomList;
      users = userList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si venimos con un ID de habitación como argumento:
    final roomArg = ModalRoute.of(context)?.settings.arguments;
    if (roomArg != null && selectedRoomId == null) {
      selectedRoomId = roomArg as String;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reserva'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Seleccionar habitación
                  DropdownButton<String>(
                    hint: const Text('Seleccionar Habitación'),
                    value: selectedRoomId,
                    isExpanded: true,
                    items: rooms.map((room) {
                      return DropdownMenuItem<String>(
                        value: room.id,
                        child: Text(room.name),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedRoomId = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seleccionar usuario
                  DropdownButton<String>(
                    hint: const Text('Seleccionar Usuario'),
                    value: selectedUserId,
                    isExpanded: true,
                    items: users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user.uid,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedUserId = newValue;
                      });
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/createUser').then((_) {
                        // Recargar la lista de usuarios después de volver
                        _loadData();
                      });
                    },
                    child: const Text('Crear nuevo usuario'),
                  ),
                  const SizedBox(height: 16),

                  // Seleccionar fecha
                  ElevatedButton(
                    onPressed: () async {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (dateRange != null) {
                        setState(() {
                          startDate = dateRange.start;
                          endDate = dateRange.end;
                        });
                        _calculateTotalPrice();
                      }
                    },
                    child: const Text('Seleccionar Fechas'),
                  ),
                  const SizedBox(height: 8),
                  if (startDate != null && endDate != null)
                    Text(
                      'Check-in: $startDate\nCheck-out: $endDate',
                    ),
                  const SizedBox(height: 16),

                  // Mostrar precio total
                  Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),

                  // Botón para guardar la reserva
                  ElevatedButton(
                    onPressed: _saveReservation,
                    child: const Text('Guardar Reserva'),
                  ),
                ],
              ),
            ),
    );
  }

  void _calculateTotalPrice() {
    if (selectedRoomId == null || startDate == null || endDate == null) {
      return;
    }
    final room = rooms.firstWhere((r) => r.id == selectedRoomId);
    final nights = endDate!.difference(startDate!).inDays;
    final price = room.pricePerNight * nights;
    setState(() {
      totalPrice = price;
    });
  }

  Future<void> _saveReservation() async {
    if (selectedRoomId == null ||
        selectedUserId == null ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Crear objeto Reservation
    final reservation = Reservation(
      id: '', // Se autogenera en Firestore
      roomId: selectedRoomId!,
      userId: selectedUserId!,
      startDate: startDate!,
      endDate: endDate!,
      totalPrice: totalPrice,
      status: 'pending',
    );

    await FirestoreService.createReservation(reservation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva guardada exitosamente')),
    );

    Navigator.pop(context);
  }
}
