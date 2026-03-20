import 'package:flutter/material.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/view/utils/custom_log_out_pop.dart';
import 'package:psglotto/view/utils/window_controls.dart';

class CustomCloseButton extends StatefulWidget {
  final Color iconColor;

  const CustomCloseButton({
    Key? key,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  State<CustomCloseButton> createState() => _CustomCloseButtonState();
}

class _CustomCloseButtonState extends State<CustomCloseButton> {
  bool _isHovering = false;
  bool showLoadingOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedScale(
          scale: _isHovering ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              children: [
                IconButton(
                  tooltip: "Close",
                  onPressed: () async {
                    debugPrint("am calling log out button");

                    // Confirm logout
                    bool confirmLogout = await showLogoutConfirmationDialog(
                        context,
                        "Confirm Exit",
                        "Are you sure you want to exit?",
                        false);

                    if (confirmLogout) {
                      debugPrint("Inside logout confirmation");

                      // Show loading overlay during the logout process
                      setState(() => showLoadingOverlay = true);

                      try {
                        // Call sign-out API
                        final result = await ApiService.signOut();
                        debugPrint("Sign out result: $result");

                        if (result == "Logged out") {
                          debugPrint("Logged out successfully");
                        } else {
                          debugPrint("Sign out failed: $result");
                        }

                        // Optional delay to simulate processing time
                        await Future.delayed(const Duration(milliseconds: 300));

                        // Attempt to close the window after sign-out
                        try {
                          await WindowControls.close();
                          debugPrint("Window closed after logout.");
                        } catch (e) {
                          debugPrint("Error during window close: $e");
                        }
                      } catch (e) {
                        setState(() {
                          showLoadingOverlay = false;
                        });
                        // Handle errors during sign-out
                        debugPrint("Error during sign out: $e");

                        // Optional: Handle cleanup or additional steps
                        await Future.delayed(const Duration(milliseconds: 300));
                        await WindowControls.close();
                      } finally {
                        setState(() {
                          showLoadingOverlay = false;
                        });
                        await WindowControls.close();
                      }
                    }
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: widget.iconColor,
                    size: 28,
                  ),
                ),
                if (showLoadingOverlay)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
