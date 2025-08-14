



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showLogoutDialog(BuildContext context) {
  final client = Supabase.instance.client;

  showDialog(
    context: context,
    barrierDismissible: true, // allows tapping outside to dismiss
    builder: (context) => AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            try {
              await client.auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            } catch (e) {
              Get.snackbar("Error", e.toString());
            }
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ).then((_) {
    // This runs after dialog is dismissed (even by tapping outside)
    if (Navigator.canPop(context)) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushNamed(context, '/home');
    }
  });
}