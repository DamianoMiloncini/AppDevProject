import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'WeightPage.dart';
import 'BMIPage.dart';
import 'Session.dart';


class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  double BMI = 0;
  double _height = 0;
  double weight = 0;
  int age = 0;
  bool _isWomanChecked = false;
  bool _isManChecked = false;
  String chart = '';

  double BMICalculation() {
    double heightMeter = _height * 0.3048;
    double division = weight / (heightMeter * heightMeter);
    setState(() {
      BMI = division;
    });
    return BMI;
  }

  String getText() {
    if(BMI >=25) {
      return 'Overweight';
    }
    else if (BMI >18.5){
      return 'Normal';
    }
    else {
      return 'Underweight';
    }
  }
  //to make the userprovider a global variable
  late UserProvider userProvider;
  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);// Initialize userProvider in initState
    getWeight(); //get the weight as soon as the page loads
    getBMI(); //get the bmi as soon as the page loads
  }
  //get the weight from the user account
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
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
          weight = documentSnapshot.get('weight');
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

  Future<void> getBMI() async {
    try {
      //take the document where the user id = the user id passed in the parameter
      QuerySnapshot querySnapshot = await _userCollection.where('uid', isEqualTo: userProvider.user!.uid).get();
      //check if there is a document with that id
      if (querySnapshot.docs.length > 0) {
        //if yes, update the document with the weight
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        //get the weight
        setState(() {
          BMI = documentSnapshot.get('BMI');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            //progress title
            Text('Progress'),
            //gridview container
            Container(
              height: 500,
              child: GridView.count(
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(
                            0,
                            1,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight'),
                        Text('$weight'),
                        SizedBox(height: 45,),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WeightPage()));

                        }, child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('View now'),
                            Icon(
                                Icons.arrow_forward_ios
                            )
                          ],
                        ))
                      ],
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1,),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BMI'),
                        Text('$BMI'),
                        SizedBox(height: 45,),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BMIPage()));

                        }, child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('View now'),
                            Icon(
                                Icons.arrow_forward_ios
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]

        ),
      )
    );
  }
}

