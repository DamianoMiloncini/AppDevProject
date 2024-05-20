import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'comments.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _postStream =
  FirebaseFirestore.instance.collection('posts').snapshots();
  Map<String, dynamic>? _selectedData; // Track selected data


  void _toggleContent(Map<String, dynamic>? data) {
    setState(() {
      _selectedData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedData == null
          ? _HomePage2(
          _postStream, _toggleContent) // Show original content if data is null
          : _DetailsPost(
          _selectedData!), // Show details post if data is not null
    );
  }

  Widget _HomePage2(Stream<QuerySnapshot> postStream,
      Function(Map<String, dynamic>?) toggleContent) {
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
              //TODO: Fetch the actual username logged in !
              Text(
                'Micka',
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
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong :(');
              }
              //if the data is loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); //ofc i had to use it
              }
              //ListView of all the posts
              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((
                      DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                // Toggle content and pass the selected data to DetailsPost
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
                                    // Have the user avatar & username
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
                                        // TODO: fetch the actual username from firebase and add it here amigo
                                        Text('Username'),
                                        SizedBox(width: 15,),
                                        Text('${date.year}-${date.month}-${date
                                            .day}  ${date.hour}:${date
                                            .minute} ')
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    //workout description
                                    Expanded(
                                      child: Text(
                                        data['description'],
                                      ), //in case the user enters a long ass description
                                    ),
                                    Divider(
                                      height: 2,
                                      thickness: 1,
                                    ),
                                    //row of icons
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              //redirect to the comment page
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Comments(data : data)));
                                            },
                                            child: Icon(Icons.message),
                                          ),
                                          // should i add the number of comments and likes ?
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(Icons.favorite_border),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(
                                                Icons.bookmark_add_outlined),
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

  //TODO: Make this page better with a go back to main page pop
  Widget _DetailsPost(Map<String, dynamic> data) {
    Timestamp timestamp = data['timestamp'];
    DateTime date = timestamp.toDate();
    var exercises = data['exercises'];
    //var sets = exercises['sets'].toString();

    Widget printExercises() {
      return ListView.builder(
        //the amount of time i spent just for the solution to be shrinkWrap esti
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          var exercise = exercises[index];
          var sets = exercise['sets'];
          return Column(
            children: [
              Text('Muscle Target: ${exercise['muscle']}'),
              Text('Exercice : ${exercise['name']}'),
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
                  }
              )
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
          Text(data['title'],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32)),
          Text('${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute} '),
          SizedBox(height: 20,),
          Text(data['description']),
          printExercises(),
        ],
      ),
    );
  }
}
