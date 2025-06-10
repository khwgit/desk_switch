import 'package:flutter/material.dart';

class ServerProfilesScreen extends StatelessWidget {
  const ServerProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Management')),
      body: const Center(child: Text('Server Profiles Screen')),
    );
  }
}
