import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'battle_system.dart';
import 'types.dart';

/// Placeholder sprite component with simple animation states.
class CreatureSpriteComponent extends PositionComponent {
  final BattleCreature creature;
  CreatureSpriteComponent({
    required this.creature,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  String _currentState = 'idle';
  double _scale = 1.0;
  Color _tint = Colors.white;

  Color get creatureColor {
    // pick a color based on type
    switch (creature.base.type) {
      case CreatureType.fire: return Colors.red;
      case CreatureType.water: return Colors.blue;
      case CreatureType.earth: return Colors.brown;
      case CreatureType.wind: return Colors.greenAccent;
      case CreatureType.shadow: return Colors.purple;
      case CreatureType.light: return Colors.yellow;
      case CreatureType.storm: return Colors.cyan;
      case CreatureType.voidType: return Colors.grey;
    }
  }

  void playIdle() {
    _currentState = 'idle';
    _scale = 1.0;
    _tint = creatureColor;
  }

  void playAttack() {
    _currentState = 'attack';
    _scale = 1.2;
    _tint = creatureColor.withValues(alpha: 0.8);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentState == 'attack') playIdle();
    });
  }

  void playHurt() {
    _currentState = 'hurt';
    _scale = 0.9;
    _tint = Colors.red;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentState == 'hurt') playIdle();
    });
  }

  void playFaint() {
    _currentState = 'faint';
    _scale = 0.5;
    _tint = Colors.black38;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _tint;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 * _scale,
      paint,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: creature.base.name[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 28 * _scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2,
          size.y / 2 - textPainter.height / 2),
    );
  }
}