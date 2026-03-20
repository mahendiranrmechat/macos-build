import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyLotteriesFilterNotifier extends StateNotifier<String> {
  MyLotteriesFilterNotifier({String? myLotteriesFilterData})
      : super(myLotteriesFilterData ?? "");
  String get myLotteriesFilterData => state;

  void setResultFilter(String myLotteriesFilter) {
    String tempState = myLotteriesFilter;
    state = tempState;
  }

  void clear() => state = "";
}
