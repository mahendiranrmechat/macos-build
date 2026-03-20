import 'package:flutter/material.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'm2_indicator.dart';

class CustomTab extends StatefulWidget implements PreferredSizeWidget {
  final void Function(int) onDone;
  final List<Widget> tabs;

  /// NEW ➜ Accept external controller
  final TabController? controller;

  final double? indicatorHeight;
  final Color? indicatorColor;
  final MD2IndicatorSize? indicatorSize;
  final Color? labelColor;
  final FontWeight? labelFontWeight;
  final Color? unselectedLabelColor;
  final bool? isScrollable;

  const CustomTab({
    Key? key,
    required this.tabs,
    required this.onDone,
    this.controller,
    this.indicatorHeight = 3,
    this.indicatorColor = const Color(0xff1c7d4a),
    this.indicatorSize = MD2IndicatorSize.full,
    this.labelColor = const Color(0xff1c7d4a),
    this.labelFontWeight = FontWeight.w700,
    this.unselectedLabelColor = Colors.black,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  State<CustomTab> createState() => _CustomTabState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class _CustomTabState extends State<CustomTab>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isExternalController = false;

  @override
  void initState() {
    super.initState();

    // Check if parent passed the controller
    isExternalController = widget.controller != null;

    tabController = widget.controller ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
        );

    // Listener for tab change
    tabController.addListener(() {
      if (!mounted) return;
      if (!tabController.indexIsChanging) {
        widget.onDone(tabController.index);
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-sync controller if parent updates it dynamically
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      tabController = widget.controller!;
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Only dispose if it's created locally
    if (!isExternalController) {
      tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TabBar(
        controller: tabController,
        labelStyle: TextStyle(
          fontWeight: widget.labelFontWeight,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: widget.labelColor,
        unselectedLabelColor: widget.unselectedLabelColor,
        isScrollable: widget.isScrollable!,
        indicator: MD2Indicator(
          indicatorHeight: widget.indicatorHeight!,
          indicatorColor: kPrimarySeedColor!,
          indicatorSize: widget.indicatorSize!,
        ),
        tabs: widget.tabs,
      ),
    );
  }
}
