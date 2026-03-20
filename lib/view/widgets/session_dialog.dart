import 'package:flutter/material.dart';

import '../login_view.dart';

Future<void> sessionDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Session expired'),
        content: const Text('Login again to continue'),
        actions: <Widget>[
          TextButton(
            child: const Text('Login again'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false);
            },
          ),
        ],
      );
    },
  );
}
