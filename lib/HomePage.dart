import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'NotificationService.dart';
import 'firebase_options.dart';
import 'comments.dart';
import 'package:provider/provider.dart';
import 'Session.dart';
import 'ExerciseList.dart';
import 'Post.dart';
import 'package:timezone/data/latest.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _postStream =
  FirebaseFirestore.instance.collection('posts').snapshots();
  Map<String, dynamic>? _selectedData;
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  late UserProvider userProvider;

  //Map to store user IDs and corresponding usernames
  Map<String, String> _usernames = {};
  Map<String, String> _pfp = {};

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    tz.initializeTimeZones();
  }

  //Method to fetch username by user ID
  Future<void> _fetchUsername(String uid) async {
    if (!_usernames.containsKey(uid)) {
      try {
        DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            _usernames[uid] = userDoc.get('username') ?? 'Unknown'; //if cannot be found, put unknown user
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
            _pfp[uid] = userDoc.get('pfp') ?? '1'; //if cannot be found, put unknown user
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

  void _toggleContent(Map<String, dynamic>? data) {
    setState(() {
      _selectedData = data;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _selectedData == null
          ? _HomePage2(_postStream, _toggleContent)
          : _DetailsPost(_selectedData!), //if the selected data is not null, show this view
    );
  }

  Widget _HomePage2(
      Stream<QuerySnapshot> postStream, Function(Map<String, dynamic>?) toggleContent) {
    userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello,',
                style: TextStyle(fontSize: 35),
              ),
              Text(
                userProvider.user!.username,
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            'Your current progress of the day',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: postStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong :(');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    String uid = data['uid'];

                    //Fetch the username for each post
                    _fetchUsername(uid);
                    _fetchPFP(uid);

                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                _toggleContent(data);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: 300,
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
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 15,),
                                        Text(_usernames[uid] ?? 'Loading...'), //display the username here
                                        SizedBox(width: 15,),
                                        Text('${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute} '),
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    Expanded(
                                      child: Text(
                                        data['description'],
                                      ),
                                    ),
                                    Divider(
                                      height: 2,
                                      thickness: 1,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Comments(data: data)));
                                            },
                                            child: Icon(Icons.message),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              NotificationService().showNotification(1, 'Test Title', 'Test Body');

                                            },
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
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _DetailsPost(Map<String, dynamic> data) {
    Timestamp timestamp = data['timestamp'];
    DateTime date = timestamp.toDate();
    var exercises = data['exercises'];

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['title'],
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                ),
                Text(
                  '${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute} ',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              data['description'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (BuildContext context, int index) {
                var exercise = exercises[index];
                var sets = exercise['sets'];

                //Exercise card
                Widget exerciseCard = Card(

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exercise['muscle']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${exercise['name']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: sets.length,
                          itemBuilder: (BuildContext context, int index) {
                            var set = sets[index];
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Set ${set['set']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.fitness_center, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        '${set['lbs']} lbs',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.replay, color: Colors.orange),
                                      SizedBox(width: 4),
                                      Text(
                                        '${set['reps']} reps',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
                return exerciseCard;
              },
            ),
            SizedBox(height: 10),
            // Back home button
            ElevatedButton(
              onPressed: () {
                _toggleContent(null); //Navigate back to the previous widget (HomePage)
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

}




