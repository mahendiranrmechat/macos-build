import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/widgets/my_lotteries/to_be_drawn_view.dart';
import 'package:psglotto/view/widgets/my_lotteries/won_view.dart';

import 'drawn_view.dart';

class ResultTypeTabView extends ConsumerStatefulWidget {
  final int categoryId;
  final bool showOnlyToBeDrawn; // new optional flag
  const ResultTypeTabView({
    Key? key,
    required this.categoryId,
    this.showOnlyToBeDrawn = false, // default false to show all tabs
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResultTypeTabViewState createState() => _ResultTypeTabViewState();
}

class _ResultTypeTabViewState extends ConsumerState<ResultTypeTabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  late List<Tab> _tabs;
  late List<Widget> _tabViews;

  @override
  void initState() {
    super.initState();

    // Build tabs based on the flag
    if (widget.showOnlyToBeDrawn) {
      _tabs = [const Tab(text: 'To be drawn')];
      _tabViews = [ToBeDrawnView(categoryId: widget.categoryId)];
    } else {
      _tabs = const [
        Tab(text: 'To be drawn'),
        Tab(text: 'Drawn'),
        Tab(text: 'Won'),
      ];
      _tabViews = [
        ToBeDrawnView(categoryId: widget.categoryId),
        DrawnView(categoryId: widget.categoryId),
        WonView(categoryId: widget.categoryId),
      ];
    }

    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: Column(
          children: [
            if (_tabs.length > 1)
              TabBar(
                unselectedLabelColor: Colors.black87,
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BubbleTabIndicator(
                  indicatorHeight: 35.0,
                  indicatorColor: kPrimarySeedColor!,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  indicatorRadius: 1,
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                controller: _controller,
                tabs: _tabs,
              ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: _tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
