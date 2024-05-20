import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.month, this.weight);
  final String month;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'weight': weight,
    };
  }

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      map['month'],
      map['weight'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChartData.fromJson(String source) =>
      ChartData.fromMap(json.decode(source));
}

class WeightPage extends StatefulWidget {
  const WeightPage({Key? key}) : super(key: key);

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  TextEditingController _weight = TextEditingController();
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  //add weight to user in firebase
  Future <void> addWeight(String userID, double weight) {
    return _userCollection.add({
      'userID' : userID,
      'weight' : weight,
    }).then((value) => print('weight added to firebase')).catchError((error) => print('Failed to add the weight to firebase $error'));
  }
  List<ChartData> chartData = [
    ChartData('Jan', 0),
    ChartData('Feb', 0),
    ChartData('Mar', 0),
    ChartData('Apr', 0),];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    _prefs = await SharedPreferences.getInstance(); // need this to store data so that when you switch pages and come back, the weight inputted before still shows
    print(_prefs);
    if (_prefs.containsKey('chartData')) {
      setState(() {
        final List<String> chartDataJson = _prefs.getStringList('chartData')!;
        chartData = chartDataJson.map((json) => ChartData.fromJson(json)).toList();
      });
    } else {
      // Initialize with default data
      setState(() {
        chartData = [
          ChartData('Jan', 35),
          ChartData('Feb', 28),
          ChartData('Mar', 34),
          ChartData('Apr', 32),
        ];
      });
    }
  }

  Future<void> saveChartData() async {
    final List<String> chartDataJson = chartData.map((data) => data.toJson()).toList();
    await _prefs.setStringList('chartData', chartDataJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _weight,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter your weight',
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              if (_weight.text.isNotEmpty) {
                setState(() {
                  //add weight to a specific user
                  //addWeight(userID, double.parse(_weight.text));
                  // Add the weight to chart data
                  chartData.add(ChartData('May', double.parse(_weight.text)));
                  _weight.text = '';
                  saveChartData(); // Save chart data after modification
                });
              }
            },
            child: Text('Update Weight'),
          ),
          //SizedBox(height: 20.0),
                SfCartesianChart(
                primaryXAxis: CategoryAxis(), // Use CategoryAxis for categorical data (months)
                series: <CartesianSeries>[
                  // Renders line chart
                  LineSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.month,
                    yValueMapper: (ChartData data, _) => data.weight,
                  )
                ],
              ),

        ],
      ),
    );
  }
}
