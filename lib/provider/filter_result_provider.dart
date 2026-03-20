import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultFilterNotifier extends StateNotifier<String> {
  ResultFilterNotifier({String? resultFilterData})
      : super(resultFilterData ?? "");
  String get resultFilterData => state;

  void setResultFilter(String resultFilter) {
    String tempState = resultFilter;
    state = tempState;
  }

  void clear() => state = "";
}
