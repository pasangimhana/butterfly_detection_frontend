import 'package:flutter/material.dart';
import 'package:foodie/main.dart';

void showSnackBar({required bool isError, required String msg}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content: Text(
        msg,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
