import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'Session.dart';

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
  String formattedDate = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  double height = 0;
  Future <void> addWeight(String userID, double weight) async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userID).get();
      if (querySnapshot.docs.length > 0) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        await documentSnapshot.reference.update({
          'weight': weight
        });
        print('Weight added in the user\'s document');
      } else {
        print('Weight couldn\'t be added to the user\'s document');
      }
    } catch (error) {
      print('Failed to update weight in Firebase: $error');
    }
  }

  List<ChartData> chartData = [];
  late SharedPreferences _prefs;
  late UserProvider userProvider;
  double weight = 0;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    getWeight();
    getHeight();
    loadChartData();
  }

  Future<void> getWeight() async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      if (querySnapshot.docs.length > 0) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        setState(() {
          weight = documentSnapshot.get('weight') ?? 0;
        });
        print('Weight was successfully fetched');
      } else {
        print('Couldn\'t get the weight from Firebase');
      }
    } catch (error) {
      print('Failed to get weight from Firebase: $error');
    }
  }
  Future<void> addBMI(String userID, double bmi) async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userID).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        await documentSnapshot.reference.update({
          'BMI': bmi // Update with bmi parameter, not class variable BMI
        });
        print('BMI added in the user\'s document');
      } else {
        print('BMI couldn\'t be added to the user\'s document');
      }
    } catch (error) {
      print('Failed to update BMI in Firebase $error');
    }
  }
  Future<void> getHeight() async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        setState(() {
          height = documentSnapshot.get('height') ?? 0;
        });
        print('Height was successfully fetched');
      } else {
        print('Couldn\'t get the Height from Firebase');
      }
    } catch (error) {
      print('Failed to fetch Height from Firebase $error');
    }
  }
  double BMICalculation(double weight) {
    double heightMeter = height * 0.3048;
    double division = weight / (heightMeter * heightMeter);
    return division;
  }

  Future<void> loadChartData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('chartWeightData')) {
      setState(() {
        final List<String> chartDataJson = _prefs.getStringList('chartWeightData')!;
        chartData = chartDataJson.map((json) => ChartData.fromJson(json)).toList();
      });
    } else {
      setState(() {
        chartData = [
          ChartData('2024-01-01', weight),
          ChartData('2024-02-04', 35),
          ChartData('2024-02-05', 28),
          ChartData('2024-02-08', 34),
          ChartData('2024-03-05', 32),
        ];
      });
    }
  }

  Future<void> saveChartData() async {
    final List<String> chartDataJson = chartData.map((data) => data.toJson()).toList();
    await _prefs.setStringList('chartWeightData', chartDataJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Page', style: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _weight,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter your weight',
                hintStyle: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                suffixIcon: Icon(Icons.monitor_weight, color: Colors.blueGrey),
              ),
              style: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.purple),
            ),
            SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_weight.text.isNotEmpty) {
                  double bmi = BMICalculation(double.parse(_weight.text));
                  setState(() {
                    addWeight(userProvider.user!.uid, double.parse(_weight.text));
                    addBMI(userProvider.user!.uid, bmi);
                    chartData.add(ChartData(formattedDate, double.parse(_weight.text)));
                    _weight.text = '';
                    saveChartData();
                  });
                }
              },
              icon: Icon(Icons.update, color: Colors.white),
              label: Text('Update Weight', style: TextStyle(fontFamily: 'Comic Sans MS')),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.month,
                    yValueMapper: (ChartData data, _) => data.weight,
                    markerSettings: MarkerSettings(isVisible: true, color: Colors.white, shape: DataMarkerType.circle),
                    color: Colors.deepPurpleAccent,
                  ),
                ],
                title: ChartTitle(
                  text: 'Weight Over Time',
                  textStyle: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.blueGrey),
                ),
                legend: Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.purple)),
                tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y kg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
