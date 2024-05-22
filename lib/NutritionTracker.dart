import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NutritionProvider.dart';

class NutritionTracker extends StatefulWidget {
  @override
  _NutritionTrackerState createState() => _NutritionTrackerState();
}

class _NutritionTrackerState extends State<NutritionTracker> {
  TextEditingController _nutrientController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _caloriesController = TextEditingController();
  List<Nutrition> _addedNutrients = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadNutritionData(); // i had a stupid mistake here took me forever to see it
  }

  Future<void> _saveNutritionData() async {
    List<Map<String, dynamic>> nutritionData =
    _addedNutrients.map((nutrition) => nutrition.toJson()).toList();

    await _prefs.setString('nutrition_data', jsonEncode(nutritionData));
  }

  Future<void> _loadNutritionData() async {
    String? jsonData = _prefs.getString('nutrition_data');
    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Nutrition> loadedNutrients =
      decodedData.map((item) => Nutrition.fromJson(item)).toList();

      setState(() {
        _addedNutrients = loadedNutrients;
      });
    }
  }

  void _addNutrient() {
    final nutrient = _nutrientController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    if (nutrient.isNotEmpty && amount > 0 && calories >= 0) {
      final newNutrient = Nutrition(
        nutrient,
        amount,
        calories,
        Colors.primaries[_addedNutrients.length % Colors.primaries.length],
      );

      setState(() {
        _addedNutrients.add(newNutrient);
      });

      _saveNutritionData();

      _nutrientController.clear();
      _amountController.clear();
      _caloriesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputFields(),
            SizedBox(height: 10),
            _buildAddButton(),
            SizedBox(height: 20),
            Expanded(
              child: _addedNutrients.isEmpty
                  ? _buildEmptyState()
                  : _buildNutrientListAndChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _nutrientController,
          decoration: InputDecoration(
            labelText: 'Nutrient',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_dining),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount (grams)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_list_numbered),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Calories',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_fire_department),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _addNutrient,
      icon: Icon(Icons.add),
      label: Text('Add Nutrient'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No nutrients added yet.',
        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildNutrientListAndChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<Nutrition, String>(
                dataSource: _addedNutrients,
                explode: true, //Enable exploded pie slices
                explodeIndex: 0, //Index of the slice to explode
                explodeOffset: '10%', //Offset of the exploded slice
                radius: '90%', //Adjust the size of the pie chart
                startAngle: 90, // tart angle of the first slice
                endAngle: 450, //End angle of the last slice
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                ),
                pointColorMapper: (Nutrition data, _) => data.color,
                xValueMapper: (Nutrition data, _) => data.nutrient,
                yValueMapper: (Nutrition data, _) {
                  final totalCalories = _addedNutrients.fold<double>(
                    0,
                        (sum, nutrient) => sum + nutrient.calories,
                  );
                  return data.calories / totalCalories * 100;
                },
                enableTooltip: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Added Nutrients:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _addedNutrients.length,
            itemBuilder: (context, index) {
              final nutrient = _addedNutrients[index];
              return ListTile(
                title: Text(
                  '${nutrient.nutrient} (${nutrient.amount} g)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${nutrient.calories} calories'),
                leading: CircleAvatar(
                  backgroundColor: nutrient.color,
                  child: Icon(Icons.local_dining, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
