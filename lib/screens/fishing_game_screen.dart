import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _Phase { ready, casting, waiting, bite, reeling, success, failure }

class FishingGameScreen extends StatefulWidget {
  final void Function(bool success) onResult;

  const FishingGameScreen({super.key, required this.onResult});

  @override
  State<FishingGameScreen> createState() => _FishingGameScreenState();
}

class _FishingGameScreenState extends State<FishingGameScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.ready;
  final _rng = Random();

  late AnimationController _castController;
  late AnimationController _rodBendController;
  late Animation<double> _castAnim;
  late Animation<double> _rodBendAnim;

  double _reelProgress = 0.0;
  // Increased grace and reduced speed for easier catching as requested
  static const double _reelSpeed = 0.05; 
  static const double _reelDecay = 0.015;

  Timer? _biteTimer;
  Timer? _reelTimer;

  // Sweet spot variables
  double _targetPosition = 0.5;
  // Widened target width for more forgiveness
  final double _targetWidth = 0.35; 
  double _successProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _castController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _castAnim = CurvedAnimation(
      parent: _castController,
      curve: Curves.easeInOut,
    );

    _rodBendController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _rodBendAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rodBendController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _castController.dispose();
    _rodBendController.dispose();
    _biteTimer?.cancel();
    _reelTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    switch (_phase) {
      case _Phase.ready:
        _cast();
      case _Phase.bite:
        _startReeling();
      case _Phase.reeling:
        _reel();
      case _Phase.success:
      case _Phase.failure:
        widget.onResult(_phase == _Phase.success);
      default:
        break;
    }
  }

  void _cast() {
    setState(() => _phase = _Phase.casting);
    _castController.forward().then((_) {
      setState(() => _phase = _Phase.waiting);
      _biteTimer = Timer(
        Duration(milliseconds: 2000 + _rng.nextInt(3000)),
        _onBite,
      );
    });
  }

  void _onBite() {
    setState(() => _phase = _Phase.bite);
    _rodBendController.forward();
    HapticFeedback.heavyImpact();

    Timer(const Duration(seconds: 4), () {
      if (_phase == _Phase.bite) {
        _fail();
      }
    });
  }
void _startReeling() {
  setState(() => _phase = _Phase.reeling);
  _reelProgress = 0.0;
  _successProgress = 0.0;
  _reelTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
    setState(() {
      _updateFishingLogic();
      _reelProgress = (_reelProgress - _reelDecay).clamp(0.0, 1.0);
      if (_reelProgress <= 0 && _phase == _Phase.reeling) {
        _fail();
      }
    });
  });
}

void _updateFishingLogic() {
  _targetPosition = (_targetPosition + (_rng.nextDouble() - 0.5) * 0.04)
      .clamp(0.1, 0.9);
}

void _reel() {
  _reelProgress = (_reelProgress + _reelSpeed).clamp(0.0, 1.0);

  if (_reelProgress > _targetPosition - _targetWidth / 2 &&
      _reelProgress < _targetPosition + _targetWidth / 2) {
    _successProgress = (_successProgress + 0.06).clamp(0.0, 1.0);
  } else {
    _successProgress = (_successProgress - 0.015).clamp(0.0, 1.0);
  }

  if (_successProgress >= 1.0) {
    _reelTimer?.cancel();
    _succeed();
  }
}
  void _succeed() {
    setState(() => _phase = _Phase.success);
    _rodBendController.reverse();
  }

  void _fail() {
    _biteTimer?.cancel();
    _reelTimer?.cancel();
    _rodBendController.reverse();
    setState(() => _phase = _Phase.failure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            CustomPaint(
              painter: _FishingPainter(
                phase: _phase,
                castProgress: _castAnim.value,
                rodBend: _rodBendAnim.value,
                reelProgress: _reelProgress,
                targetPosition: _targetPosition,
                targetWidth: _targetWidth,
              ),
              size: Size.infinite,
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 16,
              child: _buildPhaseLabel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseLabel() {
    String text;
    Color color;
    switch (_phase) {
      case _Phase.ready: text = 'TAP TO CAST'; color = Colors.amber;
      case _Phase.casting: text = '...'; color = Colors.orange;
      case _Phase.waiting: text = 'WAITING...'; color = Colors.cyan;
      case _Phase.bite: text = 'TAP TO REEL IN!'; color = Colors.redAccent;
      case _Phase.reeling: text = 'TAP TAP TAP!'; color = Colors.red;
      case _Phase.success: text = 'SUCCESS! TAP TO EXIT'; color = Colors.greenAccent;
      case _Phase.failure: text = 'MISSED! TAP TO EXIT'; color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
    );
  }
}

class _FishingPainter extends CustomPainter {
  final _Phase phase;
  final double castProgress;
  final double rodBend;
  final double reelProgress;
  final double targetPosition;
  final double targetWidth;

  _FishingPainter({
    required this.phase,
    required this.castProgress,
    required this.rodBend,
    required this.reelProgress,
    required this.targetPosition,
    required this.targetWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Basic drawing of pond/rod based on provided code structure
    final pondTop = size.height * 0.4;
    canvas.drawRect(Rect.fromLTWH(0, pondTop, size.width, size.height - pondTop), Paint()..color = const Color(0xFF1E40AF));

    final rodBaseX = size.width * 0.18;
    final rodBaseY = size.height * 0.38;
    canvas.drawLine(Offset(rodBaseX, rodBaseY), Offset(rodBaseX + 150 + rodBend * 10, rodBaseY - 100 + rodBend * 5), Paint()..color = Colors.brown..strokeWidth = 6);

    if (phase == _Phase.reeling) {
        final centerX = size.width / 2;
        final centerY = size.height * 0.7;
        final radius = size.width * 0.35;
        canvas.drawArc(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius), pi + 0.5, pi - 1.0, false, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 20);
        final startAngle = (pi + 0.5) + ((pi - 1.0) * (targetPosition - targetWidth / 2));
        canvas.drawArc(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius), startAngle, (pi - 1.0) * targetWidth, false, Paint()..color = Colors.greenAccent..style = PaintingStyle.stroke..strokeWidth = 16);
        final indicatorAngle = pi + 0.5 + ((pi - 1.0) * reelProgress);
        canvas.drawLine(Offset(centerX + radius * cos(indicatorAngle) - 10, centerY + radius * sin(indicatorAngle) - 10), Offset(centerX + radius * cos(indicatorAngle) + 10, centerY + radius * sin(indicatorAngle) + 10), Paint()..color = Colors.white..strokeWidth = 6);
    }
  }

  @override
  bool shouldRepaint(covariant _FishingPainter oldDelegate) => true;
}
