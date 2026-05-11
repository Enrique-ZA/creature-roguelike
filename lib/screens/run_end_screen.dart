import 'package:flutter/material.dart';

class RunEndScreen extends StatelessWidget {
  final bool victory;

  const RunEndScreen({super.key, required this.victory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              victory ? Icons.emoji_events : Icons.heart_broken,
              size: 80,
              color: victory ? Colors.amber : Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Text(
              victory ? 'VICTORY' : 'DEFEAT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: victory ? Colors.amber : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}