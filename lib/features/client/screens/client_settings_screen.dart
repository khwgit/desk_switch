import 'package:flutter/material.dart';

class ClientSettingsScreen extends StatelessWidget {
  const ClientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Connection Settings')),
      body: const Center(child: Text('Client Settings Screen')),
    );
  }
}
