import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String type;
  final Map<String, String> nutritions;
  final String? mealTime;
  final DateTime? dateTime;
  final String? dayName;
  final List<String> diseases; 

  Meal({
    required this.type,
    required this.nutritions,
    this.mealTime,
    this.dateTime,
    this.dayName,
    required this.diseases, 
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      type: map['type'],
      nutritions: Map<String, String>.from(map['nutritions']),
      mealTime: map['mealTime'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      dayName: map['dayName'],
      diseases: List<String>.from(map['diseases'] ?? []), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'nutritions': nutritions,
      'mealTime': mealTime,
      'dateTime': dateTime,
      'dayName': dayName,
      'diseases': diseases, 
    };
  }
}
