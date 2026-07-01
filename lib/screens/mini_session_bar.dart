import 'package:flutter/material.dart';
import 'timer_session.dart';
import 'stopwatch_session.dart';
import 'timer_screen.dart';
import 'stopwatch_screen.dart';
import '../theme/app_colors.dart';


class MiniSessionBar extends StatelessWidget {
  const MiniSessionBar({super.key});

  String _formatTimer(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatStopwatch(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([timerSession, stopwatchSession]),
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;

        Widget? content;

        if (timerSession.isActive) {
          content = _BarContent(
            icon: Icons.hourglass_bottom,
            label: _formatTimer(timerSession.remaining),
            isRunning: timerSession.isRunning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimerScreen()),
            ),
            onPlayPause: () {
              if (timerSession.isRunning) {
                timerSession.pause();
              } else {
                timerSession.start();
              }
            },
          );
        } else if (stopwatchSession.isActive) {
          content = _BarContent(
            icon: Icons.timer_outlined,
            label: _formatStopwatch(stopwatchSession.elapsed),
            isRunning: stopwatchSession.isRunning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StopwatchScreen()),
            ),
            onPlayPause: () {
              if (stopwatchSession.isRunning) {
                stopwatchSession.pause();
              } else {
                stopwatchSession.start();
              }
            },
          );
        }

        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: content == null
              ? const SizedBox.shrink()
              : Container(
                  key: const ValueKey('mini_bar'),
                  margin: const EdgeInsets.fromLTRB(8, 1, 8, 0),
                  child: IntrinsicWidth(
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      child: content,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _BarContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRunning;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const _BarContent({
    required this.icon,
    required this.label,
    required this.isRunning,
    required this.onTap,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15,0,0,0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: onPlayPause,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}