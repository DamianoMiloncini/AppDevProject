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

  factory ChartData.fromJson(String source) => ChartData.fromMap(json.decode(source));
}

class BMIPage extends StatefulWidget {
  const BMIPage({Key? key}) : super(key: key);

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  double _height = 0; // HARDCODED FOR NOW
  double weight = 0;
  late UserProvider userProvider;
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  String formattedDate = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  List<ChartData> chartData = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    getHeight();
    loadChartData();
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared.');
  }

  Future<void> getWeight(UserProvider userProvider) async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        setState(() {
          weight = documentSnapshot.get('weight') ?? 0;
        });
        print('Weight was successfully fetched');
      } else {
        print('Couldn\'t get the weight from Firebase');
      }
    } catch (error) {
      print('Failed to fetch weight from Firebase $error');
    }
  }
  Future<void> getHeight() async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        setState(() {
          _height = documentSnapshot.get('height') ?? 0;
        });
        print('Height was successfully fetched');
      } else {
        print('Couldn\'t get the Height from Firebase');
      }
    } catch (error) {
      print('Failed to fetch Height from Firebase $error');
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
  Future<void> addHeight(String userID) async {
    try {
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userID).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        await documentSnapshot.reference.update({
          'height': _height // Update with bmi parameter, not class variable BMI
        });
        print('BMI added in the user\'s document');
      } else {
        print('BMI couldn\'t be added to the user\'s document');
      }
    } catch (error) {
      print('Failed to update BMI in Firebase $error');
    }
  }

  double BMICalculation() {
    double heightMeter = _height * 0.3048;
    double division = weight / (heightMeter * heightMeter);
    return division;
  }
  Future<void> loadChartData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('chartBMIData')) {
      setState(() {
        final List<String> chartDataJson = _prefs.getStringList('chartBMIData')!;
        chartData = chartDataJson.map((json) => ChartData.fromJson(json)).toList();
      });
    } else {
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
    await _prefs.setStringList('chartBMIData', chartDataJson);
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context); // Access UserProvider with listen: true


    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Page', style: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_height', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 5),
            Text('Height (FT)', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 5),
            Slider(
              value: _height,
              max: 7,
              min: 0,
              label: _height.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _height = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.purple.shade100,
            ),
            SizedBox(height: 10.0),
            ElevatedButton.icon(
              onPressed: () {
                double bmi = BMICalculation();
                setState(() {
                  addBMI(userProvider.user!.uid, bmi);
                  addHeight(userProvider.user!.uid);
                  chartData.add(ChartData(formattedDate, bmi));
                  saveChartData();
                });
              },
              icon: Icon(Icons.update, color: Colors.white),
              label: Text('Update BMI', style: TextStyle(fontFamily: 'Comic Sans MS')),
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
                    color: Colors.blueGrey,
                  ),
                ],
                title: ChartTitle(
                  text: 'BMI Over Time',
                  textStyle: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.deepPurpleAccent),
                ),
                legend: Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontFamily: 'Comic Sans MS', color: Colors.deepPurpleAccent)),
                tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
