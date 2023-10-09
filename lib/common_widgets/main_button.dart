import 'package:flutter/material.dart';
import 'package:foodie/constants.dart';

class MainButton extends StatelessWidget {
  MainButton(
      {super.key,
      required this.size,
      required this.title,
      this.onTap});
  VoidCallback? onTap;
  final Size size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width - 100,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBlue,
          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
