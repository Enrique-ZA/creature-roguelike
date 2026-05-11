import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'moves.dart';
import 'creatures.dart';

class RoguelikeGame extends FlameGame {
  RoguelikeGame({required this.onExit, this.selectedCreature});

  final VoidCallback onExit;
  final Creature? selectedCreature;
  late List<Creature> creatures;
  late Map<String, Move> moveMap;

  @override
  Future<void> onLoad() async {
    // Load JSON from assets
    final movesJsonString = await rootBundle.loadString('assets/moves.json');
    final creaturesJsonString =
        await rootBundle.loadString('assets/creatures.json');

    final movesList = json.decode(movesJsonString) as List<dynamic>;
    final creaturesList = json.decode(creaturesJsonString) as List<dynamic>;

    // Build move map
    moveMap = loadMovesFromJson(movesList);
    // Build creatures with resolved moves
    creatures = loadCreaturesFromJson(creaturesList, moveMap);

    camera.viewfinder.anchor = Anchor.topLeft;

    // Add UI
    await add(
      ExitButton(
        position: Vector2(size.x - 60, 20),
        onPressed: onExit,
      ),
    );

    // Display selected creature if provided
    double yOffset = 80;
    if (selectedCreature != null) {
      await add(
        TextComponent(
          text: 'Active: ${selectedCreature!.name} (${selectedCreature!.type.toJson()})',
          textRenderer: TextPaint(
            style: const TextStyle(
                color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          position: Vector2(20, yOffset),
          anchor: Anchor.topLeft,
        ),
      );
      yOffset += 40;
    }

    // Display creature names as a quick test
    for (final creature in creatures) {
      await add(
        TextComponent(
          text: '${creature.name} (${creature.type.toJson()}) - moves: ${creature.moves.map((m) => m.name).join(", ")}',
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.yellow, fontSize: 16),
          ),
          position: Vector2(20, yOffset),
          anchor: Anchor.topLeft,
        ),
      );
      yOffset += 30;
    }
  }
}

class ExitButton extends TextComponent with TapCallbacks {
  ExitButton({
    required super.position,
    required this.onPressed,
  }) : super(
          text: 'X',
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white, fontSize: 32),
          ),
          anchor: Anchor.topLeft,
        );

  final VoidCallback onPressed;

  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}