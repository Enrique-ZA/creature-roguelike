import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/roguelike_game.dart';
import '../game/creatures.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, this.selectedCreature});

  final Creature? selectedCreature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: RoguelikeGame(
          onExit: () => Navigator.pushReplacementNamed(context, '/menu'),
          selectedCreature: selectedCreature!,
        ),
      ),
    );
  }
}