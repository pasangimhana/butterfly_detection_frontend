// home widget for the app

import 'package:flutter/material.dart';
import 'package:foodie/screens/history_map.dart';
import 'package:foodie/screens/prediction_history.dart';
import 'package:foodie/screens/remider_screen.dart';
import 'package:foodie/screens/signin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text('Butterfly Detection App'),
        ),
        body: Center(
          // Add a button to recognize butterfly with app_icon.png
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app_icon.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReminderScreen()),
                  );
                },
                child: Text('Recognize Butterfly'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                // go to prediction_history.dart without pushNamed
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreenUpdated()),
                  );
                },
                child: Text('View History'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the login page when the logout button is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: const Color.fromARGB(255, 36, 34, 34)),
                ),
              ),
            ],
          ),
          // logout button at the end


          ),

    );
  }
}


