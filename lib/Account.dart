import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Comments.dart';
import 'NutritionTracker.dart';
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
    if (BMI >= 25) {
      return 'Overweight';
    } else if (BMI > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');
  List<Map<String, dynamic>> _userPosts = [];

  //Map to store user IDs and corresponding usernames
  Map<String, String> _usernames = {};
  Map<String, String> _pfp = {};
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _commentsCollection =
  FirebaseFirestore.instance.collection('comments');
  //Method to fetch username by user ID
  Future<void> _fetchUsername(String uid) async {
    if (!_usernames.containsKey(uid)) {
      try {
        DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            _usernames[uid] = userDoc.get('username') ??
                'Unknown'; //if cannot be found, put unknown user
          });
        } else {
          setState(() {
            _usernames[uid] = 'Unknown';
          });
        }
      } catch (e) {
        print('Error fetching username: $e');
        setState(() {
          _usernames[uid] = 'Unknown';
        });
      }
    }
  }

  Future<void> _fetchPFP(String uid) async {
    if (!_pfp.containsKey(uid)) {
      try {
        DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            _pfp[uid] = userDoc.get('pfp') ??
                '1'; //if cannot be found, put unknown user
          });
        } else {
          setState(() {
            _pfp[uid] = '1';
          });
        }
      } catch (e) {
        print('Error fetching profile picture: $e');
        setState(() {
          _pfp[uid] = '1';
        });
      }
    }
  }

  // Get the user's posts
  Future<void> getUserPosts() async {
    try {
      QuerySnapshot querySnapshot = await _postCollection
          .where('uid', isEqualTo: userProvider.user!.uid)
          .get();
      setState(() {
        _userPosts = querySnapshot.docs
            .map((doc) => doc.data()! as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }

  Future<void> deletePost(String postId) async {
        try {
          // Reference to the comments collection
          QuerySnapshot commentsQuery = await _commentsCollection.where('postID', isEqualTo: postId).get();
          print('Comments to delete: ${commentsQuery.docs.length}');
          // Delete each comment associated with the post
          for (var commentDoc in commentsQuery.docs) {
            await commentDoc.reference.delete();
          }
            await _postCollection.doc(postId).delete();
          setState(() {
            _userPosts.removeWhere((post) => post['id'] == postId);
          });
        }
        catch (error) {
          print('Failed to delete the post $error');
        }
  }

  // Make the userProvider a global variable
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context,
        listen: false); // Initialize userProvider in initState
    getWeight(); // Get the weight as soon as the page loads
    getBMI(); // Get the BMI as soon as the page loads
    getUserPosts(); // Get user posts as soon as the page loads
  }

  // Get the weight from the user account

  Future<void> getWeight() async {
    try {
      // Take the document where the user id = the user id passed in the parameter
      QuerySnapshot querySnapshot = await _userCollection
          .where('uid', isEqualTo: userProvider.user!.uid)
          .get();
      // Check if there is a document with that id
      if (querySnapshot.docs.length > 0) {
        // If yes, update the document with the weight
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        // Get the weight
        setState(() {
          weight = documentSnapshot.get('weight');
        });
        print('Weight was successfully fetched');
      } else {
        print('Couldn\'t get the weight from Firebase');
      }
    } catch (error) {
      print('Failed to update weight in Firebase $error');
    }
  }

  Future<void> getBMI() async {
    try {
      // Take the document where the user id = the user id passed in the parameter
      QuerySnapshot querySnapshot = await _userCollection
          .where('uid', isEqualTo: userProvider.user!.uid)
          .get();
      // Check if there is a document with that id
      if (querySnapshot.docs.length > 0) {
        // If yes, update the document with the weight
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        // Get the weight
        setState(() {
          BMI = documentSnapshot.get('BMI');
        });
        print('BMI was successfully fetched');
      } else {
        print('Couldn\'t get the BMI from Firebase');
      }
    } catch (error) {
      print('Failed to update BMI in Firebase $error');
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
            // Progress title
            Text('Progress'),
            // GridView container
            Container(
              height: 250,
              child: GridView.count(
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: [
                  Container(

                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
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
                        SizedBox(height: 45),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WeightPage()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('View now'),
                              Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
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
                        Text(getText()),
                        SizedBox(height: 26),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BMIPage()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('View now'),
                              Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nutrition Tracker'),
                        SizedBox(height: 45),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NutritionTracker()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('View now'),
                              Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text('My Posts'),
            Container(
              //height: 400, // Adjust the height as needed
              child: ListView(
                shrinkWrap: true,
                children: _userPosts.map((post) {
                  Timestamp timestamp = post['timestamp'];
                  DateTime date = timestamp.toDate();
                  String uid = post['uid'];
                  String postID = post['id'];

                  //Fetch the username for each post
                  _fetchUsername(uid);
                  _fetchPFP(uid);
                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle post click
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/profile_pictures/${_pfp[uid]}.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      _usernames[uid] ?? 'Loading...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                        '${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute}'),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Expanded(
                                  child: Text(
                                    post['description'],
                                  ),
                                ),
                                Divider(
                                  height: 2,
                                  thickness: 1,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Comments(data: post)));
                                        },
                                        child: Icon(Icons.message),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Icon(Icons.favorite_border),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Icon(Icons.share),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //delete button
                      Positioned(
                        right: 20,
                        child: TextButton(onPressed: () {
                          deletePost(postID);
                      }, child: Icon(Icons.delete),
                      ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
