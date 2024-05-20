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
  double _height = 6; // HARDCODED FOR NOW
  double weight = 0;
  late UserProvider userProvider;
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  String formattedDate = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  List<ChartData> chartData = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    //clearSharedPreferences();
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

    // Fetch weight whenever the userProvider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWeight(userProvider);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$_height', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text('Height (FT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              double bmi = BMICalculation();
              setState(() {
                addBMI(userProvider.user!.uid, bmi);
                chartData.add(ChartData(formattedDate, bmi));
                saveChartData();
              });
            },
            child: Text('Update BMI'),
          ),
             SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
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
