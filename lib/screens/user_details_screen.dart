import 'package:flutter/material.dart';
import 'package:foodie/common_widgets/main_button.dart';
import 'package:foodie/constants.dart';
import 'package:foodie/main_layout.dart';
import 'package:foodie/screens/remider_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Initial Selected Value
  String dropdownvalue = 'Cholesterol';
  int _selectedIndex = 0;

  // List of items in our dropdown menu
  var items = [
    'Cholesterol',
    'Diabetes',
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MainLayout(
      title: 'USER DETAILS',
      customBody: Container(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 8,
                          child: Icon(
                            Icons.check,
                            size: 11,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Do you have a chronic diseases',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: Row(
                        key: ValueKey<int>(_selectedIndex),
                        children: [
                          _toggleButton(btnTitle: 'No', btnIndex: 0),
                          const SizedBox(
                            width: 20,
                          ),
                          _toggleButton(btnTitle: 'Yes', btnIndex: 1)
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Visibility(
                      visible: _selectedIndex == 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Select chronic diseases',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 45,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                iconSize: 15,
                                padding: EdgeInsets.zero,
                                isExpanded: true,
                                // Initial Value
                                value: dropdownvalue,

                                // Down Arrow Icon
                                icon: const Icon(Icons.keyboard_arrow_down),

                                // Array list of items
                                items: items.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownvalue = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            MainButton(
              size: size,
              title: 'CONFIRM',
              onTap: () {
                print(dropdownvalue);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderScreen(
                      diseases: _selectedIndex == 1 ? dropdownvalue : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Expanded _toggleButton({required String btnTitle, required int btnIndex}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = btnIndex;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  width: 2,
                  color: _selectedIndex == btnIndex
                      ? AppColors.primaryColor
                      : Colors.transparent)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: _selectedIndex == btnIndex
                    ? Image.asset(
                        'assets/icons/on_switch.png',
                        height: 25,
                        width: 25,
                      )
                    : Image.asset(
                        'assets/icons/off_switch.png',
                        height: 25,
                        width: 25,
                      ),
              ),
              Text(
                btnTitle,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}
