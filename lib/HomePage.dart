import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'comments.dart';
import 'package:provider/provider.dart';
import 'Session.dart';
import 'ExerciseList.dart';
import 'Post.dart';

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

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
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
          : _DetailsPost(_selectedData!),
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

                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                toggleContent(data);
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
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
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
                                            onPressed: () {},
                                            child: Icon(Icons.favorite_border),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(Icons.bookmark_add_outlined),
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

    Widget printExercises() {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          var exercise = exercises[index];
          var sets = exercise['sets'];
          return Column(
            children: [
              Text('Muscle Target: ${exercise['muscle']}'),
              Text('Exercise: ${exercise['name']}'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: sets.length,
                itemBuilder: (BuildContext context2, int index2) {
                  var set = sets[index2];
                  return Column(
                    children: [
                      Text('Set ${set['set']}'),
                      Text('Lbs: ${set['lbs']}'),
                      Text('Reps: ${set['reps']}'),
                    ],
                  );
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['title'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32)),
          Text('${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute} '),
          SizedBox(height: 20,),
          Text(data['description']),
          printExercises(),
        ],
      ),
    );
  }
}




