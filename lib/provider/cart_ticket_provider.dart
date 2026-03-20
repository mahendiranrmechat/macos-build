import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartTicketNotifier extends StateNotifier<Set<String>> {
  CartTicketNotifier({Set<String>? cartTickerData})
      : super(cartTickerData ?? <String>{});
  Set<String> get cartTicketData => state;

  void addCartTicket(Set<String> customizedTicket) {
    state = <String>{...state, ...customizedTicket};
  }

  int get cartTicketLength => state.length;

  void removeCartTicket(String customizedTicket) {
    var tempState = state;
    tempState.remove(customizedTicket);
    state = {...tempState};
  }

  void replaceCartItems(Set<String> cartData) {
    state = cartData;
  }

  void clear() => state = <String>{};
}
