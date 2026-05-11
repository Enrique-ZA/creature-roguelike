import 'package:flutter/material.dart';
import '../game/creatures.dart';
import '../game/types.dart';
import 'game_screen.dart';

class CreatureSelectScreen extends StatefulWidget {
  const CreatureSelectScreen({super.key});

  @override
  State<CreatureSelectScreen> createState() => _CreatureSelectScreenState();
}

class _CreatureSelectScreenState extends State<CreatureSelectScreen> {
  List<Creature> _creatures = [];
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCreatures();
  }

  Future<void> _loadCreatures() async {
    final creatureData = await CreatureDataLoader.load();
    setState(() {
      _creatures = creatureData;
      _loading = false;
    });
  }

  void _startRun() {
    if (_creatures.isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GameScreen(selectedCreature: _creatures[_selectedIndex]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: _loading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedRuneLoader(),
          SizedBox(height: 16),
          Text(
            'SUMMONING CREATURES...',
            style: TextStyle(
              color: Color(0xFF6B7DB3),
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final creature = _creatures[_selectedIndex];
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: _buildCreatureCard(creature),
                  ),
                );
              },
            ),
          ),
          _buildSelectionRow(),
          _buildStartButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _buildBackArrow(),
          const Spacer(),
          Text(
            'CHOOSE YOUR CREATURE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBackArrow() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(Icons.arrow_back, color: Color(0xFF6B7DB3), size: 22),
      ),
    );
  }

  Widget _buildCreatureCard(Creature creature) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(creature.id),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _rarityColor(creature.rarity).withValues(alpha: 0.6),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _rarityColor(creature.rarity).withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF131624), const Color(0xFF0A0C14)],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCreatureAvatar(creature),
              const SizedBox(height: 16),
              _buildCreatureName(creature),
              const SizedBox(height: 4),
              _buildTypeAndRarityBadges(creature),
              const SizedBox(height: 20),
              _buildStatBars(creature),
              const SizedBox(height: 16),
              _buildMovesRow(creature),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatureAvatar(Creature creature) {
    final typeColor = _typeColor(creature.type);
    final rarityGlow = _rarityColor(creature.rarity);
    final size = MediaQuery.of(context).size.height * 0.16;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            typeColor.withValues(alpha: 0.3),
            typeColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: rarityGlow.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _typeIcon(creature.type),
          size: size * 0.45,
          color: typeColor.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildCreatureName(Creature creature) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            _rarityColor(creature.rarity),
            _rarityColor(creature.rarity).withValues(alpha: 0.7),
          ],
        ).createShader(bounds);
      },
      child: Text(
        creature.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildTypeAndRarityBadges(Creature creature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _badge(
          label: creature.type.toJson().toUpperCase(),
          color: _typeColor(creature.type),
        ),
        const SizedBox(width: 10),
        _badge(
          label: creature.rarity.toJson().toUpperCase(),
          color: _rarityColor(creature.rarity),
        ),
        if (creature.isShiny) ...[
          const SizedBox(width: 10),
          _badge(label: 'SHINY', color: const Color(0xFFE040FB), sparkle: true),
        ],
      ],
    );
  }

  Widget _badge({
    required String label,
    required Color color,
    bool sparkle = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: sparkle
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatBars(Creature creature) {
    final stats = creature.stats;
    final statDefs = [
      _StatDef('HP', stats.hp, 120, const Color(0xFF4CAF50)),
      _StatDef('ATK', stats.attack, 25, const Color(0xFFFF5252)),
      _StatDef('DEF', stats.defence, 25, const Color(0xFF448AFF)),
      _StatDef('SPD', stats.speed, 20, const Color(0xFFFFC107)),
      _StatDef('SPR', stats.spirit, 10, const Color(0xFFE040FB)),
    ];

    return Column(
      children: statDefs.map((s) {
        final ratio = (s.value / s.max).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  s.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: ratio),
                    builder: (_, v, child) {
                      return LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        backgroundColor: s.color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          s.color.withValues(alpha: 0.8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${s.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMovesRow(Creature creature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_fix_high,
          size: 14,
          color: Colors.white.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 6),
        Text(
          'MOVES',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 10),
        ...creature.moves.asMap().entries.map((entry) {
          final move = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _typeColor(move.type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _typeColor(move.type).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                move.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_creatures.length, (i) {
          final isSelected = i == _selectedIndex;
          final creature = _creatures[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isSelected ? 56 : 44,
              height: isSelected ? 56 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? RadialGradient(
                        colors: [
                          _rarityColor(creature.rarity).withValues(alpha: 0.3),
                          _typeColor(creature.type).withValues(alpha: 0.08),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
              ),
              child: Center(
                child: Text(
                  creature.name[0].toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: isSelected ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStartButton() {
    final rarityColor = _creatures.isNotEmpty
        ? _rarityColor(_creatures[_selectedIndex].rarity)
        : Colors.grey;
    final buttonTopColor = rarityColor.withValues(alpha: 0.8);
    final textColor = buttonTopColor.computeLuminance() > 0.18
        ? Colors.black.withValues(alpha: 0.87)
        : Colors.white;
    return GestureDetector(
      onTap: _startRun,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 48),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              rarityColor.withValues(alpha: 0.8),
              rarityColor.withValues(alpha: 0.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: rarityColor.withValues(alpha: 0.6)),
        ),
        child: Center(
          child: Text(
            'START RUN',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(CreatureType type) {
    switch (type) {
      case CreatureType.fire:
        return const Color(0xFFFF5252);
      case CreatureType.water:
        return const Color(0xFF448AFF);
      case CreatureType.earth:
        return const Color(0xFF8D6E63);
      case CreatureType.wind:
        return const Color(0xFF69F0AE);
      case CreatureType.shadow:
        return const Color(0xFF7C4DFF);
      case CreatureType.light:
        return const Color(0xFFFFD740);
      case CreatureType.storm:
        return const Color(0xFF00BCD4);
      case CreatureType.voidType:
        return const Color(0xFFB0BEC5);
    }
  }

  Color _rarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return const Color(0xFF9E9E9E);
      case Rarity.uncommon:
        return const Color(0xFF66BB6A);
      case Rarity.rare:
        return const Color(0xFF42A5F5);
      case Rarity.epic:
        return const Color(0xFFAB47BC);
      case Rarity.legendary:
        return const Color(0xFFFFD740);
      case Rarity.mythic:
        return const Color(0xFFFF5252);
      case Rarity.shiny:
        return const Color(0xFFE040FB);
    }
  }

  IconData _typeIcon(CreatureType type) {
    switch (type) {
      case CreatureType.fire:
        return Icons.local_fire_department;
      case CreatureType.water:
        return Icons.water_drop;
      case CreatureType.earth:
        return Icons.terrain;
      case CreatureType.wind:
        return Icons.air;
      case CreatureType.shadow:
        return Icons.dark_mode;
      case CreatureType.light:
        return Icons.wb_sunny;
      case CreatureType.storm:
        return Icons.thunderstorm;
      case CreatureType.voidType:
        return Icons.blur_on;
    }
  }
}

class _StatDef {
  final String label;
  final int value;
  final int max;
  final Color color;
  const _StatDef(this.label, this.value, this.max, this.color);
}

class _AnimatedRuneLoader extends StatefulWidget {
  const _AnimatedRuneLoader();

  @override
  State<_AnimatedRuneLoader> createState() => _AnimatedRuneLoaderState();
}

class _AnimatedRuneLoaderState extends State<_AnimatedRuneLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 6.2832,
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFF6B7DB3),
            size: 40,
          ),
        );
      },
    );
  }
}
