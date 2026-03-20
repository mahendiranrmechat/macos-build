//create update notifier class

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/init_game_others.dart';
import '../params/init_game_others_params.dart';

class InitGameOthersNotifier extends StateNotifier<InitGameOthers> {
  InitGameOthersNotifier(InitGameOthers state) : super(state);

  //need to update value

  void updateDrawStartTime(int drawStartTime) {
    state = state.copyWith(drawStartTime: drawStartTime);
  }

  void updateName(String name) {
    state = state.copyWith(gameName: name);
  }

  void updateBlock(bool setBlock) {
    if (!mounted || mounted) {
      state = state.copyWith(setBloack: setBlock);
    }
  }

  void updatedDrawBlocker(bool setDrawBlocker) {
    state = state.copyWith(setDrawBlocker: setDrawBlocker);
  }

  void updateDrawId(String drawId) {
    state = state.copyWith(drawId: drawId);
  }

  void updateRefresh(bool refresh) {
    if (mounted) {
      state = state.copyWith(refreshBool: refresh);
    }
  }

  void updatedResult(List<dynamic> results) {
    if (mounted) {
      state = state.copyWith(results: results);
    }
  }

  void updatedType(List<dynamic> types) {
    state = state.copyWith(types: types);
  }

  //? updated prize points
  void updatedPrize(List<Type> types) {
    state = state.copyWith(types: types);
  }
}

class InitGameOthersProvider {
  static Map<String, dynamic>? initGameOthersProvider;
  static Map<String, dynamic>? drawResult;
  static Map<String, dynamic> getDrawID = {};
  static bool timeBlocker = false;

  InitGameOthersProvider(InitGameOthersParams initGameOthersParams);
  // Refrese ref = Refrese();
  static void onSetInitGameOthers(dynamic res) {
    initGameOthersProvider = res;
  }

  static dynamic getInitGameOthers() {
    return initGameOthersProvider;
  }

  static void onSetLobbyDrawID(dynamic res) {
    getDrawID = res;
  }

  static dynamic getLobbyDrawID() {
    return getDrawID;
  }

  static void onSetDrawResult(dynamic res) {
    drawResult = res;
  }

  static dynamic getDrawResult() {
    return drawResult;
  }
}
