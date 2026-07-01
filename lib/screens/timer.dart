import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'timer_session.dart';

// No longer owns any state itself — purely displays and controls the
// global `timerSession`, so it keeps working correctly no matter how many
// times this widget gets created/destroyed by navigation.
class CircularTimerWidget extends StatelessWidget {
  const CircularTimerWidget({super.key});

  void _adjustTime(int deltaSeconds) {
    if (timerSession.isRunning) return;
    final newTotal = (timerSession.totalDuration.inSeconds + deltaSeconds)
        .clamp(0, 99 * 60 + 59);
    timerSession.setDuration(Duration(seconds: newTotal));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: timerSession,
      builder: (context, child) {
        final isEditable = !timerSession.isRunning &&
            timerSession.remaining == timerSession.totalDuration;
        final totalMs = timerSession.totalDuration.inMilliseconds;
        final fraction = totalMs == 0
            ? 0.0
            : timerSession.remaining.inMilliseconds / totalMs;

        final displaySeconds = timerSession.remaining.inSeconds;
        final minutes = (displaySeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (displaySeconds % 60).toString().padLeft(2, '0');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _FlipDashRingPainter(
                      elapsedFraction: 1 - fraction,
                      color: colorScheme.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DraggableTimeDigits(
                            value: minutes,
                            enabled: isEditable,
                            onDragSeconds: (steps) => _adjustTime(steps * 60),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          _DraggableTimeDigits(
                            value: seconds,
                            enabled: isEditable,
                            onDragSeconds: (steps) => _adjustTime(steps * 5),
                          ),
                        ],
                      ),
                      Text(
                        isEditable ? 'DRAG TO SET' : 'REMAINING',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleIconButton(
                  icon: timerSession.isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: () {
                    if (timerSession.isRunning) {
                      timerSession.pause();
                    } else {
                      timerSession.start();
                    }
                  },
                  filled: true,
                ),
                const SizedBox(width: 20),
                _CircleIconButton(
                  icon: Icons.refresh,
                  onPressed: timerSession.reset,
                  filled: false,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: filled ? colorScheme.primary : Colors.transparent,
      shape: CircleBorder(
        side: filled ? BorderSide.none : BorderSide(color: colorScheme.onSurface.withOpacity(0.4)),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            color: filled ? colorScheme.onPrimary : colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _DraggableTimeDigits extends StatefulWidget {
  final String value;
  final bool enabled;
  final ValueChanged<int> onDragSeconds;

  const _DraggableTimeDigits({
    required this.value,
    required this.enabled,
    required this.onDragSeconds,
  });

  @override
  State<_DraggableTimeDigits> createState() => _DraggableTimeDigitsState();
}

class _DraggableTimeDigitsState extends State<_DraggableTimeDigits> {
  double _dragAccumulator = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: widget.enabled
          ? (details) {
              _dragAccumulator -= details.delta.dy;
              const stepSize = 20.0;
              while (_dragAccumulator.abs() >= stepSize) {
                final direction = _dragAccumulator > 0 ? 1 : -1;
                widget.onDragSeconds(direction);
                _dragAccumulator -= direction * stepSize;
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          widget.value,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: widget.enabled ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FlipDashRingPainter extends CustomPainter {
  final double elapsedFraction;
  final Color color;

  static const int dashCount = 60;
  static const double dashLength = 16;
  static const double dashWidth = 4;

  _FlipDashRingPainter({
    required this.elapsedFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - dashLength;
    const startAngle = -math.pi / 2;
    const windowSize = 1 / dashCount;

    final paint = Paint()
      ..color = color
      ..strokeWidth = dashWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashCount; i++) {
      final theta = startAngle + (i / dashCount) * 2 * math.pi;
      final dashThreshold = i * windowSize;
      final localProgress =
          ((elapsedFraction - dashThreshold) / windowSize).clamp(0.0, 1.0);
      final flipAngle = localProgress * (math.pi / 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(theta);
      canvas.translate(radius + dashLength / 2, 0);
      canvas.rotate(flipAngle);
      canvas.drawLine(
        Offset(-dashLength / 2, 0),
        Offset(dashLength / 2, 0),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlipDashRingPainter oldDelegate) {
    return oldDelegate.elapsedFraction != elapsedFraction;
  }
}