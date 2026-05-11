// lib/screens/puzzle_screen.dart (NEW – puzzle UI)
import 'package:flutter/material.dart';
import '../game/puzzle_sequencer.dart';
import '../game/types.dart';

class PuzzleScreen extends StatefulWidget {
  final int sequenceLength;
  final void Function(bool success) onResult;

  const PuzzleScreen({
    super.key,
    this.sequenceLength = 4,
    required this.onResult,
  });

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with SingleTickerProviderStateMixin {
  late ElementSequencerLogic logic;
  bool _showingSequence = true;
  int _currentShowIndex = 0;
  late AnimationController _controller;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    logic = ElementSequencerLogic();
    logic.generateSequence(widget.sequenceLength);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startShowingSequence();
  }

  void _startShowingSequence() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentShowIndex++;
          if (_currentShowIndex < logic.sequence.length) {
            _controller.reset();
            _controller.forward();
          } else {
            _showingSequence = false;
          }
        });
      }
    });
    _controller.forward();
  }

  void _onElementTap(CreatureType type) {
    if (_gameOver || _showingSequence) return;
    final correct = logic.addInput(type);
    if (!correct) {
      setState(() => _gameOver = true);
      widget.onResult(false);
    } else if (logic.isComplete) {
      widget.onResult(true);
    }
    setState(() {}); // re-render
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => widget.onResult(false),
        ),
        title: const Text('Element Sequencer', style: TextStyle(color: Colors.white70)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showingSequence)
              _buildDisplaySequence()
            else
              _buildInputGrid(),
            if (_gameOver)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Wrong sequence!', style: TextStyle(color: Colors.redAccent, fontSize: 24)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySequence() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(logic.sequence.length, (i) {
            final element = logic.sequence[i];
            final opacity = i <= _currentShowIndex ? 1.0 : 0.2;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  _iconForType(element),
                  size: 48,
                  color: _colorForType(element),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInputGrid() {
    final elements = CreatureType.values;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: elements.map((type) => GestureDetector(
        onTap: () => _onElementTap(type),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _colorForType(type).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _colorForType(type).withValues(alpha: 0.6)),
          ),
          child: Center(child: Icon(_iconForType(type), size: 32, color: _colorForType(type))),
        ),
      )).toList(),
    );
  }

  Color _colorForType(CreatureType type) {
    switch (type) {
      case CreatureType.fire: return const Color(0xFFFF5252);
      case CreatureType.water: return const Color(0xFF448AFF);
      case CreatureType.earth: return const Color(0xFF8D6E63);
      case CreatureType.wind: return const Color(0xFF69F0AE);
      case CreatureType.shadow: return const Color(0xFF7C4DFF);
      case CreatureType.light: return const Color(0xFFFFD740);
      case CreatureType.storm: return const Color(0xFF00BCD4);
      case CreatureType.voidType: return const Color(0xFFB0BEC5);
    }
  }

  IconData _iconForType(CreatureType type) {
    switch (type) {
      case CreatureType.fire: return Icons.local_fire_department;
      case CreatureType.water: return Icons.water_drop;
      case CreatureType.earth: return Icons.terrain;
      case CreatureType.wind: return Icons.air;
      case CreatureType.shadow: return Icons.dark_mode;
      case CreatureType.light: return Icons.wb_sunny;
      case CreatureType.storm: return Icons.thunderstorm;
      case CreatureType.voidType: return Icons.blur_on;
    }
  }
}