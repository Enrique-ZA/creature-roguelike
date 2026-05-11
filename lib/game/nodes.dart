import 'package:vector_math/vector_math.dart';

/// Defines the different map node types.
enum MapNodeType { wildBattle, boss, rest, shop, puzzle }

/// Represents a node on the world map.
class MapNode {
  final String id;
  final MapNodeType type;
  final Vector2 position;
  List<String> connections;
  bool completed = false;

  MapNode({
    required this.id,
    required this.type,
    required this.position,
    this.connections = const [],
  });
}