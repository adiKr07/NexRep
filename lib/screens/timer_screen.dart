import 'package:flutter/material.dart';
import 'timer.dart';
import 'timer_prefs.dart';
import 'timer_session.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLastDuration();
    // Whenever the session's duration changes (via drag-to-set), persist it
    // as the new "last used" value — works regardless of which screen
    // triggered the change, since the session is global.
    timerSession.addListener(_onSessionChanged);
  }

  Future<void> _loadLastDuration() async {
    // Only seed from saved prefs if nothing's already in progress —
    // otherwise reopening this screen mid-countdown would reset it.
    if (!timerSession.isActive) {
      final seconds = await TimerPrefs.getLastDurationSeconds();
      timerSession.setDuration(Duration(seconds: seconds));
    }
    setState(() => _loaded = true);
  }

  void _onSessionChanged() {
    if (!timerSession.isRunning) {
      TimerPrefs.setLastDurationSeconds(timerSession.totalDuration.inSeconds);
    }
  }

  @override
  void dispose() {
    timerSession.removeListener(_onSessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        centerTitle: true,
      ),
      body: const Center(child: CircularTimerWidget()),
    );
  }
}