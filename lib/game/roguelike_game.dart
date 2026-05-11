import 'dart:convert';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'moves.dart';
import 'creatures.dart';
import 'world_map.dart';
import 'battle_system.dart';
import 'battle_ui.dart';

enum GameState { worldMap, battle, result }

class RoguelikeGame extends FlameGame {
  RoguelikeGame({required this.onExit, required this.selectedCreature});

  final VoidCallback onExit;
  final Creature selectedCreature;
  late List<Creature> creatures;
  late Map<String, Move> moveMap;
  GameState state = GameState.worldMap;

  @override
  Future<void> onLoad() async {
    // Load data
    final movesJsonString = await rootBundle.loadString('assets/moves.json');
    final creaturesJsonString = await rootBundle.loadString('assets/creatures.json');
    final movesList = json.decode(movesJsonString) as List<dynamic>;
    final creaturesList = json.decode(creaturesJsonString) as List<dynamic>;
    moveMap = loadMovesFromJson(movesList);
    creatures = loadCreaturesFromJson(creaturesList, moveMap);

    camera.viewfinder.anchor = Anchor.topLeft;

    await add(ExitButton(
      position: Vector2(size.x - 60, 20),
      onPressed: onExit,
    ));

    // Start on the world map
    _loadWorldMap();
  }

  void _loadWorldMap() {
    state = GameState.worldMap;
    // Remove any existing battle/world map components
    children.whereType<WorldMapComponent>().forEach((c) => c.removeFromParent());
    children.whereType<BattleScene>().forEach((c) => c.removeFromParent());

    final worldMap = WorldMapComponent(
      onNodeSelected: (node) {
        if (node.type == MapNodeType.battle || node.type == MapNodeType.boss) {
          _startBattle();
        }
      },
      creatures: creatures,
    );
    add(worldMap);
  }

  void _startBattle() {
    state = GameState.battle;
    children.whereType<WorldMapComponent>().forEach((c) => c.removeFromParent());
    children.whereType<BattleScene>().forEach((c) => c.removeFromParent());

    // Pick a random enemy from creatures (excluding the player's own)
    final enemyPool = creatures.where((c) => c.id != selectedCreature.id).toList();
    final enemyBase = enemyPool[Random().nextInt(enemyPool.length)];
    final playerBattle = BattleCreature(selectedCreature);
    final enemyBattle = BattleCreature(enemyBase);

    final battleScene = BattleScene(
      player: playerBattle,
      enemy: enemyBattle,
      onBattleEnd: (playerWon) {
        // After battle, return to world map (or show result, then map)
        _loadWorldMap();
      },
    );
    add(battleScene);
  }
}

class ExitButton extends TextComponent with TapCallbacks {
  ExitButton({required super.position, required this.onPressed})
      : super(
          text: 'X',
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white, fontSize: 32),
          ),
          anchor: Anchor.topLeft,
        );

  final VoidCallback onPressed;

  @override
  void onTapUp(TapUpEvent event) => onPressed();
}
