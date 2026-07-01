import 'package:flutter/material.dart';
import 'stopwatch.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
      ),
      body: const Center(child: StopwatchWidget()),
    );
  }
}