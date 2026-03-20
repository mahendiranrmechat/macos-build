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

class MyLotteriesCancelView extends ConsumerStatefulWidget {
  final int categoryIdToShow; //  only show this category
  final String gameId;
  const MyLotteriesCancelView(
      {Key? key, required this.gameId, required this.categoryIdToShow})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyLotteriesCancelViewState createState() => _MyLotteriesCancelViewState();
}

class _MyLotteriesCancelViewState extends ConsumerState<MyLotteriesCancelView>
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
    AsyncValue<List<CategoryList>> categoryAsyncData =
        ref.watch(categoryProvider);

    return categoryAsyncData.when(
      data: (data) {
        // Filter categories based on provided categoryId
        final filteredData =
            data.where((c) => c.categoryId == widget.categoryIdToShow).toList();

        tabCount = filteredData.length;

        if (controller.length != tabCount) {
          controller = TabController(vsync: this, length: tabCount);
        }

        return Scaffold(
          appBar: CustomTab(
            tabs: getCategory(filteredData),
            onDone: (index) {
              controller.animateTo(index);
            },
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: getCategoryTab(filteredData, widget.gameId),
          ),
        );
      },
      error: (error, s) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
        });
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No Internet connection"),
              const SizedBox(height: kDefaultPadding),
              ElevatedButton(
                onPressed: () async {
                  bool networkStatus = await Helper.checkNetworkConnection();
                  if (networkStatus) {
                    // ignore: unused_result
                    ref.refresh(categoryProvider);
                  } else {
                    if (!mounted) return;
                    showSnackBar(context, "Check your internet connection");
                  }
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

List<Widget> getCategoryTab(List<CategoryList> categories, String gameId) {
  return categories.map((category) {
    switch (category.categoryId) {
      case 1:
        return const ResultTypeTabView(
          categoryId: 1,
          showOnlyToBeDrawn: true,
        );
      case 2:
        return ResultTypeTabView2D(
          categoryId: 2,
          showOnlyToBeDrawn: true,
          gameId: gameId,
        );
      case 3:
        return ResultTypeTabView3D(
          categoryId: 3,
          gameId: gameId,
          showOnlyToBeDrawn: true,
        );
      default:
        return const SizedBox();
    }
  }).toList();
}

List<Widget> getCategory(List<CategoryList> categories) {
  return categories.map((category) {
    switch (category.categoryId) {
      case 1:
        return const Tab(text: 'Lotto');
      case 2:
        return const Tab(text: '2D');
      case 3:
        return const Tab(text: '3D');
      default:
        return const SizedBox();
    }
  }).toList();
}
