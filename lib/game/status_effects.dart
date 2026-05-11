/// Represents possible status effects and their management.
enum StatusEffect {
  burn,
  freeze,
  shield,
  blind,
  paralyze,
  trap,
  speedBoost,
  heal,
  curse,
  restoreSpirit;

  /// Duration (in turns) applied by default.
  int get defaultDuration {
    switch (this) {
      case StatusEffect.burn: return 3;
      case StatusEffect.freeze: return 1;
      case StatusEffect.shield: return 2;
      case StatusEffect.blind: return 2;
      case StatusEffect.paralyze: return 1;
      case StatusEffect.trap: return 2;
      default: return 0;
    }
  }
}

/// Tracks active statuses on a creature.
class StatusTracker {
  final Map<StatusEffect, int> _active = {};

  void apply(StatusEffect effect, [int? duration]) {
    _active[effect] = (duration ?? effect.defaultDuration).clamp(1, 99);
  }

  bool hasEffect(StatusEffect effect) => _active.containsKey(effect);

  int? remainingTurns(StatusEffect effect) => _active[effect];

  void decrementAll() {
    _active.removeWhere((k, v) {
      final next = v - 1;
      if (next <= 0) return true;
      _active[k] = next;
      return false;
    });
  }

  void clear() => _active.clear();

  List<StatusEffect> get activeEffects => _active.keys.toList();
}
