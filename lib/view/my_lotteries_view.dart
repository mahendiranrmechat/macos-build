import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/custom_tabbar.dart';
import 'package:psglotto/view/widgets/home/my_lotteries_2d/result_type_tab_view_2d.dart';
import 'package:psglotto/view/widgets/home/my_lotteries_3d/result_type_tab_view_3d.dart';
import 'package:psglotto/view/widgets/my_lotteries/result_type_tab_view.dart';
import 'package:psglotto/view/widgets/snackbar.dart';

import '../model/category.dart';
import '../provider/providers.dart';
import '../utils/exception_handler.dart';

class MyLotteriesView extends ConsumerStatefulWidget {
  final String? gameId;
  final int? categoryIdToShow; //  only show this category
  const MyLotteriesView({Key? key, this.gameId, this.categoryIdToShow})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyLotteriesViewState createState() => _MyLotteriesViewState();
}

class _MyLotteriesViewState extends ConsumerState<MyLotteriesView>
    with TickerProviderStateMixin {
  late TabController controller;
  int tabCount = 0;

  @override
  void initState() {
    super.initState();
    controller =
        TabController(vsync: this, length: 0); // Initialize with 0 length
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsyncData = ref.watch(categoryProvider);

    return categoryAsyncData.when(
      data: (data) {
        tabCount = data.length;

        // Initialize or update tab controller
        if (controller.length != tabCount) {
          controller = TabController(vsync: this, length: tabCount);

          // 👇 Add debug listener
          controller.addListener(() {
            if (!controller.indexIsChanging) {
              debugPrint("🟦 Selected Tab Index: ${controller.index}");
              debugPrint(
                  "🟦 Selected Category: ${data[controller.index].categoryName}");
              debugPrint(
                  "🟦 Category ID: ${data[controller.index].categoryId}");
            }
          });

          // Auto-select based on passed category
          if (widget.categoryIdToShow != null) {
            final matchingIndex = data.indexWhere(
              (cat) => cat.categoryId == widget.categoryIdToShow,
            );

            if (matchingIndex != -1) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                controller.animateTo(matchingIndex);
                debugPrint("🎯 Auto-scrolled to tab index: $matchingIndex");
              });
            }
          }
        }

        return Scaffold(
          appBar: CustomTab(
            controller: controller,
            tabs: getCategory(data),
            onDone: (index) => controller.animateTo(index),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: getCategoryTab(data, widget.gameId ?? ""),
          ),
        );
      },
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

List<Widget> getCategoryTab(List<CategoryList> categories, String gameId) {
  List<Widget> categoryWidget = <Widget>[];
  for (CategoryList category in categories) {
    if (category.categoryId == 1) {
      categoryWidget.add(const ResultTypeTabView(categoryId: 1));
    } else if (category.categoryId == 2) {
      categoryWidget.add(ResultTypeTabView2D(
        categoryId: 2,
        gameId: gameId,
      ));
    } else if (category.categoryId == 3) {
      categoryWidget.add(const ResultTypeTabView3D(categoryId: 3));
    }
  }
  return categoryWidget;
}

List<Widget> getCategory(List<CategoryList> categories) {
  List<Widget> categoryWidget = <Widget>[];
  for (CategoryList category in categories) {
    if (category.categoryId == 1) {
      categoryWidget.add(const Tab(text: 'Lotto'));
    } else if (category.categoryId == 2) {
      categoryWidget.add(const Tab(text: '2D'));
    } else if (category.categoryId == 3) {
      categoryWidget.add(const Tab(text: '3D'));
    }
  }
  return categoryWidget;
}
