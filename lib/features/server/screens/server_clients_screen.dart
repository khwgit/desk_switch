import 'package:flutter/material.dart';

class ServerClientsScreen extends StatelessWidget {
  const ServerClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected Clients')),
      body: const Center(child: Text('Server Clients Screen')),
    );
  }
}
