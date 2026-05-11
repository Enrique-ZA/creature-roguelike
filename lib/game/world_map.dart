// lib/game/world_map.dart (MODIFIED – uses nodes.dart, added puzzle, async callback)
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'nodes.dart'; // new
import 'creatures.dart';

typedef NodeTapCallback = Future<void> Function(MapNode node);

/// Procedurally generates a simple graph of map nodes.
List<MapNode> generateMap() {
  final rand = Random();
  final nodes = <MapNode>[];
  const nodeCount = 8;

  for (int i = 0; i < nodeCount; i++) {
    final type = i == 0
        ? MapNodeType.wildBattle
        : i == nodeCount - 1
            ? MapNodeType.boss
            : MapNodeType.values[rand.nextInt(MapNodeType.values.length)];
    final x = 100 + rand.nextDouble() * 600;
    final y = 100 + rand.nextDouble() * 400;
    nodes.add(MapNode(
      id: 'node_$i',
      type: type,
      position: Vector2(x, y),
    ));
  }

  for (int i = 0; i < nodes.length - 1; i++) {
    final connections = <String>[];
    if (i + 1 < nodes.length) connections.add(nodes[i + 1].id);
    if (i + 2 < nodes.length && rand.nextBool()) connections.add(nodes[i + 2].id);
    nodes[i].connections = connections;
  }

  return nodes;
}

/// Flame component that draws the world map and handles node taps.
class WorldMapComponent extends PositionComponent with TapCallbacks {
  WorldMapComponent({
    required this.onNodeSelected,
    required this.creatures,
  });

  final NodeTapCallback onNodeSelected;
  final List<Creature> creatures;
  late List<MapNode> nodes;
  late final Map<String, RectangleComponent> nodeComponents = {};

  @override
  Future<void> onLoad() async {
    nodes = generateMap();
    for (final node in nodes) {
      final color = _colorForType(node.type);
      final rect = RectangleComponent(
        position: node.position - Vector2(20, 20),
        size: Vector2(40, 40),
        paint: Paint()..color = color,
      );
      await add(rect);
      nodeComponents[node.id] = rect;
    }
  }

  Color _colorForType(MapNodeType type) {
    switch (type) {
      case MapNodeType.wildBattle: return Colors.redAccent;
      case MapNodeType.rest: return Colors.greenAccent;
      case MapNodeType.shop: return Colors.amber;
      case MapNodeType.boss: return Colors.purple;
      case MapNodeType.puzzle: return Colors.cyanAccent;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final touchPos = event.canvasPosition;
    for (final node in nodes) {
      final rect = nodeComponents[node.id]!;
      if (rect.toRect().contains(touchPos.toOffset())) {
        if (!node.completed) {
          onNodeSelected(node);
          return;
        }
      }
    }
  }
}