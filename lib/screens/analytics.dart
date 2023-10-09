import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants.dart';
import 'package:foodie/firebase_service.dart';
import 'package:foodie/main_layout.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;
  List<bool> _selections = List.generate(7, (index) => false);
  int dayNamesIndex = 0;
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  late Map<String, double> percentageMap;
  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.red,
            value: percentageMap['Carbs'],
            title: '${percentageMap['Carbs']!.toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: percentageMap['Protein'],
            title: '${percentageMap['Protein']!.toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.yellow,
            value: percentageMap['Fat'],
            title: '${percentageMap['Fat']!.toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.amber,
            value: percentageMap['Sugar'],
            title: '${percentageMap['Sugar']!.toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MainLayout(
      title: 'Analytics',
      customBody: Container(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleSwitch(
                activeBgColor: [AppColors.primaryColor],
                inactiveBgColor: AppColors.primaryColor.withOpacity(0.3),
                minHeight: 30,
                initialLabelIndex: dayNamesIndex,
                totalSwitches: 7,
                labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                onToggle: (index) {
                  print('switched to: $index');
                  setState(() {
                    dayNamesIndex = index ?? 0;
                  });
                },
              ),
            ),
            FutureBuilder(
                future:
                    FirebaseService().calculatePercentage(days[dayNamesIndex]),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No meals found for ');
                  } else {
                    percentageMap = snapshot.data!;
                    return Column(
                      children: [
                        SizedBox(
                          height: size.width - 150,
                          width: size.width - 150,
                          child: _checkDataAvailable()
                              ? PieChart(
                                  PieChartData(
                                    // pieTouchData: PieTouchData(
                                    //   touchCallback:
                                    //       (FlTouchEvent event, pieTouchResponse) {
                                    //     setState(() {
                                    //       if (!event.isInterestedForInteractions ||
                                    //           pieTouchResponse == null ||
                                    //           pieTouchResponse.touchedSection ==
                                    //               null) {
                                    //         touchedIndex = -1;
                                    //         return;
                                    //       }
                                    //       touchedIndex = pieTouchResponse
                                    //           .touchedSection!.touchedSectionIndex;
                                    //     });
                                    //   },
                                    // ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                    sections: showingSections(),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                      'No records belong to ${days[dayNamesIndex]}'),
                                ),
                        ),
                        Container(
                          width: size.width - 100,
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primaryColor),
                          child: Table(children: [
                            _nutritionIndicator(
                                nutrition: 'Carbs',
                                percentage:
                                    '${percentageMap['Carbs']!.toStringAsFixed(2)}%',
                                color: Colors.yellow),
                            _nutritionIndicator(
                                nutrition: 'Protein',
                                percentage:
                                    '${percentageMap['Protein']!.toStringAsFixed(2)}%',
                                color: Colors.red),
                            _nutritionIndicator(
                                nutrition: 'Fat',
                                percentage:
                                    '${percentageMap['Fat']!.toStringAsFixed(2)}%',
                                color: Colors.blue),
                            _nutritionIndicator(
                                nutrition: 'Sugar',
                                percentage:
                                    '${percentageMap['Sugar']!.toStringAsFixed(2)}%',
                                color: Colors.green)
                          ]),
                        )
                      ],
                    );
                  }
                }))
          ],
        ),
      ),
    );
  }

  TableRow _nutritionIndicator(
      {required String nutrition,
      required String percentage,
      required Color color}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: color,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  nutrition,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            percentage,
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _toggleButton({
    required String btnTitle,
    required int btnIndex,
  }) {
    return Container(
      height: 20,
      width: 30,
      decoration: BoxDecoration(
        color: _selections[btnIndex]
            ? AppColors.primaryColor.withOpacity(0.4)
            : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          width: 2,
          color: _selections[btnIndex]
              ? AppColors.primaryColor
              : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          btnTitle,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color:
                _selections[btnIndex] ? AppColors.primaryColor : Colors.black,
          ),
        ),
      ),
    );
  }

  String _getDayName(int dayIndex) {
    // You can customize this function to return the day names as needed.
    List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return daysOfWeek[dayIndex];
  }

  bool _checkDataAvailable() {
    if (percentageMap['Carbs'] == 0.0 &&
        percentageMap['Protein'] == 0.0 &&
        percentageMap['Fat'] == 0.0 &&
        percentageMap['Sugar'] == 0.0) {
      return false;
    } else {
      return true;
    }
  }
}
