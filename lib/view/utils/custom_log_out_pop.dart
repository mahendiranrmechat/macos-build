import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

showLogoutConfirmationDialog(
    BuildContext context, String title, String content, bool homeView) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title), //const Text("Confirm Logout"),
        content:
            Text(content), //const Text("Are you sure you want to logout?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // No, do not logout
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Yes, log out
              // if(homeView){
              //    Navigator.of(context).pop(true); // Yes, log out
              // }
              // else{
              //    //Navigator.of(context).pop(true); // Yes, log out
              //    windowManager.close();

              // }
            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
}
