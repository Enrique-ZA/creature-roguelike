import 'package:flutter/material.dart';
import 'creature_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatureSelectScreen()),
          ),
          child: const Text('Play'),
        ),
      ),
    );
  }
}