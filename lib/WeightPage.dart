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
  //add weight to user in firebase
  Future <void> addWeight(String userID, double weight) async {
    try {
      //take the document where the user id = the user id passed in the parameter
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userID).get();

      //check if there is a document with that id
      if (querySnapshot.docs.length > 0) {
        //if yes, update the document with the weight
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        await documentSnapshot.reference.update({
          'weight': weight
        });
        print('weight added in the users document');
      }
      else {
        print('weight couldnt be added to the users document');
      }
    }
    catch (error){
      print('Failed to update weight in firebase $error');
    }


  }
  List<ChartData> chartData = [];
  late SharedPreferences _prefs;
  late UserProvider userProvider;
  double weight = 0;

  @override
  void initState() {
    super.initState();
    //clearSharedPreferences();
    userProvider = Provider.of<UserProvider>(context, listen: false);// Initialize userProvider in initState
    getWeight();
    loadChartData();
  }
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared.');
  }
  Future<void> getWeight() async {
    try {
      //take the document where the user id = the user id passed in the parameter
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      //check if there is a document with that id
      if (querySnapshot.docs.length > 0) {
        //if yes, update the document with the weight
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        //get the weight
        setState(() {
          weight = documentSnapshot.get('weight') ?? 0;
        });
        print('weight was successfully fetched');
      }
      else {
        print('couldnt get the weight from firebase');
      }
    }
    catch (error){
      print('Failed to update weight in firebase $error');
    }
  }

  Future<void> loadChartData() async {
    _prefs = await SharedPreferences.getInstance(); // need this to store data so that when you switch pages and come back, the weight inputted before still shows
    print(_prefs);
    if (_prefs.containsKey('chartWeightData')) {
      setState(() {
        final List<String> chartDataJson = _prefs.getStringList('chartWeightData')!;
        chartData = chartDataJson.map((json) => ChartData.fromJson(json)).toList();
      });
    } else {
      // Initialize with default data
      setState(() {
        chartData = [
          ChartData('2024-01-01', weight),
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
    await _prefs.setStringList('chartWeightData', chartDataJson);
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
                  addWeight(userProvider.user!.uid, double.parse(_weight.text));
                  // Add the weight to chart data
                  chartData.add(ChartData(formattedDate, double.parse(_weight.text)));
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
