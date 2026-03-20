import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/view/change_password_view.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/printer_settings.dart';
import 'package:psglotto/view/widgets/printer_settings_web.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/game_init_loader.dart';

import '../provider/providers.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  String username = SharedPref.instance.getString("username") ?? "-";

  Future<void> onRefresh() async {
    // ref.refresh(lobbyProvider);
    // ignore: unused_result
    ref.refresh(balanceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue balance = ref.watch(balanceProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Account"),
        actions: [CustomCloseButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(username),
              trailing: balance.maybeWhen(
                data: (balance) {
                  return RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Icon(
                            Icons.stars_sharp,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: " ${balance.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
                error: (e, s) {
                  return ElevatedButton(
                    onPressed: () async {
                      bool networkStatus =
                          await Helper.checkNetworkConnection();
                      if (networkStatus) {
                        onRefresh();
                      } else {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        showSnackBar(context, "Check your internet connection");
                      }
                    },
                    child: const Text("Retry"),
                  );
                },
                loading: () {
                  return const SizedBox(
                    width: 50.0,
                    child: LinearProgressIndicator(),
                  );
                },
                orElse: () {
                  return Container();
                },
              ),
            ),
            ListTile(
              title: const Text("Change Password"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordView(),
                ),
              ),
            ),
            ListTile(
              title: const Text("Printer Settings"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
              ),
              onTap: () {
                if (kIsWeb) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrinterSettingsWeb(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrinterSettings(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
