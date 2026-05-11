// lib/game/puzzle_sequencer.dart (NEW – puzzle logic)
import 'dart:math';
import 'types.dart';

class ElementSequencerLogic {
  final List<CreatureType> _elements = CreatureType.values.toList();
  late List<CreatureType> _sequence;
  int _currentInputIndex = 0;

  void generateSequence(int length) {
    final rng = Random();
    _sequence = List.generate(length, (_) => _elements[rng.nextInt(_elements.length)]);
    _currentInputIndex = 0;
  }

  List<CreatureType> get sequence => List.unmodifiable(_sequence);

  bool addInput(CreatureType type) {
    if (_currentInputIndex >= _sequence.length) return false;
    if (_sequence[_currentInputIndex] == type) {
      _currentInputIndex++;
      return true;
    } else {
      // Wrong input – reset or game over
      _currentInputIndex = 0;
      return false;
    }
  }

  bool get isComplete => _currentInputIndex == _sequence.length;

  void reset() {
    generateSequence(_sequence.length);
  }
}