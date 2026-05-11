// lib/game/roguelike_game.dart (MODIFIED – full node handling, relics, shop/rest/puzzle callbacks)
import 'dart:convert';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'moves.dart';
import 'creatures.dart';
import 'relics.dart'; // new
import 'world_map.dart';
import 'battle_system.dart';
import 'battle_ui.dart';
import 'nodes.dart'; // new

enum GameState { worldMap, battle, result }

class RoguelikeGame extends FlameGame {
  RoguelikeGame({
    required this.onExit,
    required this.selectedCreature,
    this.onShowShop,
    this.onShowRest,
    this.onShowPuzzle,
    this.onRunEnd,
  });

  final VoidCallback onExit;
  final Creature selectedCreature;

  // Callbacks for overlays (optional, required for UI nodes)
  final Future<void> Function(RoguelikeGame)? onShowShop;
  final Future<void> Function(RoguelikeGame)? onShowRest;
  final Future<bool> Function(RoguelikeGame)? onShowPuzzle;
  final void Function(bool victory)? onRunEnd;

  late List<Creature> creatures;
  late Map<String, Move> moveMap;
  late Map<String, Relic> relicMap;
  late List<Relic> relicPool;
  int gold = 100;
  List<Relic> ownedRelics = [];
  GameState state = GameState.worldMap;

  // Keep a reference to the player battle creature across battles
  BattleCreature? playerBattle;

  @override
  Future<void> onLoad() async {
    // Load data
    final movesJsonString = await rootBundle.loadString('assets/moves.json');
    final creaturesJsonString = await rootBundle.loadString('assets/creatures.json');
    final movesList = json.decode(movesJsonString) as List<dynamic>;
    final creaturesList = json.decode(creaturesJsonString) as List<dynamic>;
    moveMap = loadMovesFromJson(movesList);
    creatures = loadCreaturesFromJson(creaturesList, moveMap);
    relicMap = await loadRelics();
    relicPool = relicMap.values.toList();

    camera.viewfinder.anchor = Anchor.topLeft;

    await add(ExitButton(
      position: Vector2(size.x - 60, 20),
      onPressed: onExit,
    ));

    // Initialize player battle creature once
    playerBattle = BattleCreature(selectedCreature);

    _loadWorldMap();
  }

  void _loadWorldMap() {
    state = GameState.worldMap;
    children.whereType<WorldMapComponent>().forEach((c) => c.removeFromParent());
    children.whereType<BattleScene>().forEach((c) => c.removeFromParent());

    final worldMap = WorldMapComponent(
      onNodeSelected: _onNodeTapped,
      creatures: creatures,
    );
    add(worldMap);
  }

  Future<void> _onNodeTapped(MapNode node) async {
    switch (node.type) {
      case MapNodeType.wildBattle:
        await _startBattle(false);
        node.completed = true;
        _loadWorldMap();
        break;
      case MapNodeType.boss:
        await _startBattle(true);
        node.completed = true;
        _loadWorldMap();
        break;
      case MapNodeType.rest:
        await onShowRest?.call(this);
        // Player is healed in the rest callback
        node.completed = true;
        _loadWorldMap();
        break;
      case MapNodeType.shop:
        await onShowShop?.call(this);
        node.completed = true;
        _loadWorldMap();
        break;
      case MapNodeType.puzzle:
        final success = await onShowPuzzle?.call(this) ?? false;
        if (success) {
          // reward a random relic
          final relic = relicPool[Random().nextInt(relicPool.length)];
          ownedRelics.add(relic);
          // maybe show a snackbar, but not easily from Flame
        }
        node.completed = true;
        _loadWorldMap();
        break;
    }
  }

  Future<void> _startBattle(bool isBoss) async {
    state = GameState.battle;
    children.whereType<WorldMapComponent>().forEach((c) => c.removeFromParent());
    children.whereType<BattleScene>().forEach((c) => c.removeFromParent());

    // Pick enemy from pool, possibly stronger for boss
    final enemyPool = creatures.where((c) => c.id != selectedCreature.id).toList();
    var enemyBase = enemyPool[Random().nextInt(enemyPool.length)];
    if (isBoss) {
      // Boost stats for boss
      final boostedStats = Stats(
        hp: (enemyBase.stats.hp * 1.5).round(),
        attack: (enemyBase.stats.attack * 1.3).round(),
        defence: (enemyBase.stats.defence * 1.3).round(),
        speed: (enemyBase.stats.speed * 1.2).round(),
        spirit: (enemyBase.stats.spirit * 1.5).round(),
      );
      enemyBase = enemyBase.copyWith(stats: boostedStats);
    }

    final enemyBattle = BattleCreature(enemyBase);
    // If player is null (first battle) or fainted, reinit
    if (playerBattle == null || !playerBattle!.isAlive) {
      playerBattle = BattleCreature(selectedCreature);
    }

    final battleScene = BattleScene(
      player: playerBattle!,
      enemy: enemyBattle,
      onBattleEnd: (playerWon) {
        if (playerWon) {
          // Grant some gold
          gold += Random().nextInt(50) + 10;
        }
        if (!playerWon || (isBoss && playerWon)) {
          // Run end condition: player fainted or boss defeated
          onRunEnd?.call(playerWon);
        } else {
          // Continue to map
          _loadWorldMap();
        }
      },
    );
    await add(battleScene);
  }

  void restPlayer() {
    if (playerBattle != null) {
      playerBattle!.currentHp = playerBattle!.base.stats.hp;
      playerBattle!.spirit = playerBattle!.base.stats.spirit;
      playerBattle!.statuses.clear();
    }
  }

  void addRelic(Relic relic) {
    ownedRelics.add(relic);
    // In the future, apply relic effects globally
  }

  // Accessor for gold available to ShopScreen
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