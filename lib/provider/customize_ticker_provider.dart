import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomizeTicketNotifier extends StateNotifier<Set<String>> {
  CustomizeTicketNotifier({Set<String>? customizeTickerData})
      : super(customizeTickerData ?? <String>{});

  Set<String> get customizeTickerData => state;

  void addCustomizedTicket(Set<String> customizedTicket) =>
      state = <String>{...state, ...customizedTicket};

  int get customizedTicketLength => state.length;

  void removeCustomizedTicket(String customizedTicket) {
    var tempState = state;
    tempState.remove(customizedTicket);
    state = {...tempState};
  }

  void clear() => state = <String>{};
}
