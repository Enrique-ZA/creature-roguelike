import 'dart:math';
import '../creatures.dart';
import '../moves.dart';
import 'status_effects.dart';

/// Snapshot of a creature in battle (mutable HP, statuses, etc.).
class BattleCreature {
  final Creature base;
  int currentHp;
  int spirit;
  final StatusTracker statuses = StatusTracker();

  BattleCreature(this.base)
      : currentHp = base.stats.hp,
        spirit = base.stats.spirit;

  bool get isAlive => currentHp > 0;
  int get speed => base.stats.speed; // can be modified by statuses later

  void applyDamage(int amount) {
    if (statuses.hasEffect(StatusEffect.shield)) {
      amount ~/= 2; // shield halves damage
    }
    currentHp = max(0, currentHp - amount);
  }

  void heal(int amount) {
    currentHp = min(base.stats.hp, currentHp + amount);
  }
}

/// Minimal AI: picks a random usable move.
Move? selectAiMove(BattleCreature creature) {
  final usable = creature.base.moves
      .where((m) => m.spiritCost <= creature.spirit)
      .toList();
  if (usable.isEmpty) return null;
  return usable[Random().nextInt(usable.length)];
}

/// Resolve one turn: player vs enemy using speed-based order.
/// Returns a [TurnResult] describing what happened.
class TurnResult {
  final bool playerMovedFirst;
  final String playerMoveName;
  final int playerDamage;
  final StatusEffect? playerEffectApplied;
  final String enemyMoveName;
  final int enemyDamage;
  final StatusEffect? enemyEffectApplied;
  final bool playerFainted;
  final bool enemyFainted;

  TurnResult({
    required this.playerMovedFirst,
    required this.playerMoveName,
    required this.playerDamage,
    this.playerEffectApplied,
    required this.enemyMoveName,
    required this.enemyDamage,
    this.enemyEffectApplied,
    required this.playerFainted,
    required this.enemyFainted,
  });
}

TurnResult executeTurn(
  BattleCreature player,
  Move playerMove,
  BattleCreature enemy,
) {
  final enemyMove = selectAiMove(enemy);
  final playerFirst = player.speed >= enemy.speed;

  // Helper to perform a move
  void performMove(BattleCreature user, Move move, BattleCreature target, bool isPlayer) {
    user.spirit -= move.spiritCost;
    if (move.power > 0) {
      target.applyDamage(move.power);
    }
    if (move.effect != null) {
      final effect = StatusEffect.values.firstWhere(
        (e) => e.name == move.effect,
        orElse: () => StatusEffect.burn,
      );
      target.statuses.apply(effect);
    }
    // special effects like heal or restore spirit are handled within the move's effect
    if (move.effect == 'heal') {
      user.heal(move.power);
    } else if (move.effect == 'restoreSpirit') {
      user.spirit = min(user.base.stats.spirit, user.spirit + move.power);
    }
  }

  int playerDamage = 0;
  int enemyDamage = 0;
  StatusEffect? playerEffect, enemyEffect;
  String playerMoveName = playerMove.name;
  String enemyMoveName = enemyMove?.name ?? 'Struggle';
  bool playerFainted = false, enemyFainted = false;

  if (playerFirst) {
    // Player goes first
    playerDamage = playerMove.power;
    if (playerMove.effect != null) {
      enemyEffect = StatusEffect.values.firstWhere((e) => e.name == playerMove.effect);
    }
    performMove(player, playerMove, enemy, true);
    if (!enemy.isAlive) {
      enemyFainted = true;
      return TurnResult(
        playerMovedFirst: true,
        playerMoveName: playerMoveName,
        playerDamage: playerDamage,
        playerEffectApplied: enemyEffect,
        enemyMoveName: enemyMoveName,
        enemyDamage: 0,
        enemyEffectApplied: null,
        playerFainted: false,
        enemyFainted: true,
      );
    }
    // Enemy retaliates
    if (enemyMove != null) {
      final oldHp = player.currentHp;
      enemyDamage = enemyMove.power;
      if (enemyMove.effect != null) {
        playerEffect = StatusEffect.values.firstWhere((e) => e.name == enemyMove.effect);
      }
      performMove(enemy, enemyMove, player, false);
      if (!player.isAlive) playerFainted = true;
    }
  } else {
    // Enemy first
    if (enemyMove != null) {
      final oldHp = player.currentHp;
      enemyDamage = enemyMove.power;
      if (enemyMove.effect != null) {
        playerEffect = StatusEffect.values.firstWhere((e) => e.name == enemyMove.effect);
      }
      performMove(enemy, enemyMove, player, false);
      if (!player.isAlive) {
        playerFainted = true;
        return TurnResult(
          playerMovedFirst: false,
          playerMoveName: playerMoveName,
          playerDamage: 0,
          playerEffectApplied: null,
          enemyMoveName: enemyMoveName,
          enemyDamage: enemyDamage,
          enemyEffectApplied: playerEffect,
          playerFainted: true,
          enemyFainted: false,
        );
      }
    }
    // Player then moves
    playerDamage = playerMove.power;
    if (playerMove.effect != null) {
      enemyEffect = StatusEffect.values.firstWhere((e) => e.name == playerMove.effect);
    }
    performMove(player, playerMove, enemy, true);
    if (!enemy.isAlive) enemyFainted = true;
  }

  return TurnResult(
    playerMovedFirst: playerFirst,
    playerMoveName: playerMoveName,
    playerDamage: playerDamage,
    playerEffectApplied: enemyEffect,
    enemyMoveName: enemyMoveName,
    enemyDamage: enemyDamage,
    enemyEffectApplied: playerEffect,
    playerFainted: playerFainted,
    enemyFainted: enemyFainted,
  );
}
