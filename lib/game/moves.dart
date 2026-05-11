import 'types.dart';

/// A single move a creature can use in battle.
class Move {
  final String id;
  final String name;
  final CreatureType type;
  final int power;          // base damage / heal amount
  final int spiritCost;    // resource required per use
  final String? effect;    // e.g. 'burn', 'freeze', 'shield'
  final double effectChance; // 0.0 - 1.0
  final int cooldown;      // turns before reuse (0 = no cooldown)
  final Rarity rarity;

  const Move({
    required this.id,
    required this.name,
    required this.type,
    required this.power,
    required this.spiritCost,
    this.effect,
    this.effectChance = 0.0,
    this.cooldown = 0,
    this.rarity = Rarity.common,
  });

  /// Creates a Move from a JSON map (from moves.json).
  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CreatureType.fromString(json['type'] as String),
      power: json['power'] as int,
      spiritCost: json['spiritCost'] as int,
      effect: json['effect'] as String?,
      effectChance: (json['effectChance'] as num?)?.toDouble() ?? 0.0,
      cooldown: (json['cooldown'] as num?)?.toInt() ?? 0,
      rarity: Rarity.fromString(json['rarity'] as String? ?? 'common'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toJson(),
        'power': power,
        'spiritCost': spiritCost,
        'effect': effect,
        'effectChance': effectChance,
        'cooldown': cooldown,
        'rarity': rarity.toJson(),
      };
}

/// Loads moves from a decoded JSON list (e.g., from a file).
Map<String, Move> loadMovesFromJson(List<dynamic> jsonList) {
  final map = <String, Move>{};
  for (final item in jsonList) {
    final move = Move.fromJson(item as Map<String, dynamic>);
    map[move.id] = move;
  }
  return map;
}