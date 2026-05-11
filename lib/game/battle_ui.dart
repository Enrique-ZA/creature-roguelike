import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../creatures.dart';
import '../moves.dart';
import 'battle_system.dart';
import 'status_effects.dart';

/// A single HP bar component.
class HpBar extends PositionComponent {
  HpBar({required this.creature, required this.isEnemy})
      : super(size: Vector2(200, 20));

  final BattleCreature creature;
  final bool isEnemy;

  @override
  void render(Canvas canvas) {
    final double ratio = creature.currentHp / creature.base.stats.hp;
    final bgPaint = Paint()..color = Colors.grey.shade800;
    final fgPaint = Paint()..color = ratio > 0.5 ? Colors.green : (ratio > 0.2 ? Colors.orange : Colors.red);
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.x, size.y, const Radius.circular(4)),
      bgPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.x * ratio, size.y, const Radius.circular(4)),
      fgPaint,
    );
    // Optional: text with HP numbers
  }
}

/// A move button for the player.
class MoveButton extends PositionComponent with TapCallbacks {
  MoveButton({
    required this.move,
    required this.onSelected,
    required Vector2 position,
  }) : super(position: position, size: Vector2(140, 50));

  final Move move;
  final void Function(Move) onSelected;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = move.spiritCost <= 3 ? Colors.blue.shade600 : Colors.blueGrey;
    canvas.drawRRect(RRect.fromLTRBR(0, 0, size.x, size.y, const Radius.circular(8)), paint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${move.name}\nSP:${move.spiritCost}',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x - 8);
    textPainter.paint(canvas, const Offset(4, 4));
  }

  @override
  void onTapUp(TapUpEvent event) => onSelected(move);
}

/// Floating damage number that fades out.
class DamageNumber extends PositionComponent {
  DamageNumber({required int amount, required Vector2 position})
      : super(position: position, anchor: Anchor.center);

  double opacity = 1.0;
  late final TextComponent textComp;

  @override
  Future<void> onLoad() async {
    textComp = TextComponent(
      text: amount.toString(),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow.withOpacity(opacity),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2.zero(),
      anchor: Anchor.center,
    );
    add(textComp);
    // Animate upward and fade
    final moveTween = MoveEffect.to(
      Vector2(0, -60),
      LinearEffectController(1.0),
    );
    final fadeTween = OpacityEffect.fadeOut(LinearEffectController(0.8));
    textComp.add(moveTween..onComplete = () => removeFromParent());
    textComp.add(fadeTween);
  }
}

/// The full battle scene, mounts inside the FlameGame.
class BattleScene extends PositionComponent {
  BattleScene({
    required this.player,
    required this.enemy,
    required this.onBattleEnd, // callback with victory flag
  }) : super(size: Vector2(800, 600)); // example

  final BattleCreature player;
  final BattleCreature enemy;
  final void Function(bool playerWon) onBattleEnd;

  late HpBar playerHpBar;
  late HpBar enemyHpBar;
  List<MoveButton> moveButtons = [];

  @override
  Future<void> onLoad() async {
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));

    // HP bars
    playerHpBar = HpBar(creature: player, isEnemy: false)
      ..position = Vector2(50, size.y - 100);
    enemyHpBar = HpBar(creature: enemy, isEnemy: true)
      ..position = Vector2(size.x - 250, 50);
    add(playerHpBar);
    add(enemyHpBar);

    // Move buttons (max 4)
    final moves = player.base.moves.take(4).toList();
    for (int i = 0; i < moves.length; i++) {
      final btn = MoveButton(
        move: moves[i],
        position: Vector2(50 + i * 160, size.y - 50),
        onSelected: (move) => _executePlayerMove(move),
      );
      moveButtons.add(btn);
      add(btn);
    }
  }

  void _executePlayerMove(Move move) async {
    if (player.spirit < move.spiritCost) return; // not enough spirit

    final result = executeTurn(player, move, enemy);
    // Show damage numbers
    if (result.playerDamage > 0) {
      add(DamageNumber(
        amount: result.playerDamage,
        position: enemyHpBar.position + Vector2(100, 10),
      ));
    }
    if (result.enemyDamage > 0) {
      add(DamageNumber(
        amount: result.enemyDamage,
        position: playerHpBar.position + Vector2(100, 10),
      ));
    }

    // Update HP bars (they repaint automatically via the creature reference)
    playerHpBar.creature = player;
    enemyHpBar.creature = enemy;
    // Update status UI if needed (simplified: just repaint)

    await Future.delayed(const Duration(milliseconds: 500));

    if (result.playerFainted || result.enemyFainted) {
      // Disable buttons
      for (final btn in moveButtons) {
        btn.removeFromParent();
      }
      onBattleEnd(!result.playerFainted);
    }
  }
}
