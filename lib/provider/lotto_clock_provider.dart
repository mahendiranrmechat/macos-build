import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

int lottoCurrentTimeServer = -1;

class ClockLotto extends StateNotifier<DateTime> {
  ClockLotto(int initialTimestamp)
      : _initialTime = DateTime.fromMillisecondsSinceEpoch(initialTimestamp),
        super(DateTime.fromMillisecondsSinceEpoch(initialTimestamp)) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _incrementTime();
    });
  }

  final DateTime _initialTime;
  late final Timer _timer;

  void _incrementTime() {
    state = state.add(const Duration(seconds: 1));
  }

  // Format the DateTime to the required format
  String get formattedTime {
    final formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    final datePart = formatter.format(state);
    final microsecondPart = state.microsecond.toString().padLeft(6, '0');
    return "$datePart.$microsecondPart";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}


// Provider to initialize and manage the Clock state
final lottoClockProvider = StateNotifierProvider<ClockLotto, DateTime>((ref) {
  int serverTimestamp = lottoCurrentTimeServer;
  return ClockLotto(serverTimestamp);
});
