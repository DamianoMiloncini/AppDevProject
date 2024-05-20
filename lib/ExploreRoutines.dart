import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'Post.dart';
import 'CreateRoutine.dart';
import 'WorkoutPage.dart';
import 'Account.dart';
import 'logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreRoutines extends StatefulWidget {
  const ExploreRoutines({super.key});

  @override
  State<ExploreRoutines> createState() => _ExploreRoutinesState();
}

class _ExploreRoutinesState extends State<ExploreRoutines> {
  String _heading = 'Your Routines';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Routines',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
      ),
      body: Center(
          child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _heading = "Your Routines";
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.person),
                              Text('Your Routines'),
                            ],
                          )
                      ),
                      ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _heading = "Explore Routines";
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.group),
                              Text('Explore Routines'),
                            ],
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    _heading,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue
                    ),
                  ),
                ],
              )
          )
      ),
    );
  }
}