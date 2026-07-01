import 'package:flutter/material.dart';
import 'stopwatch_session.dart';

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget({super.key});

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: stopwatchSession,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _format(stopwatchSession.elapsed),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: colorScheme.onSurface,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleIconButton(
                  icon: stopwatchSession.isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: () {
                    if (stopwatchSession.isRunning) {
                      stopwatchSession.pause();
                    } else {
                      stopwatchSession.start();
                    }
                  },
                  filled: true,
                ),
                const SizedBox(width: 20),
                _CircleIconButton(
                  icon: Icons.refresh,
                  onPressed: stopwatchSession.reset,
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