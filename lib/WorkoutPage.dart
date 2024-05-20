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
import 'ExploreRoutines.dart';
import 'CreateRoutine.dart';
import 'Account.dart';
import 'logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Start',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Post()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.blueAccent,),
                            SizedBox(width: 5,),
                            Text('Start Empty Workout',
                              style: TextStyle(
                                  color: Colors.blue
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    Text('Routines',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateRoutine()),
                              );
                            },
                            child: Column(
                              children: [
                                Icon(Icons.list_alt_outlined),
                                Text('New Routine'),
                              ],
                            )
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ExploreRoutines()),
                              );
                            },
                            child: Column(
                              children: [
                                Icon(Icons.search),
                                Text('Explore Routines'),
                              ],
                            )
                        )
                      ],
                    )
                  ],
                )
            )
        )
    );
  }
}