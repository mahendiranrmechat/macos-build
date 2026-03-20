class GameConstant {
  static bool nextDrawBlocker = false;
  static bool setClearValue = false;
  static int timer = 0;
  static String selectedGameId = "";

  static void timerSet(int res) {
    timer = res;
  }

  static int timerGet() {
    return timer;
  }
}
