import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/login_view.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/snackbar.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  bool obscurePassworOne = true;
  bool obscurePasswordTwo = true;

  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController(),
      newPasswordController = TextEditingController();

  String validatePassword(String value) {
    RegExp passwordRegex = RegExp(
        r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{5,15}$');

    if (value.isEmpty) {
      return 'Please enter password';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Enter valid password';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Change Password"),
        actions: [CustomCloseButton()],
      ),
      body: Form(
        key: _changePasswordFormKey,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                autocorrect: false,
                obscureText: obscurePassworOne,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (value) {
                  RegExp passwordRegex = RegExp(
                      r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{5,15}$');

                  if (value!.isEmpty) {
                    return 'Please enter password';
                  } else if (!passwordRegex.hasMatch(value)) {
                    return 'Enter valid password';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  // do nothing
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 22.0,
                  ),
                  hintText: "Old Password",
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIcon: IconButton(
                    iconSize: 20.0,
                    onPressed: () => setState(() {
                      obscurePassworOne = !obscurePassworOne;
                    }),
                    icon: Icon(
                      obscurePassworOne
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: newPasswordController,
                autocorrect: false,
                obscureText: obscurePasswordTwo,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (value) {
                  RegExp passwordRegex = RegExp(
                      r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{5,15}$');

                  if (value!.isEmpty) {
                    return 'Please enter password';
                  } else if (!passwordRegex.hasMatch(value)) {
                    return 'Enter valid password';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  // do nothing
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 22.0,
                  ),
                  hintText: "New Password",
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIcon: IconButton(
                    iconSize: 20.0,
                    onPressed: () => setState(() {
                      obscurePasswordTwo = !obscurePasswordTwo;
                    }),
                    icon: Icon(
                      obscurePasswordTwo
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 45.0,
                child: ElevatedButton(
                  onPressed: () async {
                    _changePasswordFormKey.currentState!.save();
                    if (_changePasswordFormKey.currentState!.validate()) {
                      bool networkStatus =
                          await Helper.checkNetworkConnection();
                      if (networkStatus) {
                        ApiService.changePassword(oldPasswordController.text,
                                newPasswordController.text)
                            .then((value) {
                          if (value == "Success") {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully'),
                              ),
                            );
                            if (!mounted) return;

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginView(),
                                ),
                                (route) => false);
                          }
                        }).onError((error, stackTrace) {
                          ExceptionHandler.showSnack(
                              errorCode: error.toString(), context: context);
                        });
                      } else {
                        if (!mounted) return;
                        showSnackBar(context, "Check your internet connection");
                      }
                    }
                  },
                  child: const Text("Change Password"),
                ),
              ),
              const Spacer(),
              const Text(
                "Example : eXample@134,\nAllowed special characters : [#%*+=@&!?\$] \nMinimum length : 5 characters \nMaximum length : 15 characters",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
