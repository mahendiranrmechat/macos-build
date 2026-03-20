import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/model/category.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/custom_tabbar.dart';
import 'package:psglotto/view/widgets/result/lotto_2d_tab_view.dart';
import 'package:psglotto/view/widgets/result/lotto_3d_tab_view.dart';
import 'package:psglotto/view/widgets/snackbar.dart';

import '../utils/exception_handler.dart';
import 'widgets/result/lotto_tab_view.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({Key? key}) : super(key: key);

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView>
    with SingleTickerProviderStateMixin {
  int tabCount = 3;
  late TabController controller = TabController(vsync: this, length: tabCount);
  //now add the tabs list here=>

  //additionally you can initilize tab controller and dispose

  // @override
  // void initState() {
  //   super.initState();
  //
  //   controller.addListener(() {
  //     controller.animateTo(controller.index);
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<CategoryList>> categoryAsyncData =
        ref.watch(categoryProvider);
    return categoryAsyncData.when(data: (data) {
      setState(() {
        tabCount = data.length;
      });
      return Scaffold(
          appBar: CustomTab(
            // tabcontroller: controller,
            tabs: [
              ...getCategory(data),
            ], //here tabs are above mentioned tabs **additionally you can wrap CustomTab with SafeAre when required**
            onDone: (index) {
              controller
                  .animateTo(index); //if that doesn't work for you special case
            },
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: [...getCategoryTab(data)],
          ));
    }, error: (error, s) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ExceptionHandler.showSnack(
            errorCode: error.toString(), context: context);
      });

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No Internet connection"),
            const SizedBox(
              height: kDefaultPadding,
            ),
            ElevatedButton(
              onPressed: () async {
                bool networkStatus = await Helper.checkNetworkConnection();
                if (networkStatus) {
                  // ignore: unused_result
                  ref.refresh(categoryProvider);
                } else {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, "Check your internet connection");
                }
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}

List<Widget> getCategoryTab(List<CategoryList> categories) {
  List<Widget> categoryWidget = <Widget>[];
  for (CategoryList category in categories) {
    if (category.categoryId == 1) {
      categoryWidget.add(
        const LottoTabView(
          categoryId: 1,
        ),
      );
    }
    if (category.categoryId == 2) {
      // categoryWidget.add(const Text("pick"));
      categoryWidget.add(
        const LottoTabView2D(
          categoryId: 2,
        ),
      );
    }
    if (category.categoryId == 3) {
      categoryWidget.add(
        const LottoTabView3D(
          categoryId: 3,
        ),
      );
    }
  }
  return categoryWidget;
}

List<Widget> getCategory(List<CategoryList> categories) {
  List<Widget> categoryWidget = <Widget>[];
  for (CategoryList category in categories) {
    if (category.categoryId == 1) {
      categoryWidget.add(
        const Tab(
          text: 'Lotto',
        ),
      );
    }
    if (category.categoryId == 2) {
      categoryWidget.add(
        const Tab(
          text: '2D',
        ),
      );
    }
    if (category.categoryId == 3) {
      categoryWidget.add(
        const Tab(
          text: '3D',
        ),
      );
    }
  }

  return categoryWidget;
}
