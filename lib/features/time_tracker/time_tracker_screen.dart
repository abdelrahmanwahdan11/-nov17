import 'package:flutter/material.dart';

class TimeTrackerScreen extends StatefulWidget {
  const TimeTrackerScreen({super.key});

  @override
  State<TimeTrackerScreen> createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = false;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _running) {
          setState(() => _elapsed += const Duration(seconds: 1));
          _controller.forward(from: 0);
        }
      });
  }

  void _start() {
    setState(() {
      _running = true;
      _controller.forward(from: 0);
    });
  }

  void _pause() {
    setState(() {
      _running = false;
      _controller.stop();
    });
  }

  void _stop() {
    setState(() {
      _running = false;
      _controller.stop();
      _controller.reset();
      _elapsed = Duration.zero;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 12,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('$minutes:$seconds', style: Theme.of(context).textTheme.displayMedium),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(onPressed: _running ? null : _start, child: const Text('Start')),
                FilledButton(onPressed: _running ? _pause : null, child: const Text('Pause')),
                OutlinedButton(onPressed: _stop, child: const Text('Stop')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
