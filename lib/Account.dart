import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'comments.dart';


import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  double BMI = 0;
  double _height = 0;
  int weight = 0;
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
                        Text('$BMI'),
                        SizedBox(height: 45,),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(onPressed: () {

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

