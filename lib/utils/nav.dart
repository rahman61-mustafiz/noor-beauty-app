import 'package:flutter/material.dart';

/// Navigates "back" safely.
///
/// Pops the current route when there is one to pop; otherwise (a root/tab
/// destination where "back" is ambiguous) returns to the Home screen.
///
/// It NEVER routes to the login screen, so an already-authenticated user
/// always stays logged in when pressing a back arrow.
void safeBack(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  } else {
    navigator.pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
