import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'creatures.dart';

/// Represents a node on the world map.
enum MapNodeType { battle, rest, shop, boss }

class MapNode {
  final String id;
  final MapNodeType type;
  final Vector2 position;
  List<String> connections; // ids of connected nodes
  bool completed = false;

  MapNode({
    required this.id,
    required this.type,
    required this.position,
    this.connections = const [],
  });
}

/// Procedurally generates a simple graph of map nodes.
List<MapNode> generateMap() {
  final rand = Random();
  final nodes = <MapNode>[];
  const nodeCount = 8;

  // Place nodes randomly, but ensure a path from left to right.
  for (int i = 0; i < nodeCount; i++) {
    final type = i == 0
        ? MapNodeType.battle
        : i == nodeCount - 1
            ? MapNodeType.boss
            : MapNodeType.values[rand.nextInt(MapNodeType.values.length)];
    final x = 100 + rand.nextDouble() * 600; // screen width ~ 800
    final y = 100 + rand.nextDouble() * 400;
    nodes.add(MapNode(
      id: 'node_$i',
      type: type,
      position: Vector2(x, y),
    ));
  }

  // Simple connection logic: each node connects to at most 2 forward nodes.
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
    required this.creatures, // pool of enemy creatures to choose from
  });

  final void Function(MapNode node) onNodeSelected;
  final List<Creature> creatures;
  late List<MapNode> nodes;
  late final Map<String, RectangleComponent> nodeComponents = {};

  @override
  Future<void> onLoad() async {
    nodes = generateMap();
    for (final node in nodes) {
      final color = _colorForType(node.type);
      final rect = RectangleComponent(
        position: node.position - Vector2(20, 20), // center
        size: Vector2(40, 40),
        paint: Paint()..color = color,
      );
      await add(rect);
      nodeComponents[node.id] = rect;
    }
  }

  Color _colorForType(MapNodeType type) {
    switch (type) {
      case MapNodeType.battle: return Colors.redAccent;
      case MapNodeType.rest: return Colors.greenAccent;
      case MapNodeType.shop: return Colors.amber;
      case MapNodeType.boss: return Colors.purple;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final touchPos = event.canvasPosition;
    // Check if any node was tapped
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
