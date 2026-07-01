import 'dart:async';
import 'package:flutter/foundation.dart';
import 'stopwatch_session.dart';  

class TimerSession extends ChangeNotifier {
  Duration totalDuration = const Duration(seconds: 60);
  Duration remaining = const Duration(seconds: 60);
  bool isRunning = false;

  Timer? _ticker;
  DateTime? _endTime; // wall-clock target, not just a counted-down number —
  // this keeps the countdown accurate even if individual ticks get delayed.

  // True any time there's a countdown in progress or paused mid-way —
  // used to decide whether the floating mini-bar should show at all.
  bool get isActive => remaining < totalDuration && remaining > Duration.zero || isRunning;

  bool get isFinished => remaining == Duration.zero && totalDuration > Duration.zero;

  void setDuration(Duration newDuration) {
    if (isRunning) return; // can't edit while actively counting down
    totalDuration = newDuration;
    remaining = newDuration;
    notifyListeners();
  }

  void start() {
    stopwatchSession.reset();
    if (isRunning || remaining <= Duration.zero) return;
    isRunning = true;
    _endTime = DateTime.now().add(remaining);

    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final diff = _endTime!.difference(DateTime.now());
      if (diff <= Duration.zero) {
        remaining = Duration.zero;
        _stopTicker();
        reset();
        isRunning = false;
      } else {
        remaining = diff;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    _stopTicker();
    isRunning = false;
    notifyListeners();
  }

  void reset() {
    _stopTicker();
    isRunning = false;
    remaining = totalDuration;
    notifyListeners();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final timerSession = TimerSession();