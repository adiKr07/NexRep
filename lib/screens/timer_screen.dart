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
    
    timerSession.addListener(_onSessionChanged);
  }

  Future<void> _loadLastDuration() async {
    
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