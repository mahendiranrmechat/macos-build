import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/view/claim_view.dart';
import 'package:psglotto/view/home_view.dart';
import 'package:psglotto/view/profile_view.dart';
import 'package:psglotto/view/result_view.dart';
import 'package:psglotto/view/saleReport.dart';

import 'my_lotteries_view.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({Key? key}) : super(key: key);

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _selectedIndex = 0;
  bool isSaleReportEnable = false;

  @override
  void initState() {
    isSaleReportEnable = ApiService.menuList.any((menu) => menu["menuId"] == 9);
    if (kDebugMode) {
      print("The sale report $isSaleReportEnable");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mobileScreens = [
      const HomeView(),
      const ResultView(),
      const ClaimView(),
      const MyLotteriesView(),
      if (isSaleReportEnable) const SaleReportScreen(),
      const ProfileView(),
    ];

    List<BottomNavigationBarItem> bottomNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Result',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_num), // 🎫 looks like a ticket
        label: 'Claim',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.file_copy),
        label: 'My History ',
      ),
      if (isSaleReportEnable)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Report',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        items: bottomNavBarItems,
      ),
      body: mobileScreens.elementAt(_selectedIndex),
    );
  }
}
