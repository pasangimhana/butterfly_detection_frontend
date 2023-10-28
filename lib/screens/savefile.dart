import 'package:flutter/material.dart';
import 'package:flutter_split/flutter_split.dart';
import 'location_screen.dart'; // Import your LocationScreen
import 'history_screen.dart'; // Import your HistoryScreen

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        gripSize: 8,
        gripColor: Colors.grey,
        gripColorActive: Colors.blue,
        children: [
          LocationScreen(),
          HistoryScreen(),
        ],
      ),
    );
  }
}
