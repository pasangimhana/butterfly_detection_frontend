import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';
import 'location.dart'; // Import your LocationScreen
import 'prediction_history.dart'; // Import your HistoryScreen

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

