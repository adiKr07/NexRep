import 'dart:async';
import 'package:flutter/foundation.dart';
import 'timer_session.dart';

class StopwatchSession extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _stopwatch.elapsed;
  bool get isActive => _stopwatch.elapsed > Duration.zero;

  void start() {
    timerSession.reset();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) => notifyListeners());
    notifyListeners();
  }

  void pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }
}

final stopwatchSession = StopwatchSession();