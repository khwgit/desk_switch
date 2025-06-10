import 'package:flutter/material.dart';

class ServerHomeScreen extends StatelessWidget {
  const ServerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Server Home'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/server/profiles'),
              child: const Text('Profile Management'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/server/network'),
              child: const Text('Network Configuration'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/server/clients'),
              child: const Text('Connected Clients'),
            ),
          ],
        ),
      ),
    );
  }
}
