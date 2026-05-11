// lib/game/relics.dart (NEW – relic model + loader)
import 'types.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Relic {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;

  const Relic({
    required this.id,
    required this.name,
    required this.description,
    this.rarity = Rarity.common,
  });

  factory Relic.fromJson(Map<String, dynamic> json) {
    return Relic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: Rarity.fromString(json['rarity'] as String? ?? 'common'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rarity': rarity.toJson(),
      };
}

Map<String, Relic> loadRelicsFromJson(List<dynamic> jsonList) {
  final map = <String, Relic>{};
  for (final item in jsonList) {
    final relic = Relic.fromJson(item as Map<String, dynamic>);
    map[relic.id] = relic;
  }
  return map;
}

Future<Map<String, Relic>> loadRelics() async {
  final jsonString = await rootBundle.loadString('assets/relics.json');
  final jsonList = json.decode(jsonString) as List<dynamic>;
  return loadRelicsFromJson(jsonList);
}