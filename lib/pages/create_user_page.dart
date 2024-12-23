import 'package:flutter/material.dart';
import 'package:pension/model/user.dart';
import 'package:pension/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un correo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Teléfono (opcional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Guardar Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Genera un ID único para el usuario (o podrías dejar que Firestore lo autogenere)
    final uuid = const Uuid().v4();
    final user = UserModel(
      uid: uuid,
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phoneNumber: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
      createdAt: DateTime.now(),
    );

    await FirestoreService.createUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario creado exitosamente')),
    );

    Navigator.pop(context); // Regresa a la pantalla anterior
  }
}
