// lib/screens/shop_screen.dart (NEW – shop UI)
import 'package:flutter/material.dart';
import '../game/relics.dart';
import '../game/types.dart';
import '../game/roguelike_game.dart';

class ShopScreen extends StatelessWidget {
  final int gold;
  final List<Relic> forSale;
  final RoguelikeGame gameRef;

  const ShopScreen({
    super.key,
    required this.gold,
    required this.forSale,
    required this.gameRef,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Shop  |  Gold: $gold', style: const TextStyle(color: Colors.amberAccent)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: forSale.length,
        itemBuilder: (_, i) {
          final relic = forSale[i];
          final cost = _costForRarity(relic.rarity);
          final canAfford = gold >= cost;
          return ListTile(
            leading: Icon(Icons.auto_awesome, color: _colorForRarity(relic.rarity)),
            title: Text(relic.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(relic.description, style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? Colors.green : Colors.grey,
              ),
              onPressed: canAfford
                  ? () {
                      gameRef.gold -= cost;
                      gameRef.addRelic(relic);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text('Buy $cost'),
            ),
          );
        },
      ),
    );
  }

  int _costForRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common: return 50;
      case Rarity.uncommon: return 100;
      case Rarity.rare: return 200;
      case Rarity.epic: return 400;
      case Rarity.legendary: return 800;
      case Rarity.mythic: return 1600;
      case Rarity.shiny: return 3200;
    }
  }

  Color _colorForRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common: return Colors.grey;
      case Rarity.uncommon: return Colors.green;
      case Rarity.rare: return Colors.blue;
      case Rarity.epic: return Colors.purple;
      case Rarity.legendary: return Colors.amber;
      case Rarity.mythic: return Colors.red;
      case Rarity.shiny: return Colors.pink;
    }
  }
}