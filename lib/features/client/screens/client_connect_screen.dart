import 'package:flutter/material.dart';

class ClientConnectScreen extends StatelessWidget {
  const ClientConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Server')),
      body: const Center(child: Text('Client Connect Screen')),
    );
  }
}
