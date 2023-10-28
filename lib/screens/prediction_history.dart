import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foodie/screens/signin_page.dart'; // Import your login page

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> historyList = [];
  final String apiUrl = 'http://52.184.86.31/history';

  Future<void> fetchHistory() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        historyList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load history');
    }
  }

  Future<void> deleteHistory(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      fetchHistory(); // Refresh the list after deleting 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete history.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  String formatLocation(String location) {
    List<String> words = location.split(' ');
    if (words.length > 8) {
      return words.sublist(0, 8).join(' ') + '\n' + words.sublist(8).join(' ');
    }
    return location;
  }

  // New method to format butterfly class
  String formatButterflyClass(String detectionClass) {
    if (detectionClass.length > 25) {
      return detectionClass.substring(0, 25) + '\n' + detectionClass.substring(25);
    }
    return detectionClass;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.blue;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Butterfly Detection History'),
      //   actions: <Widget>[
      //     TextButton(
      //       onPressed: () {
      //         // Navigate to the login page when the logout button is clicked
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => SignInPage()),
      //         );
      //       },
      //       child: Text(
      //         'Logout',
      //         style: TextStyle(color: const Color.fromARGB(255, 36, 34, 34)),
      //       ),
      //     ),
      //   ],
      // ),
      body: ListView.builder(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Delete Icon
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteHistory(item['id']);
                    },
                  ),
                ),
                // History Content
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bug_report, color: primaryColor),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Butterfly Class: ${formatButterflyClass(item['detection_class'])}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: primaryColor),
                          SizedBox(width:5),
                          Expanded(
                            child: Text(
                              'Location: ${formatLocation(item['location'])}',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: primaryColor),
                          SizedBox(width: 5),
                          Text(
                            'Date: ${item['time']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
