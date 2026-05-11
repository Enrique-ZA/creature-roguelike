// lib/screens/game_screen.dart (MODIFIED – stateful widget with callbacks)
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/roguelike_game.dart';
import '../game/creatures.dart';
import '../game/relics.dart';
import 'shop_screen.dart';
import 'rest_screen.dart';
import 'puzzle_screen.dart';
import 'run_end_screen.dart';

class GameScreen extends StatefulWidget {
  final Creature selectedCreature;
  const GameScreen({super.key, required this.selectedCreature});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late RoguelikeGame game;

  @override
  void initState() {
    super.initState();
    game = RoguelikeGame(
      onExit: () => Navigator.pushReplacementNamed(context, '/menu'),
      selectedCreature: widget.selectedCreature,
      onShowShop: _showShop,
      onShowRest: _showRest,
      onShowPuzzle: _showPuzzle,
      onRunEnd: _showRunEnd,
    );
  }

  Future<void> _showShop(RoguelikeGame gameRef) async {
    if (!mounted) return;
    final relics = List<Relic>.from(gameRef.relicPool);
    relics.shuffle();
    final forSale = relics.take(3).toList();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopScreen(
          gold: gameRef.gold,
          forSale: forSale,
          gameRef: gameRef,
        ),
      ),
    );
  }

  Future<void> _showRest(RoguelikeGame gameRef) async {
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RestScreen()));
    // After rest, fully heal the player creature (done in game logic)
    gameRef.restPlayer();
  }

  Future<bool> _showPuzzle(RoguelikeGame gameRef) async {
    if (!mounted) return false;
    bool result = false;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(
          sequenceLength: 4,
          onResult: (success) {
            result = success;
            Navigator.pop(context);
          },
        ),
      ),
    );
    return result;
  }

  void _showRunEnd(bool victory) async {
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RunEndScreen(victory: victory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}