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
                  children: [
                    Padding(
                        padding: EdgeInsets.all(15),
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
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                  ),
                                ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CreateRoutine()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(

                                    padding: EdgeInsetsDirectional.fromSTEB(47, 15, 47, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.list_alt_outlined, color: Colors.blue),
                                      Text(
                                        'New Routine',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ExploreRoutines()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsetsDirectional.fromSTEB(32, 15, 32, 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search, color: Colors.blue),
                                        Text('Explore Routines',
                                        style: TextStyle(
                                            color: Colors.blue
                                        ),),
                                      ],
                                    )
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )

                  ],
                )
            )
        )
    );
  }
}