import 'package:flutter/material.dart';
import 'package:foodie/constants.dart';

class MainLayout extends StatefulWidget {
  MainLayout({super.key, required this.customBody, this.title = ""});
  Widget customBody;
  String title;
  @override
  State<MainLayout> createState() => _MainLayoutrState();
}

class _MainLayoutrState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 40),
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: AppColors.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(3, 3), // changes position of shadow
                  ),
                ],
              ),
              height: size.height,
              width: size.width,
              child: Padding(
                padding: EdgeInsets.only(top: (size.height * 0.18) / 2),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20),
                height: size.height * 0.7,
                constraints: BoxConstraints(minHeight: size.height * 0.7),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: AppColors.primaryColor),
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: widget.customBody,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
