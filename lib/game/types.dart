// lib/game/types.dart (unchanged)
/// Shared type enums used across creatures and moves.
enum CreatureType {
  fire,
  water,
  earth,
  wind,
  shadow,
  light,
  storm,
  voidType; // 'void' is a reserved word

  static CreatureType fromString(String value) {
    return CreatureType.values.firstWhere(
      (e) => e.name == (value == 'void' ? 'voidType' : value),
      orElse: () => CreatureType.fire,
    );
  }

  String toJson() => name == 'voidType' ? 'void' : name;
}

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
  shiny;

  static Rarity fromString(String value) {
    return Rarity.values.firstWhere((e) => e.name == value,
        orElse: () => Rarity.common);
  }

  String toJson() => name;
}