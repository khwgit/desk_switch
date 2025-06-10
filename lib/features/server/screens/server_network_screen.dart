import 'package:flutter/material.dart';

class ServerNetworkScreen extends StatelessWidget {
  const ServerNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Configuration')),
      body: const Center(child: Text('Server Network Screen')),
    );
  }
}
