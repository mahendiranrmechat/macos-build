import 'package:flutter/material.dart';

import 'constants.dart';

final appTheme = ThemeData(
  useMaterial3: false,
  colorSchemeSeed: kPrimarySeedColor!,
  scaffoldBackgroundColor: kScaffoldBackgroundColor,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(color: kPrimarySeedColor!),
    unselectedIconTheme: const IconThemeData(color: Colors.grey),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
