import 'types.dart';
import 'moves.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Base stats for a creature.
class Stats {
  final int hp;
  final int attack;
  final int defence;
  final int speed;
  final int spirit; // max 10

  const Stats({
    required this.hp,
    required this.attack,
    required this.defence,
    required this.speed,
    required this.spirit,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      hp: json['hp'] as int,
      attack: json['attack'] as int,
      defence: json['defence'] as int,
      speed: json['speed'] as int,
      spirit: json['spirit'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'hp': hp,
        'attack': attack,
        'defence': defence,
        'speed': speed,
        'spirit': spirit,
      };
}

/// A passive ability that is always active for a creature.
class PassiveAbility {
  final String name;
  final String description;

  const PassiveAbility({
    required this.name,
    required this.description,
  });

  factory PassiveAbility.fromJson(Map<String, dynamic> json) {
    return PassiveAbility(
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}

/// Full creature data.
class Creature {
  final String id;
  final String name;
  final CreatureType type;
  final Rarity rarity;
  final bool isShiny;
  final Stats stats;
  final List<Move> moves;         // up to 4 active moves
  final PassiveAbility passive;
  final int evolutionStage;       // 1–3
  final bool isUnlocked;          // persistent meta flag
  final int runCount;             // meta: times used

  const Creature({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    this.isShiny = false,
    required this.stats,
    this.moves = const [],
    required this.passive,
    this.evolutionStage = 1,
    this.isUnlocked = false,
    this.runCount = 0,
  });

  /// Creates a Creature from a JSON map. Needs a move lookup map to resolve move IDs.
  factory Creature.fromJson(
    Map<String, dynamic> json,
    Map<String, Move> moveMap,
  ) {
    final moveIds = (json['moveIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final moves = moveIds
        .map((id) => moveMap[id] ?? Move.fromJson({'id': id, 'name': 'Unknown', 'type': 'fire', 'power': 0, 'spiritCost': 0}))
        .toList();

    return Creature(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CreatureType.fromString(json['type'] as String),
      rarity: Rarity.fromString(json['rarity'] as String? ?? 'common'),
      isShiny: json['isShiny'] as bool? ?? false,
      stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
      moves: moves,
      passive: PassiveAbility.fromJson(json['passive'] as Map<String, dynamic>),
      evolutionStage: (json['evolutionStage'] as num?)?.toInt() ?? 1,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      runCount: (json['runCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toJson(),
        'rarity': rarity.toJson(),
        'isShiny': isShiny,
        'stats': stats.toJson(),
        'moveIds': moves.map((m) => m.id).toList(),
        'passive': passive.toJson(),
        'evolutionStage': evolutionStage,
        'isUnlocked': isUnlocked,
        'runCount': runCount,
      };

  Creature copyWith({
    String? id,
    String? name,
    CreatureType? type,
    Rarity? rarity,
    bool? isShiny,
    Stats? stats,
    List<Move>? moves,
    PassiveAbility? passive,
    int? evolutionStage,
    bool? isUnlocked,
    int? runCount,
  }) {
    return Creature(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      isShiny: isShiny ?? this.isShiny,
      stats: stats ?? this.stats,
      moves: moves ?? this.moves,
      passive: passive ?? this.passive,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      runCount: runCount ?? this.runCount,
    );
  }
}

/// Loads creatures from a decoded JSON list, using a pre-loaded move map.
List<Creature> loadCreaturesFromJson(
    List<dynamic> jsonList, Map<String, Move> moveMap) {
  return jsonList
      .map((e) =>
          Creature.fromJson(e as Map<String, dynamic>, moveMap))
      .toList();
}

class CreatureDataLoader {
  static Future<List<Creature>> load() async {
    final movesJson = await rootBundle.loadString('assets/moves.json');
    final creaturesJson =
        await rootBundle.loadString('assets/creatures.json');
    final movesList = json.decode(movesJson) as List<dynamic>;
    final creaturesList = json.decode(creaturesJson) as List<dynamic>;
    final moveMap = loadMovesFromJson(movesList);
    return loadCreaturesFromJson(creaturesList, moveMap);
  }
}