import 'package:flutter/material.dart';

import 'dart:convert';

class Nutrition {
  String nutrient;
  double amount;
  double calories;
  Color color; // Assuming Color is imported correctly

  Nutrition(this.nutrient, this.amount, this.calories, this.color);

  // Convert Nutrition object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'nutrient': nutrient,
      'amount': amount,
      'calories': calories,
      'color': color.value, // Store color as int value for serialization
    };
  }

  // Create Nutrition object from JSON map
  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      json['nutrient'],
      json['amount'].toDouble(),
      json['calories'].toDouble(),
      Color(json['color']), // Convert int back to Color object
    );
  }
}




class NutritionProvider with ChangeNotifier {
  List<Nutrition> _nutritionData = [];

  List<Nutrition> get nutritionData => _nutritionData;

  void addNutrition(Nutrition nutrition) {
    _nutritionData.add(nutrition);
    notifyListeners();
  }

  void clearNutrition() {
    _nutritionData.clear();
    notifyListeners();
  }
}
