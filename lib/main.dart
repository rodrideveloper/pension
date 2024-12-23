import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pension/firebase_options.dart';
import 'package:pension/pages/create_reservation_page.dart';
import 'package:pension/pages/create_user_page.dart';
import 'package:pension/pages/dashboard_page.dart';
import 'package:pension/pages/rooms_page.dart';
import 'package:pension/pages/users_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyHotelApp());
}

class MyHotelApp extends StatelessWidget {
  const MyHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel/Pensión Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/rooms': (context) => const RoomsPage(),
        '/createReservation': (context) => const CreateReservationPage(),
        '/users': (context) => const UsersPage(),
        '/createUser': (context) => const CreateUserPage(),
      },
    );
  }
}
